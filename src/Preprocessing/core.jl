function input(
    equation::String;
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing} = nothing,
    datanames::Union{Array, Array{Symbol, 1}, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removeoutliers::Bool=REMOVEOUTLIERS_DEFAULT,
    seasonaladjustment::Union{Dict, Nothing}=SEASONALADJUSTMENT_DEFAULT,
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
        removeoutliers=removeoutliers,
        seasonaladjustment=seasonaladjustment,
        removemissings=removemissings
    )
end

function input(
    equation::Array{String};
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing} = nothing,
    datanames::Union{Array, Array{Symbol, 1}, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removeoutliers::Bool=REMOVEOUTLIERS_DEFAULT,
    seasonaladjustment::Union{Dict, Nothing}=SEASONALADJUSTMENT_DEFAULT,
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
        removeoutliers=removeoutliers,
        seasonaladjustment=seasonaladjustment,
        removemissings=removemissings
    )
end

function input(
    equation::Array{Symbol};
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing} = nothing,
    datanames::Union{Array, Array{Symbol, 1}, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removeoutliers::Bool=REMOVEOUTLIERS_DEFAULT,
    seasonaladjustment::Union{Dict, Nothing}=SEASONALADJUSTMENT_DEFAULT,
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
        removeoutliers=removeoutliers,
        seasonaladjustment=seasonaladjustment,
        removemissings=removemissings
    )
end

function input(
    equation::String,
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing};
    datanames::Union{Array, Array{Symbol, 1}, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removeoutliers::Bool=REMOVEOUTLIERS_DEFAULT,
    seasonaladjustment::Union{Dict, Nothing}=SEASONALADJUSTMENT_DEFAULT,
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
        removeoutliers=removeoutliers,
        seasonaladjustment=seasonaladjustment,
        removemissings=removemissings
    )
end

function input(
    equation::Array{String},
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing};
    datanames::Union{Array, Array{Symbol, 1}, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removeoutliers::Bool=REMOVEOUTLIERS_DEFAULT,
    seasonaladjustment::Union{Dict, Nothing}=SEASONALADJUSTMENT_DEFAULT,
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
        panel=panel,
        removeoutliers=removeoutliers,
        seasonaladjustment=seasonaladjustment,
        removemissings=removemissings
    )
end

function input(
    equation::Array{Symbol},
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing};
    datanames::Union{Array, Array{Symbol, 1}, Nothing}=nothing,
    method::Union{Symbol, String}=METHOD_DEFAULT,
    intercept::Bool=INTERCEPT_DEFAULT,
    time::Union{Symbol, String, Nothing}=TIME_DEFAULT,
    panel::Union{Symbol, String, Nothing}=PANEL_DEFAULT,
    removeoutliers::Bool=REMOVEOUTLIERS_DEFAULT,
    seasonaladjustment::Union{Dict, Nothing}=SEASONALADJUSTMENT_DEFAULT,
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

    if !GlobalSearchRegression.in_vector(equation, datanames)
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
        panel=panel,
        removeoutliers=removeoutliers,
        seasonaladjustment=seasonaladjustment,
        removemissings=removemissings
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
    removeoutliers::Bool=REMOVEOUTLIERS_DEFAULT,
    seasonaladjustment::Union{Dict, Nothing}=SEASONALADJUSTMENT_DEFAULT,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )
    
    datatype = method == :precise ? Float64 : Float32
    temp_equation = equation

    if panel != nothing && GlobalSearchRegression.get_column_index(panel, temp_equation) == nothing
        temp_equation = vcat(temp_equation, panel)
    end

    if time != nothing && GlobalSearchRegression.get_column_index(time, temp_equation) == nothing
        temp_equation = vcat(temp_equation, time)
    end

    (data, datanames) = filter_data_by_selected_columns(data, temp_equation, datanames)
    data = sort_data(data, datanames, panel=panel, time=time)
    
    panel_data = nothing
    if panel != nothing
        if validate_panel(data, datanames, panel=panel)
            panel_data = data[:, GlobalSearchRegression.get_column_index(panel, datanames)]
        else
            error(PANEL_ERROR)
        end
    end
    
    time_data = nothing
    if time != nothing
        if validate_time(data, datanames, panel=panel, time=time)
            time_data = data[:, GlobalSearchRegression.get_column_index(time, datanames)]
        else
            error(TIME_ERROR)
        end
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

    if removeoutliers
        remove_outliers(data)
    end

    if seasonaladjustment != nothing
        seasonal_adjustments(data, seasonaladjustment, datanames)
    end
    
    depvar_data = data[1:end, 1]
    expvars_data = data[1:end, 2:end]

    if removemissings
        depvar_data, expvars_data, panel_data, time_data = GlobalSearchRegression.filter_raw_data_by_empty_values(datatype, depvar_data, expvars_data, panel_data, time_data)
    end

    depvar_data, expvars_data, panel_data, time_data = GlobalSearchRegression.convert_raw_data(datatype, depvar_data, expvars_data, panel_data, time_data)

    nobs = size(depvar_data, 1)

    return GlobalSearchRegression.GSRegData(
        equation,
        depvar,
        expvars,
        panel,
        time,
        depvar_data,
        expvars_data,
        panel_data,
        time_data,
        intercept,
        datatype,
        removemissings,
        nobs
    )
end
