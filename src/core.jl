function gsreg(depvar, expvars, data; intercept=nothing, outsample=nothing, samesample=nothing, threads=nothing,
    criteria=nothing, ttest=nothing, method=nothing, summary=nothing, datanames=nothing)
    result = GSRegResult(depvar, expvars, data, intercept, outsample, samesample, threads, criteria, ttest, method)
    result.datanames = datanames

    proc!(result)
    if summary != nothing
        f = open(summary, "w")
        write(f, to_string(result))
        close(f)
    end
    return result
end


function gsreg_single_proc_result!(data, results, order, outsample, ttest, method, intercept, varnames, criteria)
    cols = get_selected_cols(order)
    data_cols_num = size(data, 2)
    if intercept
        append!(cols, data_cols_num)
    end 

    # Q: @view or not?
    depvar = @view(data[1:end-outsample, 1])
    expvars = @view(data[1:end-outsample, cols])

    nobs = size(depvar, 1)
    ncoef = size(expvars, 2)
    qrf = qrfact(expvars)
    b = qrf \ depvar                        # estimate
    er = depvar - expvars * b               # in-sample residuals
    sse = sum(er .^ 2)                      # residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom
    rmse = sqrt(sse / nobs)                 # root mean squared error
    r2 = 1 - var(er) / var(depvar)          # model R-squared

    if ttest == true
        bstd = sqrt.(sum( (UpperTriangular(qrf[:R]) \ eye(ncoef)) .^ 2, 2) * (sse / df_e) ) # std deviation of coefficients
    end

    if outsample > 0
        depvar_out = @view(data[end-outsample:end, 1])
        expvars_out = @view(data[end-outsample:end, cols])
        erout = depvar_out - expvars_out * b          # out-of-sample residuals
        sseout = sum(erout .^ 2)                      # residual sum of squares
        rmseout = sqrt(sseout / outsample)            # root mean squared error
        results[order, get_data_position(:rmseout, varnames, intercept, ttest, criteria)] = rmseout
    end

    results[order, 1] = order

    for (index, col) in enumerate(cols)
        results[order, get_data_position(Symbol(string(varnames[col-1], "_b")), varnames, intercept, ttest, criteria)] = (method == "fast")?Float32(b[index]):b[index]
        if ttest == true
            results[order, get_data_position(Symbol(string(varnames[col-1], "_bstd")), varnames, intercept, ttest, criteria)] = (method == "fast")?Float32(bstd[index]):bstd[index]
        end
    end

    nobs_pos = get_data_position(:nobs, varnames, intercept, ttest, criteria)
    ncoef_pos = get_data_position(:ncoef, varnames, intercept, ttest, criteria)
    sse_pos = get_data_position(:sse, varnames, intercept, ttest, criteria)
    rmse_pos = get_data_position(:rmse, varnames, intercept, ttest, criteria)
    r2_pos = get_data_position(:r2, varnames, intercept, ttest, criteria)
    results[order, nobs_pos] = nobs
    results[order, ncoef_pos] = ncoef
    results[order, sse_pos] = (method == "fast")?Float32(sse):sse
    results[order, r2_pos] = (method == "fast")?Float32(r2):r2
    results[order, rmse_pos] = (method == "fast")?Float32(rmse):rmse
end

function gsreg_proc_result!(data, results, num_procs, ops_by_worker, i, outsample, ttest, method, intercept, varnames, criteria)
    @time for j = 1:ops_by_worker
        order = (j-1) * num_procs + i
        gsreg_single_proc_result!(data, results, order, outsample, ttest, method, intercept, varnames, criteria)
    end
end

type GSRegResult
    depvar::Symbol
    expvars::Array{Symbol}  # los nombres de las variables que se van a combinar
    data                    # data array con todos los datos
    intercept               # add constant of ones
    outsample               # cantidad de observaciones a excluir
    samesample              # excluir observaciones que no tengan algunas de las variables
    threads                 # cantidad de threads a usar (paralelismo o no)
    criteria                # criterios de comparacion (r2adj, caic, aic, bic, cp, rmsein, rmseout)
    ttest::Bool
    method::String
    results                 # aca va la posta
    proc                    # flag de que fue procesado
    post_proc               # flag que fue post procesado
    varnames
    nobs
    datanames
    function GSRegResult(
        depvar::Symbol,
        expvars::Array{Symbol},
        data,
        intercept::Bool,
        outsample::Int,
        samesample::Bool,
        threads::Int,
        criteria,
        ttest,
        method)
        if :r2adj ∉ criteria
            push!(criteria, :r2adj)
        end
        new(depvar, expvars, data, intercept, outsample, samesample, threads, criteria, ttest, method)
    end
end

function proc!(result::GSRegResult)
    expvars_num = size(result.expvars, 1)
    num_operations = 2 ^ expvars_num - 1
    result.varnames = result.datanames
    result.nobs = size(result.data, 1)

    if result.intercept
        the_type_of = (result.method == "fast")?Float32:Float64
        result.data = Array{the_type_of}(hcat(result.data, ones(result.nobs)))
        push!(result.expvars, :_cons)
        push!(result.varnames, :_cons)
        push!(result.datanames, :_cons)
    end

    criteria = collect(keys(AVAILABLE_CRITERIA))

    sub_headers = (result.ttest) ? ["_b","_bstd","_t"] : ["_b"]

    type_of_this_array_of_things = (result.method == "fast")?Float32:Float64
    headers = vcat([:index], [Symbol(string(v,n)) for v in result.expvars for n in sub_headers], [:nobs, :ncoef, :sse, :r2, :F, :rmse, :order], result.criteria)

    pdata = convert(SharedArray, result.data)
    presults = SharedArray{type_of_this_array_of_things}(num_operations, size(headers, 1))
    # Q (how much this instruction takes)
    # @time fill!(presults, NaN)
    
    num_procs = (nprocs()==1)? 1 : nprocs()-1 #exclude REPL worker if -p exists
    ops_by_worker = div(num_operations, num_procs)
    num_jobs = (num_procs > num_operations)?num_operations:num_procs
    remainder = num_operations - ops_by_worker * num_jobs

    jobs = []

    for i = 1:num_jobs
        push!(jobs, @spawnat (num_procs==1)?1:i+1 gsreg_proc_result!(pdata, presults, num_jobs, ops_by_worker, i, result.outsample, result.ttest, result.method, result.intercept, result.expvars, result.criteria))
    end

    for job in jobs
        fetch(job)
    end

    if( remainder > 0 )
        for j = 1:remainder
            gsreg_single_proc_result!(pdata, presults, j + ops_by_worker * num_jobs, result.outsample, result.ttest, result.method, result.intercept, result.expvars, result.criteria)
        end
    end

    result.results = Array(presults)
    presult = nothing
    pdata = nothing

    if result.ttest
        for varname in result.expvars
            pos_b = get_data_position(Symbol(string(varname, "_b")), result.expvars, result.intercept, result.ttest, result.criteria)
            pos_bstd = pos_b + 1
            pos_t = pos_bstd + 1
            presults[pos_t] = presults[pos_b] ./ presults[pos_bstd]
        end
    end
    
    ncoef_pos = get_data_position(:ncoef, result.expvars, result.intercept, result.ttest, result.criteria)
    nobs_pos = get_data_position(:nobs, result.expvars, result.intercept, result.ttest, result.criteria)
    sse_pos = get_data_position(:sse, result.expvars, result.intercept, result.ttest, result.criteria)
    rmse_pos = get_data_position(:rmse, result.expvars, result.intercept, result.ttest, result.criteria)
    r2_pos = get_data_position(:r2, result.expvars, result.intercept, result.ttest, result.criteria)
    F_pos = get_data_position(:F, result.expvars, result.intercept, result.ttest, result.criteria)
    order_pos = get_data_position(:order, result.expvars, result.intercept, result.ttest, result.criteria)
    
    if :aic in result.criteria || :aicc in result.criteria
        aic_pos = get_data_position(:aic, result.expvars, result.intercept, result.ttest, result.criteria)
        presults[:,aic_pos] = 2 * presults[:,ncoef_pos] + presults[:,nobs_pos] .* log.(presults[:,sse_pos] ./ presults[:,nobs_pos])
    end

    if :aicc in result.criteria
        aicc_pos = get_data_position(:aicc, result.expvars, result.intercept, result.ttest, result.criteria)
        presults[:,aicc_pos] = presults[:,aic_pos] + (2(presults[:,ncoef_pos] + 1) .* (presults[:,ncoef_pos]+2)) ./ (presults[:,nobs_pos] - (presults[:,ncoef_pos] + 1 ) - 1)
    end

    if :cp in result.criteria
        cp_pos = get_data_position(:cp, result.expvars, result.intercept, result.ttest, result.criteria)
        presults[:,cp_pos] = (presults[:,nobs_pos] - maximum(presults[:,ncoef_pos]) - 2) .* (presults[:,rmse_pos] ./ minimum(presults[:,rmse_pos])) - (presults[:,nobs_pos] - 2 .* presults[:,ncoef_pos])
    end

    if :bic in result.criteria
        bic_pos = get_data_position(:bic, result.expvars, result.intercept, result.ttest, result.criteria)
        presults[:,bic_pos] = presults[:,nobs_pos] .* log.(presults[:,rmse_pos]) + ( presults[:,ncoef_pos] - 1 ) .* log.(presults[:,nobs_pos]) + presults[:,nobs_pos] + presults[:,nobs_pos] .* log(2π)
    end

    if :r2adj in result.criteria
        r2adj_pos = get_data_position(:r2adj, result.expvars, result.intercept, result.ttest, result.criteria)
        presults[:,r2adj_pos] = 1 - (1 - presults[:,r2_pos]) .* ((presults[:,nobs_pos] - 1) ./ (presults[:,nobs_pos] - presults[:,ncoef_pos]))
    end
        
    presults[:,F_pos] = (presults[:,r2_pos] ./ (presults[:,ncoef_pos]-1)) ./ ((1-presults[:,r2_pos]) ./ (presults[:,nobs_pos] - presults[:,ncoef_pos]))

    len_criteria = length(result.criteria)
    #result.results[:,order_pos] = 0
    for criteria in result.criteria
        criteria_pos = get_data_position(criteria, result.expvars, result.intercept, result.ttest, result.criteria)        
        presults[:,order_pos] += AVAILABLE_CRITERIA[criteria]["index"] * (1 / len_criteria) * ( (presults[:,criteria_pos] - mean(presults[:,criteria_pos]) ) ./ std(presults[:,criteria_pos]) )
    end
    
    result.results = sortrows(result.results; lt=(x,y)->isless(x[order_pos],y[order_pos]), rev=true)
end

function to_string(result::GSRegResult)
    index_pos = get_data_position(:index, result.datanames, result.intercept, result.ttest, result.criteria)
    ncoef_pos = get_data_position(:ncoef, result.datanames, result.intercept, result.ttest, result.criteria)
    nobs_pos = get_data_position(:nobs, result.datanames, result.intercept, result.ttest, result.criteria)
    sse_pos = get_data_position(:sse, result.datanames, result.intercept, result.ttest, result.criteria)
    rmse_pos = get_data_position(:rmse, result.datanames, result.intercept, result.ttest, result.criteria)
    r2_pos = get_data_position(:r2, result.datanames, result.intercept, result.ttest, result.criteria)
    r2adj_pos = get_data_position(:r2adj, result.datanames, result.intercept, result.ttest, result.criteria)
    F_pos = get_data_position(:F, result.datanames, result.intercept, result.ttest, result.criteria)
    order_pos = get_data_position(:order, result.datanames, result.intercept, result.ttest, result.criteria)


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
    if result.outsample > 0
        out *= @sprintf("        Rmseout")
    end
    out *= @sprintf("\n")
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")

    cols = get_selected_cols(Int64(result.results[1, index_pos]))

    data_cols_num = size(result.data, 2)
    if result.intercept
        append!(cols, data_cols_num)
    end

    for varname in result.datanames[cols]
        pos_b = get_data_position(Symbol(string(varname, "_b")), result.datanames, result.intercept, result.ttest, result.criteria)
        out *= @sprintf(" %-35s", varname)
        out *= @sprintf(" %-10f", result.results[1, pos_b])
        if result.ttest
            pos_bstd = pos_b + 1
            pos_t = pos_bstd + 1
            out *= @sprintf("   %-10f", result.results[1,pos_bstd])
            out *= @sprintf("   %-10f", result.results[1,pos_t])
        end
        out *= @sprintf("\n")
    end
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    out *= @sprintf(" Observations                        %-10d\n", result.results[1,nobs_pos])
    out *= @sprintf(" Adjusted R²                         %-10f\n", result.results[1,r2adj_pos])
    out *= @sprintf(" F-statistic                         %-10f\n", result.results[1,F_pos])
    for criteria in result.criteria
        if AVAILABLE_CRITERIA[criteria]["verbose_show"]
    criteria_pos = get_data_position(criteria, result.datanames, result.intercept, result.ttest, result.criteria)        
    out *= @sprintf(" %-30s      %-10f\n", AVAILABLE_CRITERIA[criteria]["verbose_title"], result.results[1,criteria_pos])
        end
    end
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    return out
end

Base.show(io::IO, result::GSRegResult) = print(to_string(result))
