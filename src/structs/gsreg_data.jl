mutable struct GSRegData
    equation::Array{Symbol}
    depvar::Symbol
    expvars::Array{Symbol}
    panel::Union{Symbol, Nothing} 
    time::Union{Symbol, Nothing}
    depvar_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float64, Missing}}, Array{Union{Float32, Missing}}}
    expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float64, Missing}}, Array{Union{Float32, Missing}}}
    panel_data::Union{Nothing, Array{Int64}, Array{Int32}, Array{Union{Int64, Missing}}, Array{Union{Int32, Missing}}}
    time_data::Union{Nothing, Array{Float64}, Array{Float32}, Array{Union{Float64, Missing}}, Array{Union{Float32, Missing}}}
    intercept::Bool
    datatype::DataType
    removemissings::Bool
    nobs::Int64
    options::Array{Any}
    extras::Dict
    previous_data::Array{Any}
    results::Array{Any}

    function GSRegData(
            equation,
            depvar::Symbol,
            expvars::Array{Symbol},
            panel::Union{Symbol, Nothing},
            time::Union{Symbol, Nothing},
            depvar_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
            expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
            panel_data::Union{Nothing, Array{Int64}, Array{Int32}, Array{Union{Int64, Missing}}, Array{Union{Int32, Missing}}},
            time_data::Union{Nothing, Array{Float64}, Array{Float32}, Array{Union{Float64, Missing}}, Array{Union{Float32, Missing}}},
            intercept::Bool,
            datatype::DataType,
            removemissings::Bool,
            nobs::Int64
        )
        extras = Dict()
        options = Array{Any}(undef, 0)
        previous_data = Array{Any}(undef, 0)
        results = Array{Any}(undef, 0)
        new(equation, depvar, expvars, panel, time, depvar_data, expvars_data, panel_data, time_data, intercept, datatype, removemissings, nobs, options, extras, previous_data, results)
    end
end
