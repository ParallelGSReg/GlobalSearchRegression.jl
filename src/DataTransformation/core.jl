function datatransformation(
    equation::String;
    data=nothing,
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    panel=PANEL_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing,
    fixedeffect=FIXED_EFFECT_DEFAULT
    )

    return datatransformation(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time,
        panel=panel,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        fixedeffect=fixedeffect
    )
end

function datatransformation(
    equation::String,
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    panel=PANEL_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing,
    fixedeffect=FIXED_EFFECT_DEFAULT
    )

    equation = equation_converts_str_to_strarr!(equation)

    return datatransformation(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        method=method,
        time=time,
        panel=panel,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        fixedeffect=fixedeffect
    )
end

function datatransformation(
    equation::Array{String},
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    panel=PANEL_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing,
    fixedeffect=FIXED_EFFECT_DEFAULT
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
        panel=panel,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        fixedeffect=fixedeffect
    )
end

function datatransformation(
    equation::Array{Symbol},
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    panel=PANEL_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing,
    fixedeffect=FIXED_EFFECT_DEFAULT
    )
    
    if datanames == nothing
        datanames = get_datanames_from_data(data, datanames)
    end

    datanames = strarr_to_symarr!(datanames)
    
    if time != nothing && get_column_index(time, datanames) == nothing
        error(TIME_VARIABLE_INEXISTENT)
    end

    temp_equation = equation
    if time != nothing && get_column_index(time, temp_equation) == nothing
        temp_equation = vcat(temp_equation, time)
    end

    if panel != nothing && get_column_index(panel, temp_equation) == nothing
        temp_equation = vcat(temp_equation, panel)
    end

    (data, datanames) = filter_data_by_selected_columns(data, temp_equation, datanames)

    data = sort_data(data, datanames, panel=panel, time=time)

    return datatransformation(
        equation,
        data,
        datanames;
        intercept=intercept,
        method=method,
        time=time,
        panel=panel,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        fixedeffect=fixedeffect
    )
end

function datatransformation(
    equation::Array{Symbol},
    data,
    datanames::Array;
    intercept=INTERCEPT_DEFAULT,
    method=METHOD_DEFAULT,
    time=TIME_DEFAULT,
    panel=PANEL_DEFAULT,
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing,
    fixedeffect=FIXED_EFFECT_DEFAULT
    )

    depvar = equation[1]
    expvars = equation[2:end]

    data = get_data_from_data(data)
    
    method = Symbol(lowercase(string(method)))

    if method == :precise
        datatype = Float64
    elseif method == :fast
        datatype = Float32
    else
        error(INVALID_METHOD)
    end

    if !isa(data, Array{datatype})
        data = convert(Array{datatype}, data)
    end
    
    nobs = size(data, 1)  

    if intercept
        data = hcat(data, ones(nobs))
        push!(expvars, :_cons)
        push!(datanames, :_cons)
    end

    if fe_sqr != nothing
        fe_sqr = parse_fe_variables(fe_sqr, expvars, datanames)
        data, expvars, datanames = data_add_fe_sqr(data, fe_sqr, expvars, datanames)
    end

    if fe_log != nothing
        fe_log = parse_fe_variables(fe_log, expvars, datanames)
        data, expvars, datanames = data_add_fe_log(data, fe_log, expvars, datanames)
    end

    if fe_inv != nothing
        fe_inv = parse_fe_variables(fe_inv, expvars, datanames)
        data, expvars, datanames = data_add_fe_inv(data, fe_inv, expvars, datanames)
    end

    if panel != nothing && fixedeffect
        data = data_convert_fixedeffect(data, panel, datanames)
    end
    
    #if fe_lag != nothing
    #    fe_lag = parse_fe_variables(fe_lag, expvars, datanames, include_depvar=true, is_pair=true)
    #    data, expvars, datanames = data_add_fe_lag(data, fe_lag, expvars, datanames)
    #end

    (data, datanames) = filter_data_by_selected_columns(data, vcat([depvar], expvars), datanames)

    data = filter_data_by_empty_values(data)

    if !in_vector(equation, datanames)
        error(SELECTED_VARIABLES_DOES_NOT_EXISTS)
    end

    depvar_data = data[1:end, 1]
    expvars_data = data[1:end, 2:end]

    nobs = size(data, 1)

    return GlobalSearchRegression.GSRegData(
        depvar,
        expvars,
        depvar_data,
        expvars_data,
        intercept,
        time,
        panel,
        datatype,
        nobs,
        fe_sqr,
        fe_log,
        fe_inv,
        fe_lag
    )
end
