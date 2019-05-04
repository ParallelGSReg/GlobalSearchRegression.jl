"""
Converts and returns an array of string to an array of Symbol
"""
function strarr_to_symarr!(arr)
    return arr = [ Symbol(str) for str in arr ]
end

"""
Converts and returns an equation string to an array of variables as string 
"""
function equation_converts_str_to_strarr!(equation)
    if occursin("~", equation)
        vars = split(replace(equation, r"\s+|\s+$/g" => " "), "~")
        equation = [String(strip(var)) for var in vcat(vars[1], split(vars[2], "+"))]
    else
        equation = [String(strip(var)) for var in split(replace(equation, r"\s+|\s+$/g" => ","), ",")]
    end
    return equation
end

"""
Converts and returns a strarr equation with wildcards to a strarr with wildcards processed
"""
function equation_converts_wildcards!(equation, names)
    new_equation = []
    for e in equation
        e = replace(e, "." => "*")
        if e[end] == '*'
            datanames_arr = vec([String(key)[1:length(e[1:end - 1])] == e[1:end - 1] ? String(key) : nothing for key in names])
            append!(new_equation, filter!(x->x != nothing, datanames_arr))
        else
            append!(new_equation, [e])
        end
    end
    equation = unique(new_equation)
    return equation
end

"""
Gets datanames from data DataFrame or data Tuple
"""
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

"""
Gets datanames from data DataFrame or data Tuple
"""
function get_data_from_data(data)
    if isa(data, DataFrames.DataFrame)
        data = convert(Array{Union{Missing, Float64}}, data)
    elseif isa(data, Tuple)
        data = data[1]
    end
    return data
end

"""
Sorts data by time
"""
function sort_data_by_time(data, time, datanames)
    pos = findfirst(isequal(time), datanames)
    if isa(data, DataFrames.DataFrame)
        sort!(data, (pos))
    elseif isa(data, Array)
        data = gsregsortrows(data, [pos])
    end
    return data
end

"""
Filter data by selected columns
"""
function filter_data_by_selected_columns(data, equation, datanames)
    if isa(data, DataFrames.DataFrame)
        data = data[equation]
        datanames = datanames[[ findfirst(isequal(eq), datanames) for eq in equation ]]
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

"""
Filter data by empty values
"""
function filter_data_by_empty_values(data)
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

"""
Parse fe variables
"""
function parse_fe_variables(fe_vars, expvars; is_pair=false)
    if is_pair
        if isa(fe_vars, Pair)
            fe_vars = [fe_vars]
        end
    
        vars = []
        for var in fe_vars
            vars = vcat(vars, [Symbol(var[1])=>var[2]])
        end

        fe_vars = vars
    
        for var in fe_vars       
            if findfirst(isequal(var[1]), expvars) == nothing
                error(SOME_VARIABLES_NOT_FOUND)
            end
        end
    else
        if !isa(fe_vars, Array)
            fe_vars = [fe_vars]
        end

        fe_vars = [Symbol(s) for s in fe_vars ]

        for var in fe_vars
            if findfirst(isequal(var), expvars) == nothing
                error(SOME_VARIABLES_NOT_FOUND)
            end
        end
    end

    return fe_vars
end

"""
Adds square feature extraction to data
"""
function data_add_fe_sqr(data, fe_vars, expvars, datanames)
    data = hcat(data, (data[:, [ findfirst(isequal(var), datanames) for var in fe_vars ]]).^2)
    expvars = vcat(expvars, [Symbol(string(var, "_sqrt")) for var in fe_vars ])
    return (data, expvars)
end

"""
Adds log feature extraction to data
"""
function data_add_fe_log(data, fe_vars, expvars, datanames)
    data = hcat(data, log.(data[:, [ findfirst(isequal(var), datanames) for var in fe_vars ]]))
    expvars = vcat(expvars, [Symbol(string(var, "_log")) for var in fe_vars ])
    return (data, expvars)
end

"""
Adds inverse feature extraction to data
"""
function data_add_fe_inv(data, fe_vars, expvars, datanames)
    data = hcat(data, 1 ./data[:, [ findfirst(isequal(var), datanames) for var in fe_vars ]])
    expvars = vcat(expvars, [Symbol(string(var, "_inv")) for var in fe_vars ])
    return (data, expvars)
end

function data_add_fe_lag(data, fe_vars, expvars, datanames)
    nobs = size(data, 1)
    for var in fe_vars
        col = findfirst(isequal(var[1]), datanames)
        var_data = Array{Union{Missing, Float64}}(missing, nobs, var[2])       
        for i = 1:var[2]
            var_data[i+1:end, i] = data[1:end-i,col]
            expvars = vcat(expvars, [Symbol(string(var[1], "_l", i))])
        end
        data = hcat(data, var_data)
    end
    return (data, expvars)
end