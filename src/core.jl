type GSRegSingleResult
    nobs::Int
    ncoef::Int
    df_e::Int
    df_r::Int
    b::Array
    er::Array
    sse::Float64
    R2::Float64
    R2adj::Float64

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
        R2adj = 1 - (1 - R2) * ((nobs - 1) / (nobs - ncoef)) # adjusted R-square
        new(nobs, ncoef, df_e, df_r, b, er, sse, R2, R2adj) #, y_varnm, x_varnm)
    end
end

function gsreg(depvar::Array, indepvars::Array; noconstant::Bool=NOCONSTANT_DEFAULT, varnames::Array=VARNAMES_DEFAULT)
    indepvars_num = size(indepvars, 2)

    num_operations = 2 ^ indepvars_num - 1

    results = Array{GSRegSingleResult}(num_operations)

    if !noconstant
        indepvars = hcat(ones(size(indepvars, 1)),indepvars)
    end

    for i = 1:num_operations
        cols = getCols(i)

        if !noconstant
            append!(cols, indepvars_num+1) #add constant
        end

        results[i] = GSRegSingleResult(@view(indepvars[1:end, cols]), depvar)
    end

    return results
end