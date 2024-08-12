"""
Data preparation for inner loop in core.gsreg_single_proc_result!() function
"""
function GSPR_data_preparation(order, data, fixedvars, fixedvars_colnum, intercept, in_sample_mask, panel_id, panel_id_column, outsample)
    depvar_out, expvars_out = nothing, nothing
    cols = get_selected_cols(order)
    data_cols_num = size(data, 2)
    if fixedvars !== nothing
        cols = append!(cols, fixedvars_colnum)
    elseif intercept
        append!(cols, data_cols_num)
    end
    depvar_data = @view(data[in_sample_mask, 1])
    expvars_data = @view(data[in_sample_mask, cols])
    if panel_id !== nothing
        panel_id_column = @view(panel_id_column[in_sample_mask])
    end
    nobs = size(depvar_data, 1)
    ncoef = size(expvars_data, 2)
    if outsample > 0
        depvar_out = @view(data[.!in_sample_mask, 1])
        expvars_out = @view(data[.!in_sample_mask, cols])
    end
    return depvar_data, expvars_data, nobs, ncoef, panel_id_column, depvar_out, expvars_out, cols
end

"""
Aggregation of main estimation instructions for inner loop in core.gsreg_single_proc_result!() function
"""
function GSPR_main_estimation_block(depvar_data, expvars_data, depvar_out, expvars_out, nobs, ncoef, met, ttest, outsample)
    bstd, rmseout = nothing, nothing
    b, er, fact = ols(depvar_data, expvars_data, met)
    er2 = er .^ 2                           # squared errors
    sse = sum(er2)                          # residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom
    var_er = var(er)						# variance of residuals
    rmse = sqrt(sse / nobs)                 # root mean squared error
    r2 = 1 - var_er / var(depvar_data)      # model R-squared  
    if ttest
        bstd = compute_beta_std(fact, met, sse, df_e, ncoef)
    end
    if outsample > 0
        erout = depvar_out - expvars_out * b          # out-of-sample residuals
        sseout = sum(erout .^ 2)                      # residual sum of squares
        rmseout = sqrt(sseout / size(erout, 1))       # root mean squared error
    end
    return b, er, er2, sse, var_er, rmse, r2, bstd, rmseout
end

"""
Code for residual tests in inner loop in core.gsreg_single_proc_result!() function
"""
function GSPR_residual_tests(residualtests, panel_id, cols, intercept, in_sample_maskdiff, datadiff, er, expvars_data, b, er2, met, nobs, id_count, panel_id_column,var_er, time)
    jbtest, wtest, panelwtest, bgtest, wootest = nothing, nothing, nothing, nothing, nothing
    if residualtests !== nothing && residualtests
        # Normality test
        # jbtest
        m1 = sum(er) / nobs
        m2 = sum((er .- m1) .^ 2) / nobs
        m3 = sum((er .- m1) .^ 3) / nobs
        m4 = sum((er .- m1) .^ 4) / nobs
        b1 = (m3 / m2^(3 / 2))^2
        b2 = (m4 / m2^2)
        statistic = nobs * b1 / 6 + nobs * (b2 - 3)^2 / 24
        d = Chisq(2.0)
        jbtest = 1 .- cdf(d, statistic)

        if panel_id === nothing
            # Standard White heteroskedasticity test
            ŷ = expvars_data * b
            regmatw = hcat((ŷ .^ 2), ŷ, ones(size(ŷ, 1)))
            residw= ols_small(er2, regmatw, met) 
            rsqw = 1 - dot(residw, residw) / dot(er2, er2) # uncentered R^2
            statisticw = nobs * rsqw
            wtest = ccdf(Chisq(2), statisticw)   
            if time !== nothing 
                # Breusch-Godfrey serial correlation test
                lag = 1
                elag = zeros(Float64, nobs, lag)
                for i in 1:lag  # construct lagged residuals
                    elag[i+1:end, ii] = er[1:end-i]
                end
                regmatbg = [expvars_data[lag+1:end, :] elag[lag+1:end, :]]
                residbg = ols_small(e[lag+1:end], regmatbg, met)
                rsqbg = 1 - dot(residbg, residbg) / dot(e[lag+1:end], e[lag+1:end]) # uncentered R^2
                statisticbg = (nobs - lag) * rsqbg
                bgtest = ccdf(Chisq(lag), statisticbg)
            end
        else
            # Panel heteroskedasticity test (Wald statistic - based on Stata xttest3 package)
            si = zeros(nobs)            # ML variance for each observation
            incremental_count = zeros(Int, id_count)
            iota = zeros(Int, nobs)  # Count of observations per unit for each observation
            v = Vector{Union{Float64, Missing}}(undef, nobs)  # Variance for each observation
            wald = Vector{Union{Float64, Missing}}(undef, id_count)
            sums_er2data = [(panel_id_column[i], er2[i]) for i in 1:nobs]
            counts_panel_id_data = [(panel_id_column[i], 1) for i in 1:nobs]
            e2_sum = reduce(aggregate_sums_counts, sums_er2data, init=zeros(Float32, id_count))
            count = reduce(aggregate_sums_counts, counts_panel_id_data, init=zeros(Int, id_count))
            si .= e2_sum[panel_id_column] ./ count[panel_id_column]
            esig = (er2 .- si) .^ 2
            esigTuple = [(panel_id_column[i], esig[i]) for i in 1:nobs]
            sum_esig = reduce(aggregate_sums_counts, esigTuple, init=zeros(Float32, id_count))
            for i in 1:nobs
                id = panel_id_column[i]
                incremental_count[id] += 1
                v[i] = sum_esig[id] / incremental_count[id]
                iota[i] = incremental_count[id]
                if iota[i] > 1 && iota[i] == incremental_count[id]
                    v[i] /= (iota[i] - 1)
                end
            end
            panel_id_indices = [(panel_id_column[i], i) for i in 1:nobs]
            v_reduced = reduce((acc, x) -> extract_last_observation(acc, x, v), panel_id_indices; init=zeros(Float32, id_count))
            si_reduced = reduce((acc, x) -> extract_last_observation(acc, x, si), panel_id_indices; init=zeros(Float32, id_count))
            siS = (si_reduced .- var_er * (nobs - 1) / nobs) .^ 2
            wald .= siS ./ v_reduced  
            waldval = sum((wald))
            panelwtest = ccdf(Chisq(id_count), waldval)

            # Panel serial correlation test. Wooldridge test using datadiff matrix with first differences of original data (based on Stata xtserial package)
            if intercept
                colsdiff = cols[1:end-1]
            else
                colsdiff = cols
            end
            depvar_datadiff = @view(datadiff[in_sample_maskdiff, 1])
            expvars_datadiff = @view(datadiff[in_sample_maskdiff, colsdiff])
            wooer = ols_small(depvar_datadiff, expvars_datadiff, met)
            lagwooer = [zero(eltype(wooer)); wooer[1:end-1]]
            change_indices = vcat(1, findall(diff(panel_id_column) .!= 0) .+ 1)
            mask = trues(length(lagwooer))
            mask[change_indices] .= false
            lagwooer = lagwooer[mask]
            wooer = wooer[mask]
            wooer_res = ols_small(wooer, lagwooer, met)
            sse_unrestricted = sum(wooer_res .^ 2)
            fitted_wooer_restricted = lagwooer * -0.5
            wooer_res_restricted = wooer - fitted_wooer_restricted
            sse_restricted = sum(wooer_res_restricted .^ 2)
            df1 = 1
            df2 =  length(wooer) - 1
            F_stat = ((sse_restricted - sse_unrestricted) / df1) / (sse_unrestricted / df2)
            wootest = 1 - cdf(FDist(df1, df2), F_stat)
        end
    end
    return jbtest, wtest, panelwtest, bgtest, wootest
end

function GSPR_panel_tests(paneltests, SSB, id_count, sse, nobs, ncoef, unique_times, unique_ids, er, time_column, panel_id_column)
    anovastatistic, bplm = nothing, nothing
    if paneltests !== nothing && paneltests
        # Compute ANOVA F-test that all u_i=0.
        anovastatistic = (SSB/(id_count - 1)) / (sse/(nobs - id_count - ncoef))

        # Compute Breusch-Pagan Lagrange Multiplier (LM) test for cross-sectional independence (based on Stata xttest2 package)
        n_times = length(unique_times)
        n_groups = length(unique_ids)
        time_dict = Dict(t => i for (i, t) in enumerate(unique_times))
        id_dict = Dict(g => i for (i, g) in enumerate(unique_ids))
        T = eltype(er)  # This will give you the type of elements in `er`
        e_wide = Array{Union{Missing, T}}(missing, n_times, n_groups)
        for i in 1:nobs
            time_idx = time_dict[time_column[i]]
            group_idx = id_dict[panel_id_column[i]]
            e_wide[time_idx, group_idx] = er[i]
        end
        valid_rows_mask = Bool[]  # Initialize an empty boolean array
        for row in eachrow(e_wide)
            push!(valid_rows_mask, all(!ismissing, row))
        end
        e_wide_valid_rows = e_wide[valid_rows_mask, :]
        means = mean(e_wide_valid_rows, dims=1)
        centered_data = e_wide_valid_rows .- means
        n = size(e_wide_valid_rows, 1)  # Number of observations (rows)
        cov_matrix = (centered_data' * centered_data) / (n - 1)
        std_devs = sqrt.(diag(cov_matrix))  # Standard deviations of each column
        cor_matrix = cov_matrix ./ (std_devs * std_devs')
        CCp = cor_matrix * cor_matrix'
        tb = minimum(sum(.!ismissing.(e_wide), dims=1))  # minimum time series length
        tsig = (tr(CCp) - n_groups) * tb / 2
        df = n_groups * (n_groups - 1) / 2
        bplm = ccdf(Chisq(df), tsig)
    end
    return anovastatistic, bplm  
end          

"""
Function to store estimation results of the inner loop in core.gsreg_single_proc_result!() function ============= RESIDUALTESTS AND PANELTESTS !== NOTHING (V1)
"""
function GSPR_store_results!(results, outsample, ttest, residualtests::Bool, panel_id, time, paneltests::Bool, criteria, order, rmseout, expvars, fixedvars, cols, b, bstd, nobs, ncoef, sse, r2, rmse, jbtest, wtest, panelwtest, bgtest, wootest, anovastatistic, bplm, header, datatype)
    if outsample > 0
        results[order, header[:rmseout]] = rmseout
    end
    all_vars = vcat(expvars, fixedvars)
    results[order, header[:index]] = order
    for (index, col) in enumerate(cols)
        header[Symbol(string(all_vars[col-1], "_b"))]
        results[order, header[Symbol(string(all_vars[col-1], "_b"))]] = datatype(b[index])
        if ttest
            results[order, header[Symbol(string(all_vars[col-1], "_bstd"))]] = datatype(bstd[index])
        end
    end
    results[order, header[:nobs]] = nobs
    results[order, header[:ncoef]] = ncoef
    results[order, header[:sse]] = datatype(sse)
    results[order, header[:r2]] = datatype(r2)
    results[order, header[:rmse]] = datatype(rmse)
    results[order, header[:order]] = 0

    if residualtests !== nothing && residualtests    
        results[order, header[:normtest]] = jbtest
        if panel_id !== nothing
            results[order, header[:hettest]] = panelwtest
            results[order, header[:corrtest]] = wootest
        else
            results[order, header[:hettest]] = wtest
            if time !== nothing
                results[order, header[:corrtest]] = bgtest 
            end
        end
    end

    if paneltests !== nothing && paneltests
        results[order, header[:anovaftest]] = anovastatistic
        results[order, header[:bplmtest]] = bplm
    end

    if ttest
        for (index, col) in enumerate(cols)
            pos_b = header[Symbol(string(all_vars[col-1], "_b"))]
            pos_bstd = header[Symbol(string(all_vars[col-1], "_bstd"))]
            pos_t = header[Symbol(string(all_vars[col-1], "_t"))]
            results[order, pos_t] = results[order, pos_b] / results[order, pos_bstd]
        end
    end
    if :aic in criteria
        results[order, header[:aic]] = 2 * results[order, header[:ncoef]] + results[order, header[:nobs]] * log(results[order, header[:sse]] / results[order, header[:nobs]])
    end
    if :aicc in criteria
        if :aic in criteria
            results[order, header[:aicc]] = results[order, header[:aic]] + (2(results[order, header[:ncoef]] + 1) * (results[order, header[:ncoef]] + 2)) / (results[order, header[:nobs]] - (results[order, header[:ncoef]] + 1) - 1)
        else
            aic = 2 * results[order, header[:ncoef]] + results[order, header[:nobs]] * log(results[order, header[:sse]] / results[order, header[:nobs]])
            results[order, header[:aicc]] = aic + (2(results[order, header[:ncoef]] + 1) * (results[order, header[:ncoef]] + 2)) / (results[order, header[:nobs]] - (results[order, header[:ncoef]] + 1) - 1)
        end
    end
    if :bic in criteria
        results[order, header[:bic]] =
            results[order, header[:nobs]] * log.(results[order, header[:rmse]]) + (results[order, header[:ncoef]] - 1) * log.(results[order, header[:nobs]]) + results[order, header[:nobs]] + results[order, header[:nobs]] * log(2π)
    end
    if :r2adj in criteria
        results[order, header[:r2adj]] = 1 - (1 - results[order, header[:r2]]) * ((results[order, header[:nobs]] - 1) / (results[order, header[:nobs]] - results[order, header[:ncoef]]))
    end
    results[order, header[:F]] = (results[order, header[:r2]] / (results[order, header[:ncoef]] - 1)) / ((1 - results[order, header[:r2]]) / (results[order, header[:nobs]] - results[order, header[:ncoef]]))
end


"""
Function to store estimation results of the inner loop in core.gsreg_single_proc_result!() function ============= RESIDUALTESTS === NOTHING && PANELTESTS::BOOL (V2)
"""
function GSPR_store_results!(results, outsample, ttest, residualtests::Nothing, panel_id, time, paneltests::Bool, criteria, order, rmseout, expvars, fixedvars, cols, b, bstd, nobs, ncoef, sse, r2, rmse, jbtest, wtest, panelwtest, bgtest, wootest, anovastatistic, bplm, header, datatype)
    if outsample > 0
        results[order, header[:rmseout]] = rmseout
    end
    all_vars = vcat(expvars, fixedvars)
    results[order, header[:index]] = order
    for (index, col) in enumerate(cols)
        header[Symbol(string(all_vars[col-1], "_b"))]
        results[order, header[Symbol(string(all_vars[col-1], "_b"))]] = datatype(b[index])
        if ttest
            results[order, header[Symbol(string(all_vars[col-1], "_bstd"))]] = datatype(bstd[index])
        end
    end
    results[order, header[:nobs]] = nobs
    results[order, header[:ncoef]] = ncoef
    results[order, header[:sse]] = datatype(sse)
    results[order, header[:r2]] = datatype(r2)
    results[order, header[:rmse]] = datatype(rmse)
    results[order, header[:order]] = 0

    if paneltests !== nothing && paneltests
        results[order, header[:anovaftest]] = anovastatistic
        results[order, header[:bplmtest]] = bplm
    end

    if ttest
        for (index, col) in enumerate(cols)
            pos_b = header[Symbol(string(all_vars[col-1], "_b"))]
            pos_bstd = header[Symbol(string(all_vars[col-1], "_bstd"))]
            pos_t = header[Symbol(string(all_vars[col-1], "_t"))]
            results[order, pos_t] = results[order, pos_b] / results[order, pos_bstd]
        end
    end
    if :aic in criteria
        results[order, header[:aic]] = 2 * results[order, header[:ncoef]] + results[order, header[:nobs]] * log(results[order, header[:sse]] / results[order, header[:nobs]])
    end
    if :aicc in criteria
        if :aic in criteria
            results[order, header[:aicc]] = results[order, header[:aic]] + (2(results[order, header[:ncoef]] + 1) * (results[order, header[:ncoef]] + 2)) / (results[order, header[:nobs]] - (results[order, header[:ncoef]] + 1) - 1)
        else
            aic = 2 * results[order, header[:ncoef]] + results[order, header[:nobs]] * log(results[order, header[:sse]] / results[order, header[:nobs]])
            results[order, header[:aicc]] = aic + (2(results[order, header[:ncoef]] + 1) * (results[order, header[:ncoef]] + 2)) / (results[order, header[:nobs]] - (results[order, header[:ncoef]] + 1) - 1)
        end
    end
    if :bic in criteria
        results[order, header[:bic]] =
            results[order, header[:nobs]] * log.(results[order, header[:rmse]]) + (results[order, header[:ncoef]] - 1) * log.(results[order, header[:nobs]]) + results[order, header[:nobs]] + results[order, header[:nobs]] * log(2π)
    end
    if :r2adj in criteria
        results[order, header[:r2adj]] = 1 - (1 - results[order, header[:r2]]) * ((results[order, header[:nobs]] - 1) / (results[order, header[:nobs]] - results[order, header[:ncoef]]))
    end
    results[order, header[:F]] = (results[order, header[:r2]] / (results[order, header[:ncoef]] - 1)) / ((1 - results[order, header[:r2]]) / (results[order, header[:nobs]] - results[order, header[:ncoef]]))
end

"""
Function to store estimation results of the inner loop in core.gsreg_single_proc_result!() function ============= RESIDUALTESTS::BOOL AND PANELTESTS == NOTHING (V3)
"""
function GSPR_store_results!(results, outsample, ttest, residualtests::Bool, panel_id, time, paneltests::Nothing, criteria, order, rmseout, expvars, fixedvars, cols, b, bstd, nobs, ncoef, sse, r2, rmse, jbtest, wtest, panelwtest, bgtest, wootest, anovastatistic, bplm, header, datatype)
    if outsample > 0
        results[order, header[:rmseout]] = rmseout
    end
    all_vars = vcat(expvars, fixedvars)
    results[order, header[:index]] = order
    for (index, col) in enumerate(cols)
        header[Symbol(string(all_vars[col-1], "_b"))]
        results[order, header[Symbol(string(all_vars[col-1], "_b"))]] = datatype(b[index])
        if ttest
            results[order, header[Symbol(string(all_vars[col-1], "_bstd"))]] = datatype(bstd[index])
        end
    end
    results[order, header[:nobs]] = nobs
    results[order, header[:ncoef]] = ncoef
    results[order, header[:sse]] = datatype(sse)
    results[order, header[:r2]] = datatype(r2)
    results[order, header[:rmse]] = datatype(rmse)
    results[order, header[:order]] = 0

    if residualtests !== nothing && residualtests    
        results[order, header[:normtest]] = jbtest
        if panel_id !== nothing
            results[order, header[:hettest]] = panelwtest
            results[order, header[:corrtest]] = wootest
        else
            results[order, header[:hettest]] = wtest
            if time !== nothing
                results[order, header[:corrtest]] = bgtest 
            end
        end
    end

    if ttest
        for (index, col) in enumerate(cols)
            pos_b = header[Symbol(string(all_vars[col-1], "_b"))]
            pos_bstd = header[Symbol(string(all_vars[col-1], "_bstd"))]
            pos_t = header[Symbol(string(all_vars[col-1], "_t"))]
            results[order, pos_t] = results[order, pos_b] / results[order, pos_bstd]
        end
    end
    if :aic in criteria
        results[order, header[:aic]] = 2 * results[order, header[:ncoef]] + results[order, header[:nobs]] * log(results[order, header[:sse]] / results[order, header[:nobs]])
    end
    if :aicc in criteria
        if :aic in criteria
            results[order, header[:aicc]] = results[order, header[:aic]] + (2(results[order, header[:ncoef]] + 1) * (results[order, header[:ncoef]] + 2)) / (results[order, header[:nobs]] - (results[order, header[:ncoef]] + 1) - 1)
        else
            aic = 2 * results[order, header[:ncoef]] + results[order, header[:nobs]] * log(results[order, header[:sse]] / results[order, header[:nobs]])
            results[order, header[:aicc]] = aic + (2(results[order, header[:ncoef]] + 1) * (results[order, header[:ncoef]] + 2)) / (results[order, header[:nobs]] - (results[order, header[:ncoef]] + 1) - 1)
        end
    end
    if :bic in criteria
        results[order, header[:bic]] =
            results[order, header[:nobs]] * log.(results[order, header[:rmse]]) + (results[order, header[:ncoef]] - 1) * log.(results[order, header[:nobs]]) + results[order, header[:nobs]] + results[order, header[:nobs]] * log(2π)
    end
    if :r2adj in criteria
        results[order, header[:r2adj]] = 1 - (1 - results[order, header[:r2]]) * ((results[order, header[:nobs]] - 1) / (results[order, header[:nobs]] - results[order, header[:ncoef]]))
    end
    results[order, header[:F]] = (results[order, header[:r2]] / (results[order, header[:ncoef]] - 1)) / ((1 - results[order, header[:r2]]) / (results[order, header[:nobs]] - results[order, header[:ncoef]]))
end


"""
Function to store estimation results of the inner loop in core.gsreg_single_proc_result!() function ============= RESIDUALTESTS AND PANELTESTS === NOTHING (V4)
"""
function GSPR_store_results!(results, outsample, ttest, residualtests::Nothing, panel_id, time, paneltests::Nothing, criteria, order, rmseout, expvars, fixedvars, cols, b, bstd, nobs, ncoef, sse, r2, rmse, jbtest, wtest, panelwtest, bgtest, wootest, anovastatistic, bplm, header, datatype)
    if outsample > 0
        results[order, header[:rmseout]] = rmseout
    end
    all_vars = vcat(expvars, fixedvars)
    results[order, header[:index]] = order
    for (index, col) in enumerate(cols)
        header[Symbol(string(all_vars[col-1], "_b"))]
        results[order, header[Symbol(string(all_vars[col-1], "_b"))]] = datatype(b[index])
        if ttest
            results[order, header[Symbol(string(all_vars[col-1], "_bstd"))]] = datatype(bstd[index])
        end
    end
    results[order, header[:nobs]] = nobs
    results[order, header[:ncoef]] = ncoef
    results[order, header[:sse]] = datatype(sse)
    results[order, header[:r2]] = datatype(r2)
    results[order, header[:rmse]] = datatype(rmse)
    results[order, header[:order]] = 0

    if ttest
        for (index, col) in enumerate(cols)
            pos_b = header[Symbol(string(all_vars[col-1], "_b"))]
            pos_bstd = header[Symbol(string(all_vars[col-1], "_bstd"))]
            pos_t = header[Symbol(string(all_vars[col-1], "_t"))]
            results[order, pos_t] = results[order, pos_b] / results[order, pos_bstd]
        end
    end
    if :aic in criteria
        results[order, header[:aic]] = 2 * results[order, header[:ncoef]] + results[order, header[:nobs]] * log(results[order, header[:sse]] / results[order, header[:nobs]])
    end
    if :aicc in criteria
        if :aic in criteria
            results[order, header[:aicc]] = results[order, header[:aic]] + (2(results[order, header[:ncoef]] + 1) * (results[order, header[:ncoef]] + 2)) / (results[order, header[:nobs]] - (results[order, header[:ncoef]] + 1) - 1)
        else
            aic = 2 * results[order, header[:ncoef]] + results[order, header[:nobs]] * log(results[order, header[:sse]] / results[order, header[:nobs]])
            results[order, header[:aicc]] = aic + (2(results[order, header[:ncoef]] + 1) * (results[order, header[:ncoef]] + 2)) / (results[order, header[:nobs]] - (results[order, header[:ncoef]] + 1) - 1)
        end
    end
    if :bic in criteria
        results[order, header[:bic]] =
            results[order, header[:nobs]] * log.(results[order, header[:rmse]]) + (results[order, header[:ncoef]] - 1) * log.(results[order, header[:nobs]]) + results[order, header[:nobs]] + results[order, header[:nobs]] * log(2π)
    end
    if :r2adj in criteria
        results[order, header[:r2adj]] = 1 - (1 - results[order, header[:r2]]) * ((results[order, header[:nobs]] - 1) / (results[order, header[:nobs]] - results[order, header[:ncoef]]))
    end
    results[order, header[:F]] = (results[order, header[:r2]] / (results[order, header[:ncoef]] - 1)) / ((1 - results[order, header[:r2]]) / (results[order, header[:nobs]] - results[order, header[:ncoef]]))
end


"""
Function ols for ordinary least squares regression.
# Arguments
- y::Vector: the dependent variable.
- X::Matrix: the explanatory variables.
-  Method to be used for the estimation.
# Returns
- A tuple with the estimated coefficients and the residuals.
"""
@inline function ols(y, x, met)
    @inbounds @views begin
        if met == 'q'
            fact = qr(x)
            b = fact \ y
        elseif met == 'c'
            fact = cholesky(x' * x)
            b = fact \ (x' * y)
        else
            fact = svd(x)
            U, S, V = fact.U, fact.S, fact.V
            b = V * (Diagonal(1.0 ./ S) * (U' * y))
        end
        er = y - x * b
        return b, er, fact  # Early return with consistent 3 values
    end
end

@inline function ols_small(y, x, met)
    @inbounds @views begin
        # Ensure `x` is a 2D matrix
        if length(size(x)) == 1
            x = reshape(x, :, 1)  # Reshape to a column vector (matrix with one column)
        end
        
        if met == 'q'
            er = y - x * (qr(x) \ y)
        elseif met == 'c'
            chol = cholesky(x' * x)
            er = y - x * (chol \ (x' * y))
        else
            fact = svd(x)
            er = y - x * (fact.V * (Diagonal(1.0 ./ fact.S) * (fact.U' * y)))
        end
        return er
    end
end





"""
Function to compute standard deviation of coefficient 
to be used in ttest estimation
# Arguments
- fact: factorization of the matrix
- method: method to be used for the estimation
- sse: sum of squared errors
- df_e: degrees of freedom
- ncoef: number of coefficients
# Returns
- A vector with the standard deviation of the coefficients.
"""
function compute_beta_std(fact, met, sse, df_e, ncoef)
    if met == 'q'
        R_inv = UpperTriangular(fact.R) \ I(ncoef)
        diagvcov = sum(R_inv .^ 2, dims = 2) * (sse / df_e)
    elseif met == 'c'
        U_inv = UpperTriangular(fact.U) \ I(ncoef)
        diagvcov = sum(U_inv .^ 2, dims = 2) * (sse / df_e)
    else
        S_inv = Diagonal(1.0 ./ fact.S)
        diagvcov = diag(fact.V * S_inv^2 * fact.V' * (sse / df_e))
    end
    bstd = sqrt.(diagvcov)
    return bstd
end




"""
Converts a multiformat equation string to a list of variables and/or wildcards.
# Arguments
- `equation::String`: a multiformat (Stata, R, Julia, etc) equation string.
"""
function equation_str_to_strarr(equation::String)
	if occursin("~", equation)
		equation = replace(equation, r"\s+|\s+$/g" => " ")
		dep_indep = split(equation, "~")
		equation = [String(strip(ss)) for ss in vcat(dep_indep[1], split(dep_indep[2], "+"))]
	else
		equation = [String(strip(ss)) for ss in split(replace(equation, r"\s+|\s+$/g" => ","), ",")]
	end
	return equation
end

"""
Gets datanames from data structure and returns as a Vector.
# Arguments
- `data::Union{DataFrames.DataFrame, Array, Tuple}`: a DataFrame or an Array or a Tuple of a DataFrame or an Array.
- `datanames::Union{Nothing, Vector{String}, Vector{Symbol}}: an optional array of datanames.
"""
function get_datanames(data::Union{DataFrames.DataFrame, Array, Tuple}, datanames::Union{Nothing, Vector{String}, Vector{Symbol}})
	if isa(data, DataFrames.DataFrame)
		datanames = names(data)
	elseif isa(data, Tuple)
		datanames = data[2]
	elseif (datanames === nothing)
		error(DATANAMES_REQUIRED)
	end
	return datanames
end

"""
Converts a multiformat equation string array to a symbol array based on datanames.
# Arguments
- `equation::Vector{String}`: a DataFrame or a Tuple of a DataFrame.
- `datanames::Union{Vector{String}, Vector{Symbol}}`: a vector of stings and/or symbols.
"""
function equation_strarr_to_symarr(equation::Vector{String}, datanames::Union{Vector{String}, Vector{Symbol}})
	n_equation = []
	for e in equation
		e = replace(e, "." => "*")
		if e[end] == '*'
			datanames_arr = vec([String(key)[1:length(e[1:end-1])] == e[1:end-1] ? String(key) : nothing for key in datanames])
			append!(n_equation, filter!(x -> x !== nothing, datanames_arr))
		else
			append!(n_equation, [e])
		end
	end
	return map(Symbol, unique(n_equation))
end


"""
Converts string and/or symbol datanames array to symbol datanames set array.
# Arguments
- `datanames::Union{Vector{String}, Vector{Symbol}}`: an array of stings and/or symbols.
"""
function datanames_strarr_to_symarr!(datanames::Union{Vector{String}, Vector{Symbol}})
	dn = datanames
	datanames::Vector{Symbol} = []
	for name in dn
		push!(datanames, Symbol(name))
	end
	return datanames
end

"""
Gets DataFrame or Array from Tuple if is needed.
# Arguments
- `data::Union{DataFrames.DataFrame, Array, Tuple}`: a DataFrame or an Array or a Tuple of a DataFrame or an Array.
"""
function convert_if_is_tuple_to_array(data::Union{DataFrames.DataFrame, Array, Tuple})
	if isa(data, Tuple)
		data = data[1]
	end
	return data
end

"""
Sorts data based on time variable.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
- `time`: a time variable.
- `datanames::Vector{Symbol}`: an array of stings and/or symbols.
"""
function sort_data_by_time(data::Union{DataFrames.DataFrame, Array}, time::Symbol, datanames::Vector{Symbol})
	if isa(data, DataFrames.DataFrame)
		sort!(data, time)
	elseif isa(data, Array)
		pos = findfirst(isequal(time), datanames)
		data = gsregsortrows(data, [pos])
	end
	return data
end

"""
Sorts data based on panel_id and time variables.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
- `panel_id`: a panel identifier variable.
- `time`: a time variable.
- `datanames::Vector{Symbol}`: an array of stings and/or symbols.
"""
function sort_data_by_panel_and_time(data::Union{DataFrames.DataFrame, Array}, panel_id::Symbol, time::Symbol, datanames::Vector{Symbol})
    if isa(data, DataFrames.DataFrame)
        sort!(data, [panel_id, time])
    elseif isa(data, Array)
        panel_pos = findfirst(isequal(panel_id), datanames)
        time_pos = findfirst(isequal(time), datanames)
        data = gsregsortrows(data, [panel_pos, time_pos])
    end
    return data
end


"""
Sorts array data.
# Arguments
- TODO: Set arguments
"""
function gsregsortrows(B::AbstractMatrix, cols::Array; kws...)
	for i in 1:length(cols) # TODO: Refactor
		if i == 1
			p = sortperm(B[:, cols[i]]; kws...)
			B = B[p, :]
		else
			i0_old = 0
			i1_old = 0
			i0_new = 0
			i1_new = 0
			for j in 1:size(B, 1)-1
				if B[j, cols[1:i-1]] == B[j+1, cols[1:i-1]] && i0_old == i0_new
					i0_new = j
				elseif B[j, cols[1:i-1]] != B[j+1, cols[1:i-1]] && i0_old != i0_new && i1_new == i1_old
					i1_new = j
				elseif i0_old != i0_new && j == size(B, 1) - 1
					i1_new = j + 1
				end
				if i0_new != i0_old && i1_new != i1_old
					p = sortperm(B[i0_new:i1_new, cols[i]]; kws...)
					B[i0_new:i1_new, :] = B[i0_new:i1_new, :][p, :]
					i0_old = i0_new
					i1_old = i1_new
				end
			end
		end
	end
	return B
end

"""
Removes columns and keeps only selected variables ones.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
- `depvar::Symbol`: the dependent variable.
- `expvars::Vector{Symbol}`: the explanatory variables.
- `datanames::Vector{Symbol}`: an array of stings and/or symbols.
"""
function filter_data_valid_columns(data::Union{DataFrames.DataFrame, Array}, depvar::Symbol, expvars::Vector{Symbol}, datanames::Vector{Symbol}, panel_id::Union{Nothing, Symbol}, time::Union{Nothing, Symbol}, fixedvars::Union{Nothing, Vector{Symbol}})
    vars = panel_id === nothing ? vcat([depvar], expvars) : vcat([panel_id, time, depvar], expvars)
    vars = fixedvars !== nothing ? vcat(vars, fixedvars) : vars
    if isa(data, DataFrames.DataFrame)
        data = data[:, vars]
    elseif isa(data, Array)
        columns = []
        for var in vars
            append!(columns, get_data_column_pos(var, datanames))
        end
        data = data[:, columns]
    end
    return data
end


"""
Split data into two parts: one without the panel_id column and the other with only the panel_id column.
Assumes that the first column is the panel_id column if panel_id_sym is not nothing.
"""
function split_data(data::Union{DataFrames.DataFrame, Array})
    panel_id_column = collect(Int,data[:, 1])
    time_column = collect(Int,data[:, 2])
    data_without_panel_id_nor_time = data[:, 3:end]
    return data_without_panel_id_nor_time, panel_id_column, time_column
end

"""
Removes rows that has empty values.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
"""
function filter_rows_with_empty_values(data::Union{DataFrames.DataFrame, Array})
	if isa(data, DataFrames.DataFrame)
		data = data[completecases(data), :]
	elseif isa(data, Array{Union{Missing, Float64}, 2})
		for i in axes(data, 2)
			data = data[map(b -> !b, ismissing.(data[:, i])), :]
		end
	elseif isa(data, Array)
		for i in in
			axes(data, 2)
			data = data[data[:, i].!="", :]
		end
	end
	return data
end

"""
Converts DataFrame data to Matrix if is needed.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
"""
function convert_if_is_dataframe_to_array(data::Union{DataFrames.DataFrame, Array})
	if isa(data, DataFrames.DataFrame)
		data = Matrix{Float64}(data)
	end
	return data
end

"""
function within_transformation(data, depvar, expvars, panel_id)

Applies the within transformation to the dataset for fixed effects estimation.

# Arguments
- `data`: The dataset (Array).
- `depvar`: The dependent variable (String).
- `expvars`: The explanatory variables (Array of Strings).
- `panel_id`: The panel identifier variable (String).

# Returns
- Transformed dataset (Array).
"""
function within_transformation(data::Matrix{Float64}, panel_id_column::Vector{Int}, unique_ids::Vector{Int})
    transformed_data = similar(data)
    overall_means = mean(data, dims=1)
    for id in unique_ids
        rows = findall(x -> x == id, panel_id_column)
        group_means = mean(data[rows, :], dims=1)
        transformed_data[rows, :] .= data[rows, :] .- group_means .+ overall_means
    end
    return transformed_data
end

    function firstdiff_transformation(data::Matrix{Float64}, panel_id_column::Vector{Int})
        diff_data = diff(data, dims=1)
        change_indices = vcat(1, findall(diff(panel_id_column) .!= 0) .+ 1)
        mask = trues(size(diff_data, 1))
        mask[change_indices] .= false
        transformed_data = diff_data[mask, :]
        transformed_panel_id_column = panel_id_column[2:end][mask]
        return transformed_data, transformed_panel_id_column
    end

"""
Gets the position of a variable in datanames.
# Arguments
- `name::Symbol`: the variable name.
- `datanames::Union{Vector{String}, Vector{Symbol}}`: an array of stings and/or symbols.
"""
function get_data_column_pos(name::Symbol, datanames)
	return findfirst(x -> name == x, datanames)
end

"""
TODO: No tested or refactored
"""

"""
Returns the position of the header value based on this structure.
	- Index
	- Covariates
		* b
		* bstd
		* T-test
	- Equation general information merged with criteria user-defined options.
	- Order from user combined criteria
	- Weight
"""
function get_data_position(name, expvars, fixedvars, ttest, residualtests, time, criteria, paneltests)
    if fixedvars !== nothing
        all_vars = vcat(expvars, fixedvars)
    else
        all_vars = expvars
    end
	data_cols_num = length(all_vars)
	mult_col = (ttest == true) ? 3 : 1
	if name == INDEX
		return 1
	end
	displacement = 1
	displacement += mult_col * (data_cols_num) + 1
	testfields = (residualtests !== nothing && residualtests) ? ((time !== nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS) : []
    testfields = (paneltests !== nothing && paneltests) ? [testfields; :anovaftest; :bplmtest] : testfields
	equation_general_information_and_criteria = unique([EQUATION_GENERAL_INFORMATION; criteria; testfields])
	if name in equation_general_information_and_criteria
		return displacement + findfirst(isequal(name), equation_general_information_and_criteria) - 1
	end
	displacement += length(equation_general_information_and_criteria)
	if name == ORDER
		return displacement
	end
	displacement += 1
	if name == WEIGHT
		return displacement
	end
	displacement = 1
	string_name = string(name)
	base_name = Symbol(replace(replace(replace(string_name, "_bstd" => ""), "_t" => ""), "_b" => ""))
	if base_name in all_vars
		displacement = displacement + (findfirst(isequal(base_name), all_vars) - 1) * mult_col
		if occursin("_bstd", string_name)
			return displacement + 2
		end
		if occursin("_b", string_name)
			return displacement + 1
		end
		if occursin("_t", string_name)
			return displacement + 3
		end
	end
end

"""
Constructs the header for results based in get_data_position orders.
"""
function get_result_header(expvars, fixedvars, ttest, residualtests, time, criteria, modelavg, paneltests)
	header = Dict{Symbol, Int64}()
	header[:index] = get_data_position(:index, expvars, fixedvars, ttest, residualtests, time, criteria, paneltests)
    if fixedvars !== nothing
        all_vars = vcat(expvars, fixedvars)
    else 
        all_vars = expvars
    end
	for var in all_vars
		header[Symbol(string(var, "_b"))] = get_data_position(Symbol(string(var, "_b")), expvars, fixedvars, ttest, residualtests, time, criteria, paneltests)
		if ttest
			header[Symbol(string(var, "_bstd"))] = get_data_position(Symbol(string(var, "_bstd")), expvars, fixedvars, ttest, residualtests, time, criteria, paneltests)
			header[Symbol(string(var, "_t"))] = get_data_position(Symbol(string(var, "_t")), expvars, fixedvars, ttest, residualtests, time, criteria, paneltests)
		end
	end

	keys = unique([EQUATION_GENERAL_INFORMATION; criteria])
	if residualtests !== nothing && residualtests
		keys = unique([keys; (time !== nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS])
	end
	if paneltests !== nothing && paneltests
		keys = unique([keys; :anovaftest; :bplmtest])
	end

	for key in keys
		header[key] = get_data_position(key, expvars, fixedvars, ttest, residualtests, time, criteria, paneltests)
	end

	header[:order] = get_data_position(:order, expvars, fixedvars, ttest, residualtests, time, criteria, paneltests)
	if modelavg
		header[:weight] = get_data_position(:weight, expvars, fixedvars, ttest, residualtests, time, criteria, paneltests)
	end
	return header
end

function in_vector(sub_vector, vector)
	for sv in sub_vector
		if !in(sv, vector)
			return false
		end
	end
	return true
end

"""
Returns selected appropiate covariates for each iteration
"""
function get_selected_cols(i)
	cols = zeros(Int64, 0)
	binary = string(i, base = 2)
	k = 2
	for i in 1:length(binary)
		if binary[length(binary)-i+1] == '1'
			append!(cols, k)
		end
		k = k + 1
	end
	return cols
end

function export_csv(io::IO, obm_io::IO, result::GSRegResult)
    head = []
    for elem in sort(collect(Dict(value => key for (key, value) in result.header)))
        push!(head, elem[2])
    end
    writedlm(io, [head], ',')
    writedlm(io, result.results, ',')
    writedlm(obm_io, [head], ',')
    if size(result.results, 1) > 0
        writedlm(obm_io, result.results[result.bestmodelindex:result.bestmodelindex, :], ',')
    end
end

"""
Exports main results with headers to file and also creates a second file with _OBM suffix
"""
function export_csv(output::String, result::GSRegResult)
    file = open(output, "w")
    obm_output = replace(output, ".csv" => "_OBM.csv")
    obm_file = open(obm_output, "w")
    export_csv(file, obm_file, result)
    close(file)
    close(obm_file)
end

function all_ids_have_at_least_outsample(panel_id_column, outsample, id_count)::Bool
    id_counts = zeros(Int, id_count)
    reduce((counts, id) -> begin
        counts[id] += 1
        return counts
    end, panel_id_column, init=id_counts)
    return all(count >= (outsample + 2) for count in id_counts) # +2 because of the first difference
end

# Function to get in-sample and out-sample data using boolean masks
function in_sample_mask_func(panel_id_column::Union{Nothing, Vector{Int}}, id_count::Union{Nothing, Vector{Int}}, outsample::Int, nobsmask::Int)::BitVector
    bool_vector = trues(nobsmask)
    if panel_id_column === nothing
        bool_vector[end-outsample:end] .= false
        return bool_vector
    elseif !all_ids_have_at_least_outsample(panel_id_column, outsample, id_count)
        error("Not all ids have at least $(outsample + 2) observations.")
    end
    current_id = panel_id_column[end]
    count = 0
    for i in reverse(1:nobsmask)
        id = panel_id_column[i]  
        if id == current_id
            count += 1
        else
            current_id = id
            count = 1
        end
        if count <= outsample
            bool_vector[i] = false
        end
    end
    return bool_vector
end

# Helper functions for validation and preprocessing
function validate_parameters(estimator, equation, panel_id, data, datanames, time, criteria, outsample, parallel, paneltests, expvars, fixedvars)
    if (equation == "") || (data === nothing)
        error(EQUATION_OR_DATA_NOT_DEFINED)
    end
    if !in_vector(equation, datanames)
        error(SELECTED_VARIABLES_DOES_NOT_EXISTS)
    end
    if outsample == false && :rmseout in criteria
        error(OUTSAMPLE_MISMATCH)
    end
    if (panel_id !== nothing && estimator != "ols_fe") || (paneltests == true && estimator != "ols_fe") || (estimator == "ols_fe" && panel_id === nothing)
        error(WRONG_ESTIMATOR)
    end
    if panel_id !== nothing && time === nothing
        error(REQUIRED_TIME_VARIABLE)
    end
    if estimator ∉ AVAILABLE_ESTIMATORS
        error(INVALID_ESTIMATOR)
    end
    if parallel !== nothing
        if parallel > nworkers()
            error(INVALID_NUMBER_OF_WORKERS)
        elseif parallel < 1
            error(INVALID_NUMBER_OF_WORKERS)
        end
    end 
    if outsample != OUTSAMPLE_DEFAULT
        if outsample < 0
            error(OUTSAMPLE_LOWER_VALUE)
        elseif size(data, 1) - outsample < INSAMPLE_MIN_SIZE + size(data, 2) - 1
            error(OUTSAMPLE_HIGHER_VALUE)
        end
    end
    if panel_id !== nothing && panel_id ∉ datanames
        error(PANEL_ID_INEXISTENT)
    end
    if time !== nothing && time ∉ datanames
        error(TIME_VARIABLE_INEXISTENT)
    end
    if fixedvars !== nothing && !in_vector(fixedvars, datanames)
        error(SELECTED_FIXED_VARIABLES_DOES_NOT_EXISTS)
    end
    if fixedvars !== nothing && in_vector([fixedvars], expvars)
        error(SELECTED_FIXED_VARIABLES_IN_EQUATION)
    end
end

function preprocess_data(data, depvar, expvars, datanames, time, panel_id, paneltests, outsample, residualtests, fixedvars)
    panel_id_column=nothing
    panel_id_columndiff=nothing
    id_count=nothing
    SSB=nothing
    datadiff=nothing
    unique_ids=nothing
    unique_times=nothing
    time_column=nothing
    if  panel_id !== nothing
        panel_id = Symbol(panel_id)
        time = Symbol(time)
        data = sort_data_by_panel_and_time(data, panel_id, time, datanames)
    else
        if  time !== nothing
            time = Symbol(time)
            data = sort_data_by_time(data, time, datanames)
        end
    end
    data = filter_data_valid_columns(data, depvar, expvars, datanames, panel_id, time, fixedvars)
    data = filter_rows_with_empty_values(data)
    data = convert_if_is_dataframe_to_array(data)
    in_sample_maskdiff=nothing
    if panel_id !== nothing
        data, panel_id_column, time_column = split_data(data)
        unique_ids = unique(panel_id_column)
        unique_times = unique(time_column)
        id_count = length(unique_ids)
        if paneltests !== nothing && paneltests
            y = data[:, 1]
            overall_mean = mean(y)
            SSB = sum((sum(panel_id_column .== id) * (mean(y[panel_id_column .== id]) - overall_mean)^2 for id in unique_ids))
        end
        if residualtests !==nothing && residualtests
            datadiff, panel_id_columndiff = firstdiff_transformation(data, panel_id_column)
            in_sample_maskdiff = trues(size(datadiff, 1))
        end
        data = within_transformation(data, panel_id_column, unique_ids)
    end
    in_sample_mask = trues(size(data, 1))
    if outsample != OUTSAMPLE_DEFAULT
        if panel_id === nothing
            in_sample_mask = in_sample_mask_func(nothing, nothing, outsample, size(data, 1))
        else
            if paneltests !== nothing && paneltests
                in_sample_mask = in_sample_mask_func(panel_id_column, id_count, outsample, size(data, 1))
                in_sample_maskdiff = in_sample_mask_func(panel_id_columndiff, id_count, outsample, size(datadiff, 1))
                panel_id_column_filtered = panel_id_column[in_sample_mask]
                y_filtered = y[in_sample_mask]
                overall_mean = mean(y_filtered)  # This line has been moved
                SSB = sum((sum(panel_id_column_filtered .== id) * 
                            (mean(y_filtered[panel_id_column_filtered .== id]) - overall_mean)^2 
                            for id in unique_ids))  # This line has been moved
            else
                in_sample_mask = in_sample_mask_func(panel_id_column, id_count, outsample, size(data, 1))
            end
        end
    end             
    fixedvars_colnum=nothing
    if fixedvars !== nothing
        fixedvars_colnum = Int[]
        lfixedvars = length(fixedvars)
        lexpvars = length(expvars)
        for i in (lexpvars+2):(lexpvars+lfixedvars+1) # +2 because of the dependent variable and the additional step for the first fixed variable
            push!(fixedvars_colnum, i)
        end
    end
    return data, datadiff, panel_id_column, id_count, SSB, in_sample_mask, in_sample_maskdiff, unique_ids, unique_times, time_column, fixedvars_colnum
end

function finalize_data(data, equation, datanames, expvars)
    expvars_data = data[:, 2:end]
    corrmatrix = cor(expvars_data)
    s = size(corrmatrix, 1)
    corrminusiden = corrmatrix - Matrix{Float64}(I, s, s)
    maxcorr = maximum(corrminusiden)
    if maxcorr > 0.999
        error(NON_LINEARLY_INDEPENDENT_EXPVARS)
    end
end

function select_criteria(criteria, outsample)
    if criteria == CRITERIA_DEFAULT
        if outsample != OUTSAMPLE_DEFAULT
            return CRITERIA_DEFAULT_OUTSAMPLE
        else
            return CRITERIA_DEFAULT_INSAMPLE
        end
    end
    return criteria
end

"""
# function select_datatype(method::String)::DataType
"""
function select_datatype(method::String)::DataType
    if method == SVD_64 || method == QR_64 || method == CHO_64
        return Float64
    elseif method == SVD_32 || method == QR_32 || method == CHO_32
        return Float32
    elseif method == SVD_16 || method == QR_16 || method == CHO_16
        return Float16
    else
        error(METHOD_INVALID)
    end
end

"""
Reduce functions for panel data heteroskedasticity tests
"""
function aggregate_sums_counts(acc, x)
    id, value = x
    acc[id] += value
    return acc
end

function extract_last_observation(acc, x, vec)
    id, idx = x
    acc[id] = vec[idx]
    return acc
end