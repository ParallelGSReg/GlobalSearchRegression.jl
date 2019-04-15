function datatransformation(
    equation::String;
    data=nothing,
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT
    )

    return datatransformation(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time
    )
end

function datatransformation(
    equation::String,
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT
    )

    equation = equation_str_to_strarr(equation)

    return datatransformation(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time
    )
end

function datatransformation(
    equation::Array{String},
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT
    )

    datanames = get_datanames_from_data(data, datanames)
    equation = equation_strarr_to_symarr(equation, datanames)

    if isempty(equation)
        error(VARIABLES_NOT_OR_VALID_OR_NOT_DEFINED)
    end

    return datatransformation(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time
    )
end

function datatransformation(
    equation::Array{Symbol},
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT
    )

    datanames = datanames_strarr_to_symarr!(datanames)
    if time != nothing && time ∉ datanames
        error(TIME_VARIABLE_INEXISTENT)
    end
    
    depvar = equation[1]
    expvars = equation[2:end]
    data = convert_if_is_tuple_to_array(data, datanames)

    equation_time = equation
    if time != nothing && findfirst(isequal(time), equation_time) == nothing
        equation_time = vcat(equation_time, time)
    end
    (data, datanames) = filter_data_valid_columns(data, equation_time, datanames)

    if time != nothing
        data = sort_data_by_time(data, time, datanames)
    end
    
    (data, datanames) = filter_data_valid_columns(data, equation, datanames)
    data = filter_rows_with_empty_values(data)
    data = convert_if_is_dataframe_to_array(data)
    
    return datatransformation(
        equation,
        data,
        datanames;
        intercept=intercept,
        method=method,
        time=time
    )
end

function datatransformation(
    equation::Array{Symbol},
    data,
    datanames::Array;
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT
    )

    if method == "precise"
        datatype = Float64
    elseif method == "fast"
        datatype = Float32
    else
        error(METHOD_INVALID)
    end

    if !isa(data, Array{datatype})
        data = convert(Array{datatype}, data)
    end

    if !in_vector(equation, datanames)
        error(SELECTED_VARIABLES_DOES_NOT_EXISTS)
    end

    depvar = equation[1]
    expvars = equation[2:end]

    nobs = size(data, 1)
    if intercept
        data = Array{datatype}(hcat(data, ones(nobs)))
        push!(expvars, :_cons)
        push!(datanames, :_cons)
    end

    return GSRegData(
        depvar,
        expvars,
        data,
        intercept,
        time,
        datanames,
        datatype,
        nobs
    )
end
