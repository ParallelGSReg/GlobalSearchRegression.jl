function datatransformation(
    equation::String;
    data=nothing,
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing
    )

    return datatransformation(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag
    )
end

function datatransformation(
    equation::String,
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing
    )

    equation = equation_converts_str_to_strarr!(equation)

    return datatransformation(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag
    )
end

function datatransformation(
    equation::Array{String},
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing
    )

    datanames = get_datanames_from_data(data, datanames)
    equation = strarr_to_symarr!(equation_converts_wildcards!(equation, datanames))

    if isempty(equation)
        error(VARIABLES_NOT_DEFINED)
    end
    
    return datatransformation(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag
    )
end

function datatransformation(
    equation::Array{Symbol},
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing
    )
    
    if datanames == nothing
        datanames = get_datanames_from_data(data, datanames)
    end

    datanames = strarr_to_symarr!(datanames)
    
    if time != nothing && time ∉ datanames
        error(TIME_VARIABLE_INEXISTENT)
    end   

    equation_time = equation
    if time != nothing && findfirst(isequal(time), equation_time) == nothing
        equation_time = vcat(equation_time, time)
    end

    (data, datanames) = filter_data_by_selected_columns(data, equation_time, datanames)

    if time != nothing
        data = sort_data_by_time(data, time, datanames)
    end

    (data, datanames) = filter_data_by_selected_columns(data, equation, datanames)

    return datatransformation(
        equation,
        data,
        datanames;
        intercept=intercept,
        method=method,
        time=time,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag
    )
end

function datatransformation(
    equation::Array{Symbol},
    data,
    datanames::Array;
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing
    )

    depvar = equation[1]
    expvars = equation[2:end]

    data = get_data_from_data(data)
    
    nobs = size(data, 1)
    
    if intercept
        data = hcat(data, ones(nobs))
        push!(expvars, :_cons)
        push!(datanames, :_cons)
    end

    if fe_sqr != nothing
        fe_sqr = parse_fe_variables(fe_sqr, expvars)
        data, expvars = data_add_fe_sqr(data, fe_sqr, expvars, datanames)
    end

    if fe_log != nothing
        fe_log = parse_fe_variables(fe_sqr, expvars)
        data, expvars = data_add_fe_log(data, fe_log, expvars, datanames)
    end

    if fe_inv != nothing
        fe_inv = parse_fe_variables(fe_inv, expvars)
        data, expvars = data_add_fe_inv(data, fe_inv, expvars, datanames)
    end

    if fe_lag != nothing
        fe_lag = parse_fe_variables(fe_lag, expvars, is_pair=true)
        data, expvars = data_add_fe_lag(data, fe_lag, expvars, datanames)
    end
    println(expvars)

    return data

    data = filter_data_by_empty_values(data)

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

    depvar_data = data[1:end, 1]
    expvars_data = data[1:end, 2:end]

    return GSRegData(
        depvar,
        expvars,
        depvar_data,
        expvars_data,
        intercept,
        time,
        datatype,
        nobs
    )
end

function print_array(data)
    out = "──────────────────────────────────────────────────────────\n"
    nrows, ncols = size(data)
    for nrow in 1:nrows
        out *= "│ "
        for ncol in 1:ncols
            if isa(data[nrow, ncol], Float64)
                #out *= @sprintf("%-10f", data[nrow, ncol])
            else
                out *= " missing  "
            end
            out *= " │"
        end
        out *= "\n"
    end
    out*= "──────────────────────────────────────────────────────────\n"

    print(out)
end
