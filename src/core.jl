
get_variable_pos(col, n) = POS_NUM_VARS*col+n
get_b_pos(col) = get_variable_pos(col, RESULT_ARRAY["b"])
get_bstd_pos(col) = get_variable_pos(col, RESULT_ARRAY["bstd"])

get_result_pos(cols_size, n) = cols_size * POS_NUM_VARS + n
get_nobs_pos(cols_size) = get_result_pos(cols_size, RESULT_ARRAY["nobs"])
get_ncoef_pos(cols_size) = get_result_pos(cols_size, RESULT_ARRAY["ncoef"])
get_sse_pos(cols_size) = get_result_pos(cols_size, RESULT_ARRAY["sse"])
get_rmse_pos(cols_size) = get_result_pos(cols_size, RESULT_ARRAY["rmse"])
get_r2_pos(cols_size) = get_result_pos(cols_size, RESULT_ARRAY["r2"])


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
    rmse = sum(er .^ 2) / ( nobs - ncoef )  # root mean squared errors
    bvcov = inv(qrf[:R]'qrf[:R]) * rmse     # variance - covariance matrix
    bstd = sqrt.(diag(bvcov))               # standard deviation of beta coefficients
    r2 = 1 - var(er) / var(depvar)          # model R-squared

    cols = get_cols(order)
    results[order,1] = order
    for (index, col) in enumerate(cols)
        results[order, get_b_pos(col)] = b[index]
        results[order, get_bstd_pos(col)] = bstd[index]
        # este sería el T
        # results[order, 2col+3] = b[index] / bstd[index]
    end

    cols_size = size(cols,2)
    results[order, get_nobs_pos(cols_size)] = nobs
    results[order, get_ncoef_pos(cols_size)] = ncoef
    results[order, get_sse_pos(cols_size)] = sse
    results[order, get_rmse_pos(cols_size)] = rmse
    results[order, get_r2_pos(cols_size)] = r2
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
        criteria,
        resultscsv)
        #calcular dimensiones de la matriz
        #alocar la matriz completa
        #guardar datos de inicializacion
        new(depvar, expvars, data, intercept, outsample, samesample, threads, criteria, results)
    end
end

function proc!(result::GSRegResult)
    expvars_num = size(expvars, 2)

    if varnames == nothing
        varnames = get_default_varnames(expvars_num)
    end

    num_operations = 2 ^ expvars_num - 1

    if result.intercept
        expvars = hcat(ones(size(expvars, 1)), expvars)
        push!(varnames, :_cons)
    end

    results = Matrix{Float64}(num_operations,1+3nvar,12)

    for i = 1:num_operations
        cols = get_cols(i)

        if intercept
            append!(cols, expvars_num + 1) #add constant
        end
        single_result = gsreg_single_result!(results, i, @view(expvars[1:end, cols]), depvar)
        push!(results, get_partial_row(single_result))
    end

    return results
end

function post_proc!(result::GSRegResult)
    function aic()
        return obs * log(rmse) + 2 * ( nvar - 1 ) + obs + obs * log(2π)
    end

    function aicc()
        return aic + ( 2*(nvar+1)*(nvar+2) )/( obs-(nvar+1)-1 )
    end

    function cp()
        return (obs - max(nvar) - 2) * (rmse/min(rmse)) - (obs - 2 * nvar)
    end

    function bic()
        return obs * log(rmse) + ( nvar - 1 ) * log(obs) + obs + obs * log(2π)
    end

    function r2adj()
        return 1 - (1 - r2) * ((obs - 1) / (obs - nvar))
    end
    @inbounds @simd for result in result.results

    end
end

function Base.show(io::IO, r::GSRegResult)
    print("esto es un GSRegResult con esto adentro")
end
