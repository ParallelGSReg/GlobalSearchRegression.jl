function in_vector(sub_vector, vector)
    for sv in sub_vector
        if !in(sv, vector)
            return false
        end
    end
    return true
end

function equation_str_to_strarr(equation)
    if occursin("~", equation)
        equation = replace(equation, r"\s+|\s+$/g" => " ")
        dep_indep = split(equation, "~")
        equation = [String(strip(ss)) for ss in vcat(dep_indep[1], split(dep_indep[2], "+"))]
    else
        equation = [String(strip(ss)) for ss in split(replace(equation, r"\s+|\s+$/g" => ","), ",")]
    end
    return equation
end

function equation_strarr_to_symarr(equation, datanames)
    n_equation = []
    for e in equation
        e = replace(e, "." => "*")
        if e[end] == '*'
            datanames_arr = vec([String(key)[1:length(e[1:end - 1])] == e[1:end - 1] ? String(key) : nothing for key in datanames])
            append!(n_equation, filter!(x->x != nothing, datanames_arr))
        else
            append!(n_equation, [e])
        end
    end
    return map(Symbol, unique(n_equation))
end

function get_datanames_from_data(data, datanames)
    if isa(data, DataFrames.DataFrame)
        datanames = names(data)
    elseif isa(data, Tuple)
        datanames = data[2]
    elseif (datanames == nothing)
        error(DATANAMES_REQUIRED)
    end
    return datanames
end

function datanames_strarr_to_symarr!(datanames)
    dn = datanames
    datanames = []
    for name in dn
        push!(datanames, Symbol(name))
    end
    return datanames
end

function convert_if_is_tuple_to_array(data, datanames)
    if isa(data, Tuple)
        data = data[1]
    end
    return data
end

function convert_if_is_dataframe_to_array(data)
    if isa(data, DataFrames.DataFrame)
        data = convert(Array{Float64}, data)
    end
    return data
end

function filter_data_valid_columns(data, equation, datanames)
    if isa(data, DataFrames.DataFrame)
        data = data[equation]
        filter!(in(equation), datanames)
    elseif isa(data, Array)
        columns = []
        for i = 1:length(equation)
            append!(columns, get_data_column_pos(equation[i], datanames))
        end
        data = data[:,columns]
        datanames = datanames[columns]
    end
    return (data, datanames)
end

function sort_data_by_time(data, time, datanames)
    pos = findfirst(isequal(time), datanames)
    if isa(data, DataFrames.DataFrame)
        sort!(data, (pos))
    elseif isa(data, Array)
        data = gsregsortrows(data, [pos])
    end
    return data
end

function filter_rows_with_empty_values(data)
    if isa(data, DataFrames.DataFrame)
        data = data[completecases(data), :]
    elseif isa(data, Array{Union{Missing, Float64},2})
        for i = 1:size(data, 2)
            data = data[map(b->!b, ismissing.(data[:,i])), :]
        end
    elseif isa(data, Array)
        for i = 1:size(data, 2)
            data = data[data[:,i] .!= "", :]
        end
    end
    return data
end

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
