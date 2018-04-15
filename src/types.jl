function gsreg_single_result!(results, order, detvar, expvars)
    qrf = qrfact(expvars)
    b = qrf \ detvar                    # estimate
    nobs = size(detvar, 1)              # number of observations
    ncoef = size(expvars, 2)            # number of coefficients
    df_e = nobs - ncoef                 # degrees of freedom, error
    df_r = ncoef - 1                    # degrees of freedom, regression
    er = detvar - expvars * b           # residuals
    sse = sum(er .^ 2)                  # SSE - sum of squared errors
    rmse = sse / df_e                   # root min squared error
    bvcov = inv(qrf[:R]'qrf[:R]) * rmse  # variance - covariance matrix
    bstd = sqrt.(diag(bvcov))           # standard deviation of beta coefficients
    r2 = 1 - var(er) / var(detvar)      # model R-squared

    cols = get_cols(order)

    results[order,1] = order

    for (index, col) in enumerate(cols)
        results[order, 2col+1] = b[index]
        # este sería el T
        # results[order, 2col+2] = b[index]
    end

    ## calcular size en una function ##
    results[order,size(cols,2)*2 + 1] = nobs
    results[order,size(cols,2)*2 + 2] = ncoef
    results[order,size(cols,2)*2 + 3] = sse
    results[order,size(cols,2)*2 + 4] = rmse
    results[order,size(cols,2)*2 + 5] = r2
end

type GSRegResult
    equation        # las variables que se van a seleccionar
    data            # data array con todos los datos
    intercept
    outsample       # cantidad de observaciones a excluir
    samesample      # excluir observaciones que no tengan algunas de las variables
    threads         # cantidad de threads a usar (paralelismo o no)
    criteria        # criterios de comparacion (r2adj, caic, aic, bic, cp, rmsein, rmseout)
    resultscsv      # salida a un csv
    results         # aca va la posta
    function GSRegResult(equation, data, intercept, outsample, samesample, threads, criteria, resultscsv)
        #calcular dimensiones de la matriz
        #alocar la matriz completa
        #guardar datos de inicializacion
        new(data)
    end
end

#procesamiento
calcular!(result::GSRegResult)
    @simd for
    #for por las combinaciones, quizas paralelo
end

function Base.show(io::IO, r::GSRegResult)
    print("esto es un GSRegResult con esto adentro")
end

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
