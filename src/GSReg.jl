module GSReg

using DataFrames

NOCONSTANT_DEFAULT = false
VARNAMES_DEFAULT = []

function gsreg(depvar::Array, indepvars::Array; noconstant::Bool=NOCONSTANT_DEFAULT, varnames::Array=VARNAMES_DEFAULT)
    # TODO: Implement gsreg
    return true
end

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
    indepvars = Array{Float64}(data[1:end, equation])
    return GSReg.gsreg(depvar, indepvars, noconstant=noconstant, varnames=varnames)
end

end
