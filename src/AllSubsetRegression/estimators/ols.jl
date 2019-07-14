function ols(
        data::GlobalSearchRegression.GSRegData;
        fixedvariables::Array=FIXEDVARIABLES_DEFAULT,
        outsample=OUTSAMPLE_DEFAULT,
        criteria::Array=CRITERIA_DEFAULT,
        ttest::Bool=TTEST_DEFAULT,
        modelavg::Bool=MODELAVG_DEFAULT,
        residualtest::Bool=RESIDUALTEST_DEFAULT,
        orderresults::Bool=ORDERRESULTS_DEFAULT
    )

    return ols!(
        GlobalSearchRegression.copy_data(data),
        fixedvariables=fixedvariables,
        outsample=outsample,
        criteria=criteria,
        ttest=ttest,
        modelavg=modelavg,
        residualtest=residualtest,
        orderresults=orderresults
    )
end

function ols!(
    data::GlobalSearchRegression.GSRegData;
    fixedvariables::Array=FIXEDVARIABLES_DEFAULT,
    outsample=OUTSAMPLE_DEFAULT,
    criteria::Array=CRITERIA_DEFAULT,
    ttest::Bool=TTEST_DEFAULT,
    modelavg::Bool=MODELAVG_DEFAULT,
    residualtest::Bool=RESIDUALTEST_DEFAULT,
    orderresults::Bool=ORDERRESULTS_DEFAULT
)

    result = create_result(data, fixedvariables, outsample, criteria, ttest, modelavg, residualtest, orderresults)
    execute!(data, result)
    GlobalSearchRegression.addresult!(data, result)
    data = addextras(data, result)

    return data
end

function execute!(data::GlobalSearchRegression.GSRegData, result::AllSubsetRegressionResult)
    if !data.removemissings
        data = GlobalSearchRegression.filter_data_by_empty_values(data)
    end

    expvars_num = size(data.expvars, 1)
    if data.intercept
        expvars_num = expvars_num - 1
    end
    num_operations = 2 ^ expvars_num - 1

    depvar_data = convert(SharedArray, data.depvar_data)
    expvars_data = convert(SharedArray, data.expvars_data)
    result_data = fill!(SharedArray{data.datatype}(num_operations, size(result.datanames, 1)), NaN)
    datanames_index = GlobalSearchRegression.create_datanames_index(result.datanames)
    if nprocs() == nworkers()
        for order = 1:num_operations
            execute_row!(order, data.depvar, data.expvars, datanames_index, depvar_data, expvars_data, result_data, data.intercept, data.time, data.datatype, result.outsample, result.criteria, result.ttest, result.residualtest, result.fixedvariables)
        end
    else
        ops_per_worker = div(num_operations, nworkers())
        if (nworkers() > num_operations)
            num_jobs = num_operations
        else
            num_jobs = nworkers()
        end
        jobs = []
        for num_job = 1:num_jobs
            push!(jobs, @spawnat num_job+1 execute_job!(num_job, num_jobs, ops_per_worker, data.depvar, data.expvars, datanames_index, depvar_data, expvars_data, result_data, data.intercept, data.time, data.datatype, result.outsample, result.criteria, result.ttest, result.residualtest, result.fixedvariables))
        end
        for job in jobs
            fetch(job)
        end

        remainder = num_operations - ops_per_worker * num_jobs
        if remainder > 0
            for j = 1:remainder
                order = j + ops_per_worker * num_jobs
                execute_row!(order, data.depvar, data.expvars, datanames_index, depvar_data, expvars_data, result_data, data.intercept, data.time, data.datatype, result.outsample, result.criteria, result.ttest, result.residualtest, result.fixedvariables)
            end
        end
    end

    result.data = Array(result_data)
    
    if :cp in result.criteria
        result.data[ :, datanames_index[:cp] ] = (result.data[ :, datanames_index[:nobs] ] .- maximum(result.data[ :, datanames_index[:ncoef] ]) .- 2) .* (result.data[ :,datanames_index[:rmse] ] ./ minimum(result.data[ :,datanames_index[:rmse] ])) .- (result.data[ :,datanames_index[:nobs] ] .- 2 .* result.data[ :,datanames_index[:ncoef] ])
    end

    len_criteria = length(result.criteria)
    for criteria in result.criteria
        result.data[ :,datanames_index[:order] ] += AVAILABLE_CRITERIA[criteria]["index"] * (1 / len_criteria) * ( (result.data[ :,datanames_index[criteria] ] .- mean(result.data[ :,datanames_index[criteria] ]) ) ./ std(result.data[ :,datanames_index[criteria] ]) )
    end
    
    if result.modelavg
        delta = maximum(result.data[:, datanames_index[:order]]) .- result.data[:, datanames_index[:order]]
        w1 = exp.(-delta/2)
        result.data[:, datanames_index[:weight]] = w1./sum(w1)
        result.modelavg_data = Vector{Float64}(undef, size(result.datanames))
        weight_pos = (result.ttest) ? 4 : 2
        for expvar in data.expvars
            obs = result.data[:,datanames_index[Symbol(string(expvar, "_b"))]]
            if result.ttest
                obs = hcat(obs, result.data[:, datanames_index[Symbol(string(expvar, "_bstd"))]])
                obs = hcat(obs, result.data[:, datanames_index[Symbol(string(expvar, "_t"))]])
            end
            obs = hcat(obs, result.data[:, datanames_index[:weight]])

            obs = obs[findall(x -> !isnan(obs[x,1]), 1:size(obs,1)),:]
            obs[:, weight_pos] /= sum(obs[:, weight_pos])

            result.modelavg_data[datanames_index[Symbol(string(expvar, "_b"))]] = sum(obs[:, 1] .* obs[:, weight_pos])
            if result.ttest
                result.modelavg_data[datanames_index[Symbol(string(expvar, "_bstd"))]] = sum(obs[:, 2] .* obs[:, weight_pos])
                result.modelavg_data[datanames_index[Symbol(string(expvar, "_t"))]] = sum(obs[:, 3] .* obs[:, weight_pos])
            end
        end

        for criteria in [:nobs, :r2adj, :F, :order]
            result.modelavg_data[datanames_index[criteria]] = sum(result.data[:, datanames_index[criteria]] .* result.data[:, datanames_index[:weight]])
        end
    end

    if result.orderresults
        result.data = sortrows(result.data, [datanames_index[:order]]; rev=true)
        result.bestresult_data = result.data[1, :]
    else
        max_order = result.data[1, datanames_index[:order]]
        best_result_index = 1
        for i = 1:num_operations
            if result.data[i, datanames_index[:order]] > max_order
                max_order = result.data[i, datanames_index[:order]]
                best_result_index = i
            end
        end
        result.bestresult_data = result.data[best_result_index, :]
    end

    return result
end

function execute_job!(
    num_job,
    num_jobs,
    ops_per_worker,
    depvar,
    expvars,
    datanames_index,
    depvar_data,
    expvars_data,
    result_data,
    intercept,
    time,
    datatype,
    outsample,
    criteria,
    ttest,
    residualtest,
    fixedvariables
)
    @time begin

    for j = 1:ops_per_worker
        order = (j-1) * num_jobs + num_job
        execute_row!(
            order,
            depvar,
            expvars,
            datanames_index,
            depvar_data,
            expvars_data,
            result_data,
            intercept,
            time,
            datatype,
            outsample,
            criteria,
            ttest,
            residualtest,
            fixedvariables,
            num_jobs=num_jobs,
            num_job=num_job,
            iteration_num=j
        )
    end
    end
end

function execute_row!(
    order,
    depvar,
    expvars,
    datanames_index,
    depvar_data,
    expvars_data,
    result_data,
    intercept,
    time,
    datatype,
    outsample,
    criteria,
    ttest,
    residualtest,
    fixedvariables;
    num_jobs=nothing,
    num_job=nothing,
    iteration_num=nothing
)
    selected_variables_index = get_selected_variables(order, expvars, intercept, fixedvariables=fixedvariables, num_jobs=num_jobs, num_job=num_job, iteration_num=iteration_num)    

    depvar_subset, expvars_subset = get_insample_subset(depvar_data, expvars_data, outsample, selected_variables_index)
    outsample_enabled = size(depvar_subset, 1) < size(depvar_data, 1)

    nobs = size(depvar_subset, 1)
    ncoef = size(expvars_subset, 2)
    qrf = qr(expvars_subset)
    b = qrf \ depvar_subset               # estimate
    ŷ = expvars_subset * b                # predicted values
    er = depvar_subset - ŷ                # in-sample residuals
    er2 = er .^ 2                         # squared errors
    sse = sum(er2)                        # residual sum of squares
    df_e = nobs - ncoef                   # degrees of freedom
    rmse = sqrt(sse / nobs)               # root mean squared error
    r2 = 1 - var(er) / var(depvar_subset) # model R-squared

    if ttest
        bstd = sqrt.( sum( (UpperTriangular(qrf.R) \ Matrix(1.0LinearAlgebra.I, ncoef, ncoef) ) .^ 2, dims=2) * (sse / df_e) )
    end

    if outsample_enabled > 0
        depvar_outsample_subset, expvars_outsample_subset = get_outsample_subset(depvar_data, expvars_data, outsample, selected_variables_index)
        erout = depvar_outsample_subset - expvars_outsample_subset * b  # out-of-sample residuals
        sseout = sum(erout .^ 2)                                        # residual sum of squares
        outsample_count = outsample
        if (isa(outsample, Array))
            outsample_count = size(outsample, 1)
        end
        rmseout = sqrt(sseout / outsample_count)                        # root mean squared error
        result_data[ order, datanames_index[:rmseout] ] = rmseout
    end

    result_data[ order, datanames_index[:index] ] = order
    for (index, selected_variable_index) in enumerate(selected_variables_index)
        result_data[ order, datanames_index[Symbol(string(expvars[selected_variable_index], "_b"))] ] = datatype(b[index])
        if ttest
            result_data[ order, datanames_index[Symbol(string(expvars[selected_variable_index], "_bstd"))] ] = datatype(bstd[index])
            result_data[ order, datanames_index[Symbol(string(expvars[selected_variable_index], "_t"))] ] = result_data[order, datanames_index[Symbol(string(expvars[selected_variable_index], "_b"))]] / result_data[order, datanames_index[Symbol(string(expvars[selected_variable_index], "_bstd"))]]
        end
    end

    result_data[ order, datanames_index[:nobs] ] = nobs
    result_data[ order, datanames_index[:ncoef] ] = ncoef
    result_data[ order, datanames_index[:sse] ] = datatype(sse)
    result_data[ order, datanames_index[:r2 ] ] = datatype(r2)
    result_data[ order, datanames_index[:rmse] ] = datatype(rmse)
    result_data[ order, datanames_index[:order] ] = 0

    if :aic in criteria || :aicc in criteria
        aic = 2 * result_data[ order, datanames_index[:ncoef] ] + result_data[ order, datanames_index[:nobs] ] * log(result_data[ order, datanames_index[:sse] ] / result_data[ order, datanames_index[:nobs] ])
    end

    if :aic in criteria
        result_data[ order, datanames_index[:aic] ] = aic
    end

    if :aicc in criteria
        result_data[ order, datanames_index[:aicc] ] = aic + (2(result_data[ order, datanames_index[:ncoef] ] + 1) * (result_data[ order, datanames_index[:ncoef] ] + 2)) / (result_data[ order, datanames_index[:nobs] ] - (result_data[ order, datanames_index[:ncoef] ] + 1 ) - 1)
    end

    if :bic in criteria
        result_data[ order, datanames_index[:bic] ] = result_data[ order, datanames_index[:nobs] ] * log.(result_data[ order, datanames_index[:rmse] ]) + ( result_data[ order, datanames_index[:ncoef] ] - 1 ) * log.(result_data[ order, datanames_index[:nobs] ]) + result_data[ order, datanames_index[:nobs] ] + result_data[ order, datanames_index[:nobs] ] * log(2π)
    end

    if :r2adj in criteria
        result_data[ order, datanames_index[:r2adj] ] = 1 - (1 - result_data[ order, datanames_index[:r2] ]) * ((result_data[ order, datanames_index[:nobs] ] - 1) / (result_data[ order, datanames_index[:nobs] ] - result_data[ order, datanames_index[:ncoef] ]))
    end

    result_data[ order, datanames_index[:F] ] = (result_data[ order, datanames_index[:r2] ] / (result_data[ order, datanames_index[:ncoef] ] - 1)) / ((1 - result_data[ order, datanames_index[:r2] ]) / (result_data[ order, datanames_index[:nobs] ] - result_data[ order, datanames_index[:ncoef] ]))

    if residualtest
        x = er
        n = length(x)
        m1 = sum(x) / n
        m2 = sum((x .- m1) .^ 2) / n
        m3 = sum((x .- m1) .^ 3) / n
        m4 = sum((x .- m1) .^ 4) / n
        b1 = (m3 / m2 ^ (3 / 2)) ^ 2
        b2 = (m4 / m2 ^ 2)
        statistic = n * b1 / 6 + n * (b2 - 3) ^ 2 / 24
        d = Chisq(2.)
        jbtest = 1 .- cdf(d, statistic)

        regmatw = hcat((ŷ .^ 2), ŷ , ones(size(ŷ, 1)))
        qrfw = qr(regmatw)
        regcoeffw = qrfw \ er2
        residw = er2 - regmatw * regcoeffw
        rsqw = 1 - dot(residw, residw) / dot(er2, er2) # uncentered R^2
        statisticw = n * rsqw
        wtest = ccdf(Chisq(2), statisticw)

        result_data[ order, datanames_index[:wtest] ] = wtest
        result_data[ order, datanames_index[:jbtest] ] = jbtest
        if time != nothing
            e = er
            lag = 1
            xmat = expvars_subset

            n = size(e,1)
            elag = zeros(Float64,n,lag)
            for ii = 1:lag
                elag[ii+1:end, ii] = e[1:end-ii]
            end

            offset = lag
            regmatbg = [xmat[offset+1:end,:] elag[offset+1:end,:]]
            qrfbg = qr(regmatbg)
            regcoeffbg = qrfbg \ e[offset+1:end]
            residbg = e[offset+1:end] .- regmatbg * regcoeffbg
            rsqbg = 1 - dot(residbg,residbg) / dot(e[offset+1:end], e[offset+1:end]) # uncentered R^2
            statisticbg = (n - offset) * rsqbg
            bgtest = ccdf(Chisq(lag), statisticbg)
            result_data[ order, datanames_index[:bgtest] ] = bgtest
        end
    end
    
end
