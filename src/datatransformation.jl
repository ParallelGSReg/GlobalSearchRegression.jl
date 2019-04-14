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

    # TODO: Refactor equation functions
    datanames = get_datanames_from_data(data, datanames)
    equation = equation_strarr_to_symarr(equation, datanames)

    # TODO: Refactor equation functions
    if isempty(equation)
        error(VARIABLES_NOT_OR_VALID_OR_NOT_DEFINED)
    end

    return equation
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

    # TODO: Refactor equation functions
    datanames = datanames_strarr_to_symarr!(datanames)
    depvar = equation[1]
    expvars = equation[2:end]
    data = convert_if_is_tuple_to_array(data, datanames)

    if time != nothing
        data = sort_data_by_time(data, time, datanames)
    end

    data = filter_data_valid_columns(data, depvar, expvars, datanames)
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

function gsreg(
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

    if outsample != OUTSAMPLE_DEFAULT
        if outsample < 0
            error(OUTSAMPLE_LOWER_VALUE)
        elseif size(data, 1) - outsample < INSAMPLE_MIN_SIZE + size(data, 2) - 1
            error(OUTSAMPLE_HIGHER_VALUE)
        end
    end

    if outsample == false && :rmseout in criteria
        error(OUTSAMPLE_MISMATCH)
    end

    if criteria == CRITERIA_DEFAULT
        if outsample != OUTSAMPLE_DEFAULT
            criteria = CRITERIA_DEFAULT_OUTSAMPLE
        else
            criteria = CRITERIA_DEFAULT_INSAMPLE
        end
    end

    if time != nothing && time ∉ datanames
        error(TIME_VARIABLE_INEXISTENT)
    end

    if resultscsv != csv
        if resultscsv != CSV_DEFAULT && csv != CSV_DEFAULT
            error(CSV_DUPLICATED_PARAMETERS)
        elseif csv != CSV_DEFAULT
            resultscsv = csv
        end
    end

    # TODO: Is this been used?
    if parallel != nothing
        if parallel > nworkers()
            error("Number of parallel workers can not exceed available cores. Use addprocs()")
        end

        if parallel < 1
            error("Number of workers can not be less than 1")
        end
    end

    if size(data, 1) < size(equation[2:end], 1) + 1
        error(NO_ENOUGH_OBSERVATIONS)
    end

    if !in_vector(equation, datanames)
        error(SELECTED_VARIABLES_DOES_NOT_EXISTS)
    end

    depvar = equation[1]
    expvars = equation[2:end]

    return result
end
