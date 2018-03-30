module GSReg

using DataFrames

export
    GSRegSingleResult,
    gsreg

NOCONSTANT_DEFAULT = false
VARNAMES_DEFAULT = []

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

function getCols(i)
    cols = zeros(Int64, 0)
    f = Int(ceil(log2(i+1)))
    for flag in base(2, i)
        if flag == '1'
            prepend!(cols,f)
        end
        f -= 1
    end
    return cols
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

#function gsreg(equation::String; data::DataFrame=DataFrame(), noconstant::Bool=NOCONSTANT_DEFAULT)
#    return gsreg(equation, data, noconstant=noconstant)
#end

function gsreg(equation::String, data::DataFrame; noconstant::Bool=NOCONSTANT_DEFAULT)
    if contains(equation, "~")
        equation = replace(equation, r"\s+|\s+$/g", "")
        dep_indep = split(equation, "~")
        equation = [String(ss) for ss in vcat(dep_indep[1], split(dep_indep[2], "+"))]
    else
        equation = [String(ss) for ss in split(replace(equation, r"\s+|\s+$/g", ","), ",")]
    end
    return GSReg.gsreg(equation, data, noconstant=noconstant)
end

function gsreg(equation::Array{String}, data::DataFrame; noconstant::Bool=NOCONSTANT_DEFAULT)
    keys = names(data)
    n_equation = []
    for e in equation
        if e[end] == '*'
            append!(n_equation, filter!(x->x!=nothing, [String(key)[1:length(e[1:end-1])] == e[1:end-1]?String(key):nothing for key in keys]))
        else
            append!(n_equation, [e])
        end
    end
    return GSReg.gsreg(map(Symbol, unique(n_equation)), data, noconstant=noconstant)
end

function gsreg(equation::Array{Symbol}, data::DataFrame; noconstant::Bool=NOCONSTANT_DEFAULT)
    varnames = map(string, data.colindex.names)
    depvar = Array{Float64}(data[1:end, 1])
    indepvars = Array{Float64}(data[1:end], equation[2:end])
    return GSReg.gsreg(depvar, indepvars, noconstant=noconstant, varnames=varnames)
end

end
