function input(
    equation::String;
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing} = nothing,
    datanames::Union{Array, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    return input(
        equation,
        data,
        datanames=datanames,
        method=method,
        intercept=intercept,
        time=time,
        panel=panel,
        removemissings=removemissings
    )
end

function input(
    equation::Array{String};
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing} = nothing,
    datanames::Union{Array, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    return input(
        equation,
        data,
        datanames=datanames,
        method=method,
        intercept=intercept,
        time=time,
        panel=panel,
        removemissings=removemissings
    )
end

function input(
    equation::Array{Symbol};
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing} = nothing,
    datanames::Union{Array, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    return input(
        equation,
        data,
        datanames=datanames,
        method=method,
        intercept=intercept,
        time=time,
        panel=panel,
        removemissings=removemissings
    )
end

function input(
    equation::String,
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing};
    datanames::Union{Array, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    return input(
        equation_str_to_strarr!(equation),
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time,
        panel=panel,
        removemissings=removemissings
    )
end

function input(
    equation::Array{String},
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing};
    datanames::Union{Array, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    datanames = get_datanames_from_data(data, datanames)

    if datanames == nothing
        error(DATANAMES_REQUIRED)
    end

    equation = strarr_to_symarr!(equation_converts_wildcards!(equation, datanames))

    if isempty(equation)
        error(VARIABLES_NOT_DEFINED)
    end
    
    return input(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time,
        panel=panel
    )
end

function input(
    equation::Array{Symbol},
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing};
    datanames::Union{Array, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    if length(equation) != size(equation, 1)
        equation = convert(Vector{Symbol}, equation[1,:])
    end

    method = Symbol(lowercase(string(method)))

    if method == :precise
        datatype = Float64
    elseif method == :fast
        datatype = Float32
    else
        error(INVALID_METHOD)
    end

    if datanames == nothing
        datanames = get_datanames_from_data(data, datanames)
    end

    if length(datanames) != size(datanames, 1)
        datanames = convert(Vector{Symbol}, datanames[1,:])
    end

    data = get_data_from_data(data)

    if !in_vector(equation, datanames)
        error(SELECTED_VARIABLES_DOES_NOT_EXISTS)
    end

    if !isa(data, Array{Union{Missing, datatype}}) || !isa(data, Array{Union{datatype}})
        data = convert(Matrix{Union{Missing, datatype}}, data)
    end

    if time != nothing
        if isa(time, String)
            time = Symbol(time)
        end
        if GlobalSearchRegression.get_column_index(time, datanames) == nothing
            error(TIME_VARIABLE_INEXISTENT)
        end
    end

    if panel != nothing
        if isa(panel, String)
            panel = Symbol(panel)
        end
        if GlobalSearchRegression.get_column_index(panel, datanames) == nothing
            error(PANEL_VARIABLE_INEXISTENT)
        end
    end

    return processinput(
        equation,
        data,
        datanames,
        method,
        intercept;
        time=time,
        panel=panel
    )
end

function processinput(
    equation::Array{Symbol},
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
    datanames::Array{Symbol},
    method::Symbol,
    intercept::Bool;
    time::Union{Symbol, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, Nothing}=PANEL_DEFAULT,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )
    
    if method == :precise
        datatype = Float64
    elseif method == :fast
        datatype = Float32
    end

    temp_equation = equation

    if time != nothing && GlobalSearchRegression.get_column_index(time, temp_equation) == nothing
        temp_equation = vcat(temp_equation, time)
    end

    if panel != nothing && GlobalSearchRegression.get_column_index(panel, temp_equation) == nothing
        temp_equation = vcat(temp_equation, panel)
    end

    (data, datanames) = filter_data_by_selected_columns(data, temp_equation, datanames)
    data = sort_data(data, datanames, panel=panel, time=time)
    
    if panel != nothing && !validate_panel(data, datanames, panel=panel)
        error(PANEL_ERROR)
    end

    if time != nothing && !validate_time(data, datanames, panel=panel, time=time)
        error(TIME_ERROR)
    end

    (data, datanames) = filter_data_by_selected_columns(data, equation, datanames)

    depvar = equation[1]
    expvars = equation[2:end]

    nobs = size(data, 1)

    if intercept
        data = hcat(data, ones(nobs))
        push!(expvars, :_cons)
        push!(datanames, :_cons)
    end

    data = filter_data_by_empty_values(data)
    data = convert(Array{datatype}, data)

    depvar_data = data[1:end, 1]
    expvars_data = data[1:end, 2:end]

    return GSRegData(
        equation,
        depvar,
        expvars,
        depvar_data,
        expvars_data,
        intercept,
        time,
        panel,
        datatype,
        removemissings,
        nobs
    )
end
