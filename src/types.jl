type GSRegSingleResult
    nobs::Int
    ncoef::Int
    df_e::Int
    df_r::Int
    b::Array
    sse::Float64
    R2::Float64
    
    function GSRegSingleResult(x, y)
        qrf = qrfact(x)
        nobs = size(y, 1)         # number of observations
        ncoef = size(x, 2)        # number of coefficients
        df_e = nobs - ncoef       # degrees of freedom, error
        df_r = ncoef - 1          # degrees of freedom, regression
        b = qrf \ y               # estimate
        er = y - x * b            # residuals
        sse = sum(er .^ 2) / df_e # SSE
        bvcov = inv(qrf[:R]'qrf[:R]) * sse # variance - covariance matrix
        bstd = sqrt.(diag(bvcov)) # standard deviation of beta coefficients
        R2 = 1 - var(er) / var(y) # model R-squared
        new(nobs, ncoef, df_e, df_r, b, sse, R2)
    end
end