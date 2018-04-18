function gsreg(depvar, expvars, data; intercept=nothing, outsample=nothing, samesample=nothing, threads=nothing, criteria=nothing)
    result = GSRegResult(depvar, expvars, data, intercept, outsample, samesample, threads, criteria)
    proc!(result)
    post_proc!(result)
    return result
end

function gsreg_single_result!(results, order, varnames, depvar, expvars)
    # TODO:
    # (adanmauri) This is not working with more than one expvar
    qrf = qrfact(expvars)
    b = qrf \ depvar                        # estimate
    nobs = size(depvar, 1)                  # number of observations
    ncoef = size(expvars, 2)                # number of coefficients
    er = depvar - expvars * b               # residuals
    sse = sum(er .^ 2)                      # residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom
    se2 = sse / df_e                        # residual variance
    rmse = sqrt(sse) / nobs                 # root mean squared error
    bvcov = inv(qrf[:R]'qrf[:R]) * se2      # variance - covariance matrix
    bstd = sqrt.(diag(bvcov))               # standard deviation of beta coefficients
    r2 = 1 - var(er) / var(depvar)          # model R-squared

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
    varnames = [ result.depvar ; result.expvars ]

    if result.intercept
        result.data = hcat(result.data, ones(size(result.data, 1)))
        push!(varnames, :_cons)
    end

    criteria = collect(keys(AVAILABLE_CRITERIA))

    headers = vcat([:index ], [Symbol(string(v,n)) for v in varnames for n in ["_b","_bstd","_t"]], [:nobs, :ncoef, :r2], criteria)
    results = DataFrame(vec([Float64 for i in headers]), vec(headers), num_operations)

    data_cols_num = size(result.data, 2)

    for i = 1:num_operations
        cols = get_selected_cols(i)
        if result.intercept
            append!(cols, data_cols_num)
        end
        gsreg_single_result!(results, i, varnames, @view(result.data[1:end, 1]), @view(result.data[1:end, cols]))
    end

    result.results = results
    result.proc = true
end

function post_proc!(result::GSRegResult)
    # TODO:
    # @simd?
    for res in eachrow(result.results)
        # NOTE:
        # (adanmauri) Is it nvar equal ncoef? If not, change ncoef to nvar
        # Generate by demand
        res[:aic] = res[:nobs] * log(res[:rmse]) + 2( res[:ncoef] - 1 ) + res[:rmse] + res[:rmse] * log(2π)
        res[:aicc] = res[:aic] + (2(res[:ncoef] + 1) * (res[:ncoef]+2)) / (res[:nobs]-(res[:ncoef] + 1 ) - 1)
        res[:cp] = (res[:nobs] - max(res[:ncoef]) - 2) * (res[:rmse]/min(res[:rmse])) - (res[:nobs] - 2 * res[:ncoef])
        res[:bic] = res[:nobs] * log(res[:rmse]) + ( res[:ncoef] - 1 ) * log(res[:nobs]) + res[:nobs] + res[:nobs] * log(2π)
        res[:r2adj] = 1 - (1 - res[:r2]) * ((res[:nobs] - 1) / (res[:nobs] - res[:ncoef]))

        # TODO:
        # Calculate t_test value
    end
    result.post_proc = true
end

function Base.show(io::IO, r::GSRegResult)
    print("esto es un GSRegResult con esto adentro")
end
