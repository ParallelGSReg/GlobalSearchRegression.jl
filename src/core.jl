function gsreg(depvar, expvars, data; intercept=nothing, outsample=nothing, samesample=nothing, threads=nothing,
    criteria=nothing, ttest=nothing, fast=nothing)
    result = GSRegResult(depvar, expvars, data, intercept, outsample, samesample, threads, criteria, ttest, fast)
    proc!(result)
    return result
end

function gsreg_single_result!(result, order)
    data_cols_num = size(result.data, 2)
    cols = get_selected_cols(order)

    if result.intercept
        append!(cols, data_cols_num)
    end

    depvar = @view(result.data[1:end-result.outsample, 1])
    expvars = @view(result.data[1:end-result.outsample, cols])

    varnames = result.varnames

    nobs = size(depvar, 1)
    ncoef = size(expvars, 2)
    qrf = qrfact(expvars)
    b = qrf \ depvar                        # estimate
    er = depvar - expvars * b               # in-sample residuals
    sse = sum(er .^ 2)                      # residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom
    rmse = sqrt(sse / nobs)                 # root mean squared error
    r2 = 1 - var(er) / var(depvar)          # model R-squared

    if result.ttest == true
        bstd = sqrt.(sum( (UpperTriangular(qrf[:R]) \ eye(ncoef)) .^ 2, 2) * (sse / df_e) ) # std deviation of coefficients
    end

    if result.outsample > 0
        depvar_out = @view(result.data[end-result.outsample:end, 1])
        expvars_out = @view(result.data[end-result.outsample:end, cols])
        erout = depvar_out - expvars_out * b          # out-of-sample residuals
        sseout = sum(erout .^ 2)                      # residual sum of squares
        rmseout = sqrt(sseout / result.outsample)        # root mean squared error
        result.results[order, :rmseout] = rmseout
    end

    result.results[order, :index] = order
    cols = get_selected_cols(order)
    for (index, col) in enumerate(cols)
        result.results[order, Symbol(string(varnames[col],"_b"))] = (result.fast)?Float32(b[index]):b[index]
        if result.ttest == true
            result.results[order, Symbol(string(varnames[col],"_bstd"))] = (result.fast)?Float32(bstd[index]):bstd[index]
        end
    end

    result.results[order, :nobs] = nobs
    result.results[order, :ncoef] = ncoef
    result.results[order, :sse] = (result.fast)?Float32(sse):sse
    result.results[order, :rmse] = (result.fast)?Float32(rmse):rmse
    result.results[order, :r2] = (result.fast)?Float32(r2):r2

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
    fast::Bool
    results                 # aca va la posta
    proc                    # flag de que fue procesado
    post_proc               # flag que fue post procesado
    varnames
    nobs
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
        fast)
        new(depvar, expvars, data, intercept, outsample, samesample, threads, criteria, ttest, fast)
    end
end

function proc!(result::GSRegResult)
    expvars_num = size(result.expvars, 1)
    num_operations = 2 ^ expvars_num - 1
    result.varnames = [ result.depvar ; result.expvars ]
    result.nobs = size(result.data, 1)

    if result.intercept
        the_type_of = (result.fast)?Float32:Float64
        result.data = Array{the_type_of}(hcat(result.data, ones(result.nobs)))
        push!(result.expvars, :_cons)
        push!(result.varnames, :_cons)
    end

    criteria = collect(keys(AVAILABLE_CRITERIA))

    sub_headers = (result.ttest) ? ["_b","_bstd","_t"] : ["_b"]

    type_of_this_array_of_things = (result.fast)?Float32:Float64
    headers = vcat([:index ], [Symbol(string(v,n)) for v in result.expvars for n in sub_headers], [:nobs, :ncoef, :r2], criteria)
    result.results = DataFrame(vec([Union{type_of_this_array_of_things,Missing,Int} for i in headers]), vec(headers), num_operations)

    result.results[:] = missing


    Threads.@threads for i = 1:num_operations
        gsreg_single_result!(result, i)
    end

    if result.ttest
        for varname in result.expvars
            result.results[Symbol(string(String(varname),"_t"))] = result.results[Symbol(string(String(varname),"_b"))] ./ result.results[Symbol(string(String(varname),"_bstd"))]
        end
    end

    if :aic in result.criteria || :aicc in result.criteria
        result.results[:aic] = 2 * result.results[:ncoef] + result.results[:nobs] .* log.(result.results[:sse] ./ result.results[:nobs])
    end

    if :aicc in result.criteria
        result.results[:aicc] = result.results[:aic] + (2(result.results[:ncoef] + 1) .* (result.results[:ncoef]+2)) ./ (result.results[:nobs] - (result.results[:ncoef] + 1 ) - 1)
    end

    if :cp in result.criteria
        result.results[:cp] = (result.results[:nobs] - maximum(result.results[:ncoef]) - 2) .* (result.results[:rmse] ./ minimum(result.results[:rmse])) - (result.results[:nobs] - 2 .* result.results[:ncoef])
    end

    if :bic in result.criteria
        result.results[:bic] = result.results[:nobs] .* log.(result.results[:rmse]) + ( result.results[:ncoef] - 1 ) .* log.(result.results[:nobs]) + result.results[:nobs] + result.results[:nobs] .* log(2π)
    end

    if :r2adj in result.criteria
        result.results[:r2adj] = 1 - (1 - result.results[:r2]) .* ((result.results[:nobs] - 1) ./ (result.results[:nobs] - result.results[:ncoef]))
    end

    result.results[:F] = (result.results[:r2] ./ (result.results[:ncoef]-1)) ./ ((1-result.results[:r2]) ./ (result.results[:nobs] - result.results[:ncoef]))

    len_criteria = length(criteria)
    result.results[:order] = 0
    for criteria in result.criteria
        result.results[:order] += AVAILABLE_CRITERIA[criteria]["index"] * (1 / len_criteria) * ( (result.results[criteria] - mean(result.results[criteria]) ) ./ std(result.results[criteria]) )
    end

    sort!(result.results, cols = [:order], rev = true);
end

function Base.show(io::IO, result::GSRegResult)
    @printf("\n")
    @printf("══════════════════════════════════════════════════════════════════════════════\n")
    @printf("                              Best model results                              \n")
    @printf("══════════════════════════════════════════════════════════════════════════════\n")
    @printf("                                                                              \n")
    @printf("                                     Dependent variable: %s                   \n", result.depvar)
    @printf("                                     ─────────────────────────────────────────\n")
    @printf("                                                                              \n")
    @printf(" Selected covariates                 Coef.")
    if result.ttest
        @printf("        Std.         t-test")
    end
    @printf("\n")
    @printf("──────────────────────────────────────────────────────────────────────────────\n")
    for expvar in result.expvars[get_selected_cols(result.results[1,:index])-1]
        @printf(" %-35s", expvar)
        @printf(" %-10f", result.results[1,Symbol(expvar,"_b")])
        if result.ttest
            @printf("   %-10f", result.results[1,Symbol(expvar,"_bstd")])
            @printf("   %-10f", result.results[1,Symbol(expvar,"_t")])
        end
        @printf("\n")
    end
    @printf("──────────────────────────────────────────────────────────────────────────────\n")
    @printf(" Observations                        %-10d\n", result.results[1,:nobs])
    @printf(" Adjusted R²                         %-10f\n", result.results[1,:r2adj])
    @printf(" F-statistic                         %-10d\n", result.results[1,:F])
    for criteria in result.criteria
        if AVAILABLE_CRITERIA[criteria]["verbose_show"]
    @printf(" %-30s      %-10d\n", AVAILABLE_CRITERIA[criteria]["verbose_title"], result.results[1,criteria])
        end
    end
    @printf("──────────────────────────────────────────────────────────────────────────────\n")
end
