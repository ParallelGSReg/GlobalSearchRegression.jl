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
Sorts data
"""
function sort_data(data, datanames; time=nothing, panel=nothing)
    time_pos = get_column_index(time, datanames)
    panel_pos = get_column_index(panel, datanames)

    # TODO: readability vs simplicity
    if isa(data, DataFrames.DataFrame)
        if time_pos != nothing && panel_pos != nothing
            sort!(data, [panel_pos, time_pos])
        elseif panel_pos != nothing
            sort!(data, [panel_pos])
        elseif time_pos != nothing
            sort!(data, [time_pos])
        end
    elseif isa(data, Array)
        if time_pos != nothing && panel_pos != nothing
            data = sortslices(data, by=x->(x[panel_pos], x[time_pos]), dims=1)
        elseif panel_pos != nothing
            data = sortslices(data, by=x->(x[panel_pos]), dims=1)
        elseif time_pos != nothing
            data = sortslices(data, by=x->(x[time_pos]), dims=1)
        end
    end
    return data
end

"""
Filter data by selected columns
"""
function filter_data_by_selected_columns(data, equation, datanames)
    if isa(data, DataFrames.DataFrame)
        data = data[equation]
        datanames = datanames[[ get_column_index(eq, datanames) for eq in equation ]]
    elseif isa(data, Array)
        columns = []
        for i = 1:length(equation)
            append!(columns, get_column_index(equation[i], datanames))
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
function parse_fe_variables(fe_vars, expvars, datanames; include_depvar=false, is_pair=false)
    
    if include_depvar
        valid_vars = datanames
    else
        valid_vars = expvars
    end

    selected_vars = []

    if is_pair
        if isa(fe_vars, Pair)
            fe_vars = [fe_vars]
        end
    
        vars = []
        for var in fe_vars
            vars = vcat(vars, [Symbol(var[1])=>var[2]])
            selected_vars = append!(selected_vars, [Symbol(var[1])])
        end

        fe_vars = vars
    else
        if !isa(fe_vars, Array)
            fe_vars = [fe_vars]
        end

        fe_vars = [Symbol(s) for s in fe_vars ]
        selected_vars = fe_vars
    end

    if !in_vector(selected_vars, valid_vars)
        error(SOME_VARIABLES_NOT_FOUND)
    end

    return fe_vars
end

"""
Adds square feature extraction to data
"""
function data_add_fe_sqr(data, fe_vars, expvars, datanames)
    data = hcat(data, (data[:, [ get_column_index(var, datanames) for var in fe_vars ]]).^2)
    expvars = vcat(expvars, [Symbol(string(var, "_sqrt")) for var in fe_vars ])
    datanames = vcat(datanames, [Symbol(string(var, "_sqrt")) for var in fe_vars ])
    return (data, expvars, datanames)
end

"""
Adds log feature extraction to data
"""
function data_add_fe_log(data, fe_vars, expvars, datanames)
    data = hcat(data, log.(data[:, [ get_column_index(var, datanames) for var in fe_vars ]]))
    expvars = vcat(expvars, [Symbol(string(var, "_log")) for var in fe_vars ])
    datanames = vcat(datanames, [Symbol(string(var, "_log")) for var in fe_vars ])
    return (data, expvars, datanames)
end

"""
Adds inverse feature extraction to data
"""
function data_add_fe_inv(data, fe_vars, expvars, datanames)
    data = hcat(data, 1 ./data[:, [ get_column_index(var, datanames) for var in fe_vars ]])
    expvars = vcat(expvars, [Symbol(string(var, "_inv")) for var in fe_vars ])
    datanames = vcat(datanames, [Symbol(string(var, "_inv")) for var in fe_vars ])
    return (data, expvars, datanames)
end

"""
Adds lag feature extraction to data
"""
function data_add_fe_lag(data, fe_vars, expvars, datanames; panel=nothing)
    nobs = size(data, 1)

    # TODO: Merge solutions
    if panel == nothing
        for var in fe_vars
            col = get_column_index(var[1], datanames)
            var_data = Array{Union{Missing, Float64}}(missing, nobs, var[2])       
            for i = 1:var[2]
                var_data[:, i] = lag(data[:, col], i)
                expvars = vcat(expvars, [Symbol(string(var[1], "_l", i))])
                datanames = vcat(datanames, [Symbol(string(var[1], "_l", i))])
            end
            data = hcat(data, var_data)
        end
    else 
        panel_index = get_column_index(panel, datanames)
        if panel == nothing
            csis = 0
        else
            csis = unique(data[:, panel_index])
        end
        for var in fe_vars
            col = get_column_index(var[1], datanames)
            var_data = Array{Union{Missing, Float64}}(missing, nobs, var[2])
            for i = 1:var[2]
                for csi in csis
                    rows = findall(x->x == csi, data[:,panel_index])
                    num_rows = size(rows, 1)
                    var_data[rows[1]:rows[1]+num_rows-1, i] = lag(data[rows[1]:rows[1]+num_rows-1, col], i)
                end
                expvars = vcat(expvars, [Symbol(string(var[1], "_l", i))])
                datanames = vcat(datanames, [Symbol(string(var[1], "_l", i))])
            end
            data = hcat(data, var_data)
        end
    end
    return (data, expvars, datanames)
end

"""
Adds interaction between variables
"""
function data_add_interaction(data, interaction, depvar, expvars, datanames, equation)
    if get_column_index(depvar, interaction) != nothing
        error(INTERACTION_DEPVAR_ERROR)
    end
    
    if !in_vector(interaction, equation)
        error(INTERACTION_EQUATION_ERROR)
    end

    nobs = size(data, 1)
    num_variables = size(interaction, 1)
    comb = binomial(num_variables, 2)
    var_data = Array{Union{Missing, Float64}}(missing, nobs, comb)
    
    pos = 1
    for i = 1:num_variables-1
        for j = i+1:num_variables
            var_data[:,pos] = data[:, get_column_index(interaction[i], datanames)] .* data[:, get_column_index(interaction[j], datanames)]
            expvars = vcat(expvars, [Symbol(string(interaction[i], "_", interaction[j]))])
            datanames = vcat(datanames, [Symbol(string(interaction[i], "_", interaction[j]))])
            pos = pos + 1
        end
    end

    data = hcat(data, var_data)
    return (data, expvars, datanames)
end

"""
Converts data using fixedeffect
"""
function data_convert_fixedeffect(data, panel, datanames)
    panel_index = get_column_index(panel, datanames)
    csis = unique(data[:, panel_index])
    for csi in csis
        rows = findall(x->x == csi, data[:,panel_index])
        for dataname in datanames
            if dataname != :_cons && dataname != panel
                dataname_index = get_column_index(dataname, datanames)
                data[rows,dataname_index]= data[rows,dataname_index] .- mean(data[rows,dataname_index])
            end
        end
    end
    return data
end
