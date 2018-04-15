function gsreg(depvar, expvars, data; intercept, outsample, samesample, threads, criteria)
    result = GSRegResult(...)
    proc!(result)
    post_proc!(result)
    return result
end

function gsreg_single_result!(results, order, depvar, expvars)
    qrf = qrfact(expvars)
    b = qrf \ depvar                        # estimate
    nobs = size(depvar, 1)                  # number of observations
    ncoef = size(expvars, 2)                # number of coefficients
    er = detvar - expvars * b               # residuals
    sse = sum(er .^ 2)                      # residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom
    se2 = sse / df_e                        # residual variance
    rmse = sqrt(sse) / nobs                 # root mean squared error
    bvcov = inv(qrf[:R]'qrf[:R]) * se2      # variance - covariance matrix
    bstd = sqrt.(diag(bvcov))               # standard deviation of beta coefficients
    r2 = 1 - var(er) / var(depvar)          # model R-squared

    results[order, :index] = order

    cols = get_cols(order)

    for (index, col) in enumerate(cols)
        results[order, get_variable_result_symbol(col, "b")] = b[index]
        results[order, get_variable_result_pos(col, "bstd")] = bstd[index]
        # este sería el T
        # results[order, 2col+3] = b[index] / bstd[index]
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
    expvars_num = size(result.expvars, 2)

    varnames = [ result.depvar ; result.expvars ]

    num_operations = 2 ^ expvars_num - 1

    if result.intercept
        result.expvars = hcat(ones(size(expvars, 1)), expvars)
        push!(varnames, :_cons)
    end

    criteria = [ :sse :rmse :aic :aicc :cp :bic :r2adj ]

    headers = [:index [Symbol(string(v,n)) for v in varnames for n in ["_b","_std","_t"]] :nobs :ncoef criteria ]

    results = DataFrame(vec([Float64 for i in headers]), vec(headers), num_operations)

    for i = 1:num_operations
        cols = get_cols(i)

        if result.intercept
            append!(cols, expvars_num + 1)
        end

        gsreg_single_result!(results, i, result.depvar, @view(result.expvars[1:end, cols]))
    end

    result.results = results
    result.proc = true
end

function post_proc!(result::GSRegResult)
    for result in eachrow(result.results)
        aic = obs * log(rmse) + 2 * ( nvar - 1 ) + obs + obs * log(2π)
        aicc = aic + ( 2*(nvar+1)*(nvar+2) )/( obs-(nvar+1)-1 )
        cp = (obs - max(nvar) - 2) * (rmse/min(rmse)) - (obs - 2 * nvar)
        bic = obs * log(rmse) + ( nvar - 1 ) * log(obs) + obs + obs * log(2π)
        r2adj = 1 - (1 - r2) * ((obs - 1) / (obs - nvar))
        # calcular el t_test
    end
    result.post_proc = true
end

function Base.show(io::IO, r::GSRegResult)
    print("esto es un GSRegResult con esto adentro")
end
