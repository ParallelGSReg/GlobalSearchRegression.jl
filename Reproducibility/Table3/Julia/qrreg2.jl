#OLS QR-Decomposition function using in GlobalSearchRegression.jl
    
function qrreg(data)
    qrf = qr(expvars_data)
    b = qrf \ depvar_data                   # estimate
    ŷ = expvars_data * b                    # predicted values
    er = depvar_data - ŷ                    # in-sample residuals
    er2 = er .^ 2                           # squared errors
    sse = sum(er2)                          # residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom
    rmse = sqrt(sse / nobs)                 # root mean squared error
    r2 = 1 - var(er) / var(depvar_data)     # model R-squared
    bstd = sqrt.( sum( (UpperTriangular(qrf.R) \ Matrix(1.0LinearAlgebra.I, ncoef, ncoef) ) .^ 2, dims=2) * (sse / df_e) ) # std deviation of coefficients

end
