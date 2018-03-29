module GSReg

using DataFrames

function gsreg(depvar::Array, indepvars::Array, noconstant::Bool=true, varnames::Array=[])
    # TODO: Implement gsreg

    return true
end

function gsreg(equation::String, data::DataFrame, noconstant::Bool=true)
    return GSReg.gsreg([String(ss) for ss in split(replace(equation, r"\s+|\s+$/g", ","), ",")], data, noconstant)
end

function gsreg(equation::Array{String}, data::DataFrame, noconstant::Bool=true)
    keys = names(data)
    n_equation = []
    for e in equation
        if e[end] == '*'
            append!(n_equation, filter!(x->x!=nothing, [String(key)[1:length(e[1:end-1])] == e[1:end-1]?String(key):nothing for key in keys]))
        else
            append!(n_equation, [e])
        end
    end
    return GSReg.gsreg(map(Symbol, unique(n_equation)), data, noconstant)
end

function gsreg(equation::Array{Symbol}, data::DataFrame, noconstant::Bool=true)
    varnames = map(string, data.colindex.names)
    depvar = Array{Float64}(data[1:end, 1])
    indepvars = Array{Float64}(data[1:end, equation])
    return GSReg.gsreg(depvar, indepvars, noconstant, varnames)
end

end
