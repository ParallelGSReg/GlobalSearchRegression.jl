function gsreg(depvar, expvars, data; intercept=nothing, outsample=nothing, samesample=nothing, threads=nothing, criteria=nothing)
    result = GSRegResult(depvar, expvars, data, intercept, outsample, samesample, threads, criteria)
    proc!(result)
    post_proc!(result)
    return result
end

function gsreg_single_result!(result, results, order)
    """    data_cols_num = size(result.data, 2)
    cols = get_selected_cols(order)
    if result.intercept
        append!(cols, data_cols_num)
    end

    depvar = @view(result.data[1:end, 1])
    expvars = @view(result.data[1:end, cols])
    varnames = result.varnames

    nobs = size(depvar, 1)
    ncoef = size(expvars, 2)
    qrf = qrfact(expvars)
    b = qrf \ depvar                        # estimate
    er = depvar - expvars * b               # residuals
    sse = sum(er .^ 2)                      # residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom
    se2 = sse / df_e                        # residual variance
    rmse = sqrt(sse / nobs)                 # root mean squared error
    r2 = 1 - var(er) / var(depvar)          # model R-squared
    bstd = sqrt.(sum( (UpperTriangular(qrf[:R]) \ eye(ncoef)) .^ 2, 2) * se2 ) # std deviation of coefficients

    results[order, :index] = order

    cols = get_selected_cols(order)
    for (index, col) in enumerate(cols)
        results[order, Symbol(string(varnames[col],"_b"))] = b[index]
        results[order, Symbol(string(varnames[col],"_bstd"))] = bstd[index]
    end

    results[order, :nobs] = nobs
    results[order, :ncoef] = ncoef
    results[order, :sse] = sse
    results[order, :rmse] = rmse
    results[order, :r2] = r2
    if (i > 1000)
        gc()
    end
    i = i + 1"""
    varnames = result.varnames

    results[order, :index] = order

    cols = get_selected_cols(order)
    for (index, col) in enumerate(cols)
        results[order, Symbol(string(varnames[col],"_b"))] = 1
        results[order, Symbol(string(varnames[col],"_bstd"))] = 1
    end

    results[order, :nobs] = 1
    results[order, :ncoef] = 1
    results[order, :sse] = 1
    results[order, :rmse] = 1
    results[order, :r2] = 1
end


type GSRegResult
    depvar::Symbol          # la variable independiente
    expvars::Array{Symbol}  # los nombres de las variables que se van a combinar
    data                    # data array con todos los datos
    intercept               # add constant of ones
    outsample               # cantidad de observaciones a excluir
    samesample              # excluir observaciones que no tengan algunas de las variables
    threads                 # cantidad de threads a usar (paralelismo o no)
    criteria                # criterios de comparacion (r2adj, caic, aic, bic, cp, rmsein, rmseout)
    results                 # aca va la posta
    proc                    # flag de que fue procesado
    post_proc               # flag que fue post procesado
    varnames
    nobs
    function GSRegResult(
        depvar::Symbol,
        expvars::Array{Symbol},
        data::Array,
        intercept::Bool,
        outsample::Int,
        samesample::Bool,
        threads::Int,
        criteria)
        new(depvar, expvars, data, intercept, outsample, samesample, threads, criteria)
    end
end

function proc!(result::GSRegResult)
    expvars_num = size(result.expvars, 1)
    num_operations = 2 ^ expvars_num - 1
    result.varnames = [ result.depvar ; result.expvars ]
    result.nobs = size(result.data, 1)

    if result.intercept
        result.data = hcat(result.data, ones(result.nobs))
        push!(result.expvars, :_cons)
        push!(result.varnames, :_cons)
    end

    criteria = collect(keys(AVAILABLE_CRITERIA))

    headers = vcat([:index ], [Symbol(string(v,n)) for v in result.expvars for n in ["_b","_bstd","_t"]], [:nobs, :ncoef, :r2], criteria)
    results = DataFrame(vec([Float64 for i in headers]), vec(headers), num_operations)
    results[:] = 0

    """
    operation_matrix_header = [:nobs, :ncoef, :qrf, :b, :er, :sse, :df_e, :se2, :rmse, :r2, :bstd]
    operations_matrix = DataFrame(vec([Float64 for i in operation_matrix_header]), vec(headers), nthreads())
    """
    Threads.@threads for i = 1:num_operations
        gsreg_single_result!(result, results, i)
    end

    result.results = results
    result.proc = true
end

function post_proc!(result::GSRegResult)
    # TODO:
    # @simd?
    """nops = size(result.results, 1)
    Threads.@threads for i = 1:nops
        # NOTE:
        # (adanmauri) Is it nvar equal ncoef? If not, change ncoef to nvar
        # Generate by demand
        result.results[i, :aic] = 2 * result.results[i, :ncoef] + result.results[i, :nobs] * log(result.results[i, :sse]/result.results[i, :nobs])
        result.results[i, :aicc] = result.results[i, :aic] + (2(result.results[i, :ncoef] + 1) * (result.results[i, :ncoef]+2)) / (result.results[i, :nobs]-(result.results[i, :ncoef] + 1 ) - 1)
        result.results[i, :cp] = (result.results[i, :nobs] - max(result.results[i, :ncoef]) - 2) * (result.results[i, :rmse]/min(result.results[i, :rmse])) - (result.results[i, :nobs] - 2 * result.results[i, :ncoef])
        result.results[i, :bic] = result.results[i, :nobs] * log(result.results[i, :rmse]) + ( result.results[i, :ncoef] - 1 ) * log(result.results[i, :nobs]) + result.results[i, :nobs] + result.results[i, :nobs] * log(2π)
        result.results[i, :r2adj] = 1 - (1 - result.results[i, :r2]) * ((result.results[i, :nobs] - 1) / (result.results[i, :nobs] - result.results[i, :ncoef]))
        # TODO:
        # Calculate t_test value
    end"""
    result.post_proc = true
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
    @printf(" Selected covariates                 Coef.        Std.         t-test         \n")
    @printf("──────────────────────────────────────────────────────────────────────────────\n")
    for expvar in result.expvars
    @printf(" %-30s      %-10d   %-10d   %-10d\n", expvar, 1, 1, 1)
    end
    @printf("──────────────────────────────────────────────────────────────────────────────\n")
    @printf(" Observations                        %-10d\n", result.nobs)
    @printf(" Adjusted R²                         %-10d\n", 1) #result.results[:r2adj])
    @printf(" F-statistic                         %-10d\n", 2)
    for criteria in result.criteria
        if AVAILABLE_CRITERIA[criteria]["verbose_show"]
    @printf(" %-30s      %-10d\n", AVAILABLE_CRITERIA[criteria]["verbose_title"], 1)
        end
    end
    @printf("──────────────────────────────────────────────────────────────────────────────\n")
end
