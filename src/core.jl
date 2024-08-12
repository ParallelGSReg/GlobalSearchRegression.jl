function gsreg(
    depvar::Symbol,
    expvars::Vector{Symbol},
    data::Union{Matrix{Float64},Matrix{Float32},Matrix{Float16}};
    intercept = nothing,
    outsample = nothing,
    criteria = nothing,
    ttest = nothing,
    method = nothing,
    estimator = nothing, 
    modelavg = nothing,
    residualtests = nothing,
    time = nothing,
    panel_id = nothing, 
    summary = nothing,
    datanames = nothing,
    datatype = nothing,
    orderresults = nothing,
    onmessage = nothing,
    parallel = nothing,
    paneltests = nothing,
    id_count =nothing,
    SSB = nothing,
    bestmodelindex=nothing,
    panel_id_column = nothing,
    datadiff = nothing,
    in_sample_mask=nothing,
    in_sample_maskdiff=nothing,
    unique_ids=nothing,
    unique_times=nothing,
    time_column=nothing,
    fixedvars = nothing,
    fixedvars_colnum = nothing,
)
    result = GSRegResult(
        depvar,
        expvars,
        data,
        intercept,
        outsample,
        criteria,
        ttest,
        method,
        estimator,
        modelavg,
        residualtests,
        time,
        panel_id,
        datanames,
        datatype,
        orderresults,
        onmessage,
        parallel,
        paneltests,
        id_count,
        SSB,
        bestmodelindex,
        panel_id_column,
        datadiff,
        in_sample_mask,
        in_sample_maskdiff,
        unique_ids,
        unique_times,
        time_column,
        fixedvars,
        fixedvars_colnum,
    )
    proc!(result)
    if summary !== nothing
        f = open(summary, "w")
        write(f, to_string(result))
        close(f)
    end
    return result
end

# MAIN CORE FUNCTION TO PERFORM REGRESSIONS (USING MULTIPLE DISPATCH)
# (V1) RESIDUALTESTS AND PANELTESTS !== NOTHING
@inline function gsreg_single_proc_result!(
    order,
    data,
    results,
    expvars,
    intercept,
    outsample,
    criteria,
    ttest,
    #method,
    residualtests::Bool,
    time,
    panel_id,
    datatype,
    header,
    paneltests::Bool,
    id_count,
    SSB,
    panel_id_column,
    datadiff,
    in_sample_mask,
    in_sample_maskdiff,
    unique_ids,
    unique_times,
    time_column,
    fixedvars,
    fixedvars_colnum,
    met,
    )

    depvar_data, expvars_data, nobs, 
    ncoef, panel_id_column, 
    depvar_out, expvars_out, cols   =   @inline GSPR_data_preparation(
                                        order, data, fixedvars, fixedvars_colnum, 
                                        intercept, in_sample_mask, panel_id, panel_id_column,
                                        outsample
                                        )

    b, er, er2, sse, var_er, rmse, 
    r2, bstd, rmseout               =   @inline GSPR_main_estimation_block(
                                        depvar_data, expvars_data, depvar_out, expvars_out, 
                                        nobs, ncoef, met, ttest, outsample
                                        ) 
    
    jbtest, wtest, panelwtest, 
    bgtest, wootest                 =   @inline GSPR_residual_tests(
                                        residualtests, panel_id, cols, intercept, in_sample_maskdiff, 
                                        datadiff, er, expvars_data, b, er2, met, nobs, id_count, 
                                        panel_id_column,var_er, time
                                        )

    anovastatistic, bplm            =   @inline GSPR_panel_tests(
                                        paneltests, SSB, id_count, sse, nobs, ncoef, unique_times, 
                                        unique_ids, er, time_column, panel_id_column
                                        )
    
    
@inline GSPR_store_results!(results, outsample, ttest, residualtests, panel_id, time, paneltests, 
                            criteria, order, rmseout, expvars, fixedvars, cols, b, bstd, nobs, 
                            ncoef, sse, r2, rmse, jbtest, wtest, panelwtest, bgtest, wootest, 
                            anovastatistic, bplm, header, datatype
                            )
   
end

# (V2) RESIDUALTESTS === NOTHING AND PANELTESTS:: BOOL
@inline function gsreg_single_proc_result!(
    order,
    data,
    results,
    expvars,
    intercept,
    outsample,
    criteria,
    ttest,
    #method,
    residualtests::Nothing,
    time,
    panel_id,
    datatype,
    header,
    paneltests::Bool,
    id_count,
    SSB,
    panel_id_column,
    datadiff,
    in_sample_mask,
    in_sample_maskdiff,
    unique_ids,
    unique_times,
    time_column,
    fixedvars,
    fixedvars_colnum,
    met,
    )

    depvar_data, expvars_data, nobs, 
    ncoef, panel_id_column, 
    depvar_out, expvars_out, cols   =   @inline GSPR_data_preparation(
                                        order, data, fixedvars, fixedvars_colnum, 
                                        intercept, in_sample_mask, panel_id, panel_id_column,
                                        outsample
                                        )

    b, er, er2, sse, var_er, rmse, 
    r2, bstd, rmseout               =   @inline GSPR_main_estimation_block(
                                        depvar_data, expvars_data, depvar_out, expvars_out, 
                                        nobs, ncoef, met, ttest, outsample
                                        ) 
    
    jbtest, wtest, panelwtest, 
    bgtest, wootest                 =   nothing, nothing, nothing, nothing, nothing

    anovastatistic, bplm            =   @inline GSPR_panel_tests(
                                        paneltests, SSB, id_count, sse, nobs, ncoef, unique_times, 
                                        unique_ids, er, time_column, panel_id_column
                                        )
    
    
@inline GSPR_store_results!(results, outsample, ttest, residualtests, panel_id, time, paneltests, 
                            criteria, order, rmseout, expvars, fixedvars, cols, b, bstd, nobs, 
                            ncoef, sse, r2, rmse, jbtest, wtest, panelwtest, bgtest, wootest, 
                            anovastatistic, bplm, header, datatype
                            )
   
end

# (V3) RESIDUALTESTS::BOOL && NOTHING AND PANELTESTS === NOTHING
@inline function gsreg_single_proc_result!(
    order,
    data,
    results,
    expvars,
    intercept,
    outsample,
    criteria,
    ttest,
    #method,
    residualtests::Bool,
    time,
    panel_id,
    datatype,
    header,
    paneltests::Nothing,
    id_count,
    SSB,
    panel_id_column,
    datadiff,
    in_sample_mask,
    in_sample_maskdiff,
    unique_ids,
    unique_times,
    time_column,
    fixedvars,
    fixedvars_colnum,
    met,
    )

    depvar_data, expvars_data, nobs, 
    ncoef, panel_id_column, 
    depvar_out, expvars_out, cols   =   @inline GSPR_data_preparation(
                                        order, data, fixedvars, fixedvars_colnum, 
                                        intercept, in_sample_mask, panel_id, panel_id_column,
                                        outsample
                                        )

    b, er, er2, sse, var_er, rmse, 
    r2, bstd, rmseout               =   @inline GSPR_main_estimation_block(
                                        depvar_data, expvars_data, depvar_out, expvars_out, 
                                        nobs, ncoef, met, ttest, outsample
                                        ) 
    
    jbtest, wtest, panelwtest, 
    bgtest, wootest                 =   @inline GSPR_residual_tests(
                                        residualtests, panel_id, cols, intercept, in_sample_maskdiff, 
                                        datadiff, er, expvars_data, b, er2, met, nobs, id_count, 
                                        panel_id_column,var_er, time
                                        )

    anovastatistic, bplm            =   nothing, nothing
    
    
@inline GSPR_store_results!(results, outsample, ttest, residualtests, panel_id, time, paneltests, 
                            criteria, order, rmseout, expvars, fixedvars, cols, b, bstd, nobs, 
                            ncoef, sse, r2, rmse, jbtest, wtest, panelwtest, bgtest, wootest, 
                            anovastatistic, bplm, header, datatype
                            )
   
end

# (V4) RESIDUALTESTS AND PANELTESTS === NOTHING
@inline function gsreg_single_proc_result!(
    order,
    data,
    results,
    expvars,
    intercept,
    outsample,
    criteria,
    ttest,
    #method,
    residualtests::Nothing,
    time,
    panel_id,
    datatype,
    header,
    paneltests::Nothing,
    id_count,
    SSB,
    panel_id_column,
    datadiff,
    in_sample_mask,
    in_sample_maskdiff,
    unique_ids,
    unique_times,
    time_column,
    fixedvars,
    fixedvars_colnum,
    met,
    )

    depvar_data, expvars_data, nobs, 
    ncoef, panel_id_column, 
    depvar_out, expvars_out, cols   =   @inline GSPR_data_preparation(
                                        order, data, fixedvars, fixedvars_colnum, 
                                        intercept, in_sample_mask, panel_id, panel_id_column,
                                        outsample
                                        )

    b, er, er2, sse, var_er, rmse, 
    r2, bstd, rmseout               =   @inline GSPR_main_estimation_block(
                                        depvar_data, expvars_data, depvar_out, expvars_out, 
                                        nobs, ncoef, met, ttest, outsample
                                        ) 
    
    jbtest, wtest, panelwtest, 
    bgtest, wootest                 =   nothing, nothing, nothing, nothing, nothing

    anovastatistic, bplm            =   nothing, nothing
    
    
@inline GSPR_store_results!(results, outsample, ttest, residualtests, panel_id, time, paneltests, 
                            criteria, order, rmseout, expvars, fixedvars, cols, b, bstd, nobs, 
                            ncoef, sse, r2, rmse, jbtest, wtest, panelwtest, bgtest, wootest, 
                            anovastatistic, bplm, header, datatype
                            )
   
end

@inline function gsreg_proc_result!(
    num_job,
    num_jobs, 
    ops_by_worker, 
    opts...)
    @inbounds @simd for j in 1:ops_by_worker
        order = (j - 1) * num_jobs + num_job
        gsreg_single_proc_result!(order, opts...)
    end
end

function proc!(result::GSRegResult)
    expvars_num = size(result.expvars, 1)
    num_operations = 2^expvars_num - 1
    result.onmessage("Creating environment")
    pdata = convert(SharedArray, result.data)
    presults = fill!(SharedArray{result.datatype}(num_operations, length(keys(result.header))), NaN)
    met = result.method[1]
    result.onmessage("Doing $num_operations regressions")
    if nprocs() == nworkers()
        @inbounds @simd for order in 1:num_operations
            gsreg_single_proc_result!(
                order,
                pdata,
                presults,
                result.expvars,
                result.intercept,
                result.outsample,
                result.criteria,
                result.ttest,
                #result.method,
                result.residualtests,
                result.time,
                result.panel_id,
                result.datatype,
                result.header,
                result.paneltests,
                result.id_count,
                result.SSB,
                result.panel_id_column,
                result.datadiff,
                result.in_sample_mask,
                result.in_sample_maskdiff,
                result.unique_ids,
                result.unique_times,
                result.time_column,
                result.fixedvars,
                result.fixedvars_colnum,
                met,
            )
        end
    else
        num_workers = (result.parallel !== nothing) ? result.parallel : nworkers()
        ops_by_worker = div(num_operations, num_workers)
        num_jobs = (num_workers > num_operations) ? num_operations : num_workers
        remainder = num_operations - ops_by_worker * num_jobs
        jobs = []
        @inbounds @simd for num_job in 1:num_jobs
            push!(
                jobs,
                @spawnat num_job + 1 gsreg_proc_result!(
                    num_job,
                    num_jobs,
                    ops_by_worker,
                    pdata,
                    presults,
                    result.expvars,
                    result.intercept,
                    result.outsample,
                    result.criteria,
                    result.ttest,
                    #result.method,
                    result.residualtests,
                    result.time,
                    result.panel_id,
                    result.datatype,
                    result.header,
                    result.paneltests,
                    result.id_count,
                    result.SSB,
                    result.panel_id_column, 
                    result.datadiff,
                    result.in_sample_mask,
                    result.in_sample_maskdiff,
                    result.unique_ids,
                    result.unique_times,
                    result.time_column,
                    result.fixedvars,
                    result.fixedvars_colnum,
                    met,
                )
            )
        end
        @inbounds @simd for job in jobs
            fetch(job)
        end
        if (remainder > 0)
            @inbounds @simd for j in 1:remainder
                order = j + ops_by_worker * num_jobs
                gsreg_single_proc_result!(
                    order,
                    pdata,
                    presults,
                    result.expvars,
                    result.intercept,
                    result.outsample,
                    result.criteria,
                    result.ttest,
                    #result.method,
                    result.residualtests,
                    result.time,
                    result.panel_id,
                    result.datatype,
                    result.header,
                    result.paneltests,
                    result.id_count,
                    result.SSB,
                    result.panel_id_column,
                    result.datadiff,
                    result.in_sample_mask,
                    result.in_sample_maskdiff,
                    result.unique_ids,
                    result.unique_times,
                    result.time_column,
                    result.fixedvars,
                    result.fixedvars_colnum,
                    met,
                )
            end
        end
    end
    result.results = Array(presults)
    presult = nothing
    pdata = nothing
    if :cp in result.criteria
        result.results[:, result.header[:cp]] =
            (result.results[:, result.header[:nobs]] .- maximum(result.results[:, result.header[:ncoef]]) .- 2) .* (result.results[:, result.header[:rmse]] ./ minimum(result.results[:, result.header[:rmse]])) .-
            (result.results[:, result.header[:nobs]] .- 2 .* result.results[:, result.header[:ncoef]])
    end
    len_criteria = length(result.criteria)
    @inbounds @simd for criteria in result.criteria
        result.results[:, result.header[:order]] +=
            AVAILABLE_CRITERIA[criteria]["index"] * (1 / len_criteria) * ((result.results[:, result.header[criteria]] .- mean(result.results[:, result.header[criteria]])) ./ std(result.results[:, result.header[criteria]]))
    end
    if result.modelavg
        result.onmessage("Generating model averaging results")
        delta = maximum(result.results[:, result.header[:order]]) .- result.results[:, result.header[:order]]
        w1 = exp.(-delta / 2)
        result.results[:, result.header[:weight]] = w1 ./ sum(w1)
        result.average = Array{Float64}(undef, 1, length(keys(result.header)))
        weight_pos = (result.ttest) ? 4 : 2
        
        all_vars = vcat(result.expvars, result.fixedvars)
        @inbounds @simd for var in all_vars
            obs = result.results[:, result.header[Symbol(string(var, "_b"))]]
            if result.ttest
                obs = hcat(obs, result.results[:, result.header[Symbol(string(var, "_bstd"))]])
                obs = hcat(obs, result.results[:, result.header[Symbol(string(var, "_t"))]])
            end
            obs = hcat(obs, result.results[:, result.header[:weight]])
            obs = obs[findall(x -> !isnan(obs[x, 1]), 1:size(obs, 1)), :]
            obs[:, weight_pos] /= sum(obs[:, weight_pos])
            result.average[result.header[Symbol(string(var, "_b"))]] = sum(obs[:, 1] .* obs[:, weight_pos])
            if result.ttest
                result.average[result.header[Symbol(string(var, "_bstd"))]] = sum(obs[:, 2] .* obs[:, weight_pos])
                result.average[result.header[Symbol(string(var, "_t"))]] = sum(obs[:, 3] .* obs[:, weight_pos])
            end
        end
        if result.paneltests !== nothing && result.paneltests
            statistics = [:nobs, :F, :order, :anovaftest, :bplmtest]
        else
            statistics = [:nobs, :F, :order]
        end
        @inbounds @simd for statistic in statistics
            result.average[result.header[statistic]] = sum(result.results[:, result.header[statistic]] .* result.results[:, result.header[:weight]])
        end
    end
    if result.orderresults
        result.onmessage("Sorting results")
        result.results = gsregsortrows(result.results, [result.header[:order]]; rev = true)
        result.bestresult = result.results[1, :]
        result.bestmodelindex = 1
    else
        result.onmessage("Looking for the best result")
        max_order = result.results[1, result.header[:order]]
        best_result_index = 1
        @inbounds @simd for i in 1:num_operations
            if result.results[i, result.header[:order]] > max_order
                max_order = result.results[i, result.header[:order]]
                best_result_index = i
            end
        end
        result.bestresult = result.results[best_result_index, :]
        result.bestmodelindex = best_result_index
    end
end

function to_string(result::GSRegResult)
    out = ""
    out *= @sprintf("\n")
    out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
    out *= @sprintf("                              Best model results                              \n")
    out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
    out *= @sprintf("                                                                              \n")
    out *= @sprintf("                                     Dependent variable: %s                   \n", result.depvar)
    out *= @sprintf("                                     ─────────────────────────────────────────\n")
    out *= @sprintf("                                                                              \n")
    out *= @sprintf(" Selected covariates                 Coef.")
    if result.ttest
        out *= @sprintf("        Std.         t-test")
    end
    out *= @sprintf("\n")
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    cols = get_selected_cols(Int64(result.bestresult[result.header[:index]]))
    if result.fixedvars !== nothing
        cols = append!(cols, result.fixedvars_colnum)
    end
    all_vars = vcat(result.expvars, result.fixedvars)
    for pos in cols
        varname = all_vars[pos-1]
        out *= @sprintf(" %-35s", varname)
        out *= @sprintf(" %-10f", result.bestresult[result.header[Symbol(string(varname, "_b"))]])
        if result.ttest
            out *= @sprintf("   %-10f", result.bestresult[result.header[Symbol(string(varname, "_bstd"))]])
            out *= @sprintf("   %-10f", result.bestresult[result.header[Symbol(string(varname, "_t"))]])
        end
        out *= @sprintf("\n")
    end
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    out *= @sprintf(" Estimator                           %-10s\n", result.estimator)
    out *= @sprintf(" Method                              %-10s\n", result.method)
    out *= @sprintf(" Observations                        %-10d\n", result.bestresult[result.header[:nobs]])
    out *= @sprintf(" F-statistic                         %-10f\n", result.bestresult[result.header[:F]])
    if result.paneltests !== nothing && result.paneltests
        out *= @sprintf(" ANOVA F-test                        %-10f\n", result.bestresult[result.header[:anovaftest]])
    end
    for criteria in result.criteria
        if AVAILABLE_CRITERIA[criteria]["verbose_show"]
            out *= @sprintf(" %-30s      %-10f\n", AVAILABLE_CRITERIA[criteria]["verbose_title"], result.bestresult[result.header[criteria]])
        end
    end
    if !result.modelavg
        out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    end
    if result.modelavg
        out *= @sprintf("\n")
        out *= @sprintf("\n")
        out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
        out *= @sprintf("                            Model averaging results                           \n")
        out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
        out *= @sprintf("                                                                              \n")
        out *= @sprintf("                                     Dependent variable: %s                   \n", result.depvar)
        out *= @sprintf("                                     ─────────────────────────────────────────\n")
        out *= @sprintf("                                                                              \n")
        out *= @sprintf(" Covariates                          Coef.")
        if result.ttest
            out *= @sprintf("        Std.         t-test")
        end
        out *= @sprintf("\n")
        out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
        for varname in all_vars
            out *= @sprintf(" %-35s", varname)
            out *= @sprintf(" %-10f", result.average[result.header[Symbol(string(varname, "_b"))]])
            if result.ttest
                out *= @sprintf("   %-10f", result.average[result.header[Symbol(string(varname, "_bstd"))]])
                out *= @sprintf("   %-10f", result.average[result.header[Symbol(string(varname, "_t"))]])
            end
            out *= @sprintf("\n")
        end
        out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
        out *= @sprintf(" Estimator                           %-10s\n", result.estimator)
        out *= @sprintf(" Method                              %-10s\n", result.method)
        out *= @sprintf(" Observations                        %-10d\n", result.average[result.header[:nobs]])
        out *= @sprintf(" F-statistic                         %-10f\n", result.average[result.header[:F]])
        if result.paneltests !== nothing && result.paneltests
            out *= @sprintf(" ANOVA F-test                        %-10f\n", result.average[result.header[:anovaftest]])
        end
        out *= @sprintf(" Combined criteria                   %-10f\n", result.average[result.header[:order]])
        out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    end
    return out
end
Base.show(io::IO, result::GSRegResult) = print(io, to_string(result))
