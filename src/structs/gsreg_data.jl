mutable struct GSRegData
    equation::Array{Symbol}
    depvar::Symbol
    expvars::Array{Symbol}
    depvar_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}
    expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}
    intercept::Bool
    time::Union{Symbol, Nothing}
    panel::Union{Symbol, Nothing} 
    datatype::DataType
    removemissings::Bool
    nobs::Int64
    options::Array{Any}
    results::Array{Any}

    function GSRegData(
            equation,
            depvar::Symbol,
            expvars::Array{Symbol},
            depvar_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
            expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
            intercept::Bool,
            time::Union{Symbol, Nothing},
            panel::Union{Symbol, Nothing},
            datatype::DataType,
            removemissings::Bool,
            nobs::Int64
        )
        options = Array{Any}(undef, 0)
        results = Array{Any}(undef, 0)
        new(equation, depvar, expvars, depvar_data, expvars_data, intercept, time, panel, datatype, removemissings, nobs, options, results)
    end
end
