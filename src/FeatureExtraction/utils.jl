"""
Parse fe variables
"""
function parse_fe_variables(fe_vars, expvars; depvar=nothing, is_pair=false)
    valid_vars = expvars

    if depvar != nothing
        append!(valid_vars, depvar)
    end

    selected_vars = []

    if is_pair
        vars = []
        if isa(fe_vars, Pair)
            fe_vars = [fe_vars]
        end
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
function data_add_fe_sqr(data, fe_vars)
    data.expvars_data = hcat(data.expvars_data, (data.expvars_data[:, [ get_column_index(var, data.expvars) for var in fe_vars ]]).^2)
    data.expvars = vcat(data.expvars, [Symbol(string(var, "_sqrt")) for var in fe_vars ])
    return data
end

"""
Adds log feature extraction to data
"""
function data_add_fe_log(data, fe_vars)
    try
        data.expvars = vcat(data.expvars, [Symbol(string(var, "_log")) for var in fe_vars ])
        data.expvars_data = hcat(data.expvars_data, log.(data.expvars_data[:, [ get_column_index(var, data.expvars) for var in fe_vars ]]))
        return data
    catch
        error(LOG_FUNCTION_ERROR)
    end
end

"""
Adds inverse feature extraction to data
"""
function data_add_fe_inv(data, fe_vars)
    data.expvars = vcat(data.expvars, [Symbol(string(var, "_inv")) for var in fe_vars ])
    data.expvars_data = hcat(data.expvars_data, 1 ./ (data.expvars_data[:, [ get_column_index(var, data.expvars) for var in fe_vars ]]))
    return data
end

"""
Adds lag feature extraction to data
"""
function data_add_fe_lag(data, fe_vars)
    nobs = size(data.expvars_data, 1)

    # TODO: Merge solutions
    if panel == nothing
        for var in fe_vars
            col = get_column_index(var[1], data.expvars) 
            var_data = Array{Union{Missing, Float64}}(missing, nobs, var[2])       
            for i = 1:var[2]
                var_data[:, i] = lag(data.expvars_data[:, col], i)
                data.expvars = vcat(data.expvars, [Symbol(string(var[1], "_l", i))])
            end
            data.expvars_data = hcat(data.expvars, var_data)
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
function data_add_interaction(data, interaction)
    if get_column_index(data.depvar, interaction) != nothing
        error(INTERACTION_DEPVAR_ERROR)
    end
    
    if !in_vector(interaction, data.expvars)
        error(INTERACTION_EQUATION_ERROR)
    end

    nobs = size(data.expvars_data, 1)
    num_variables = size(interaction, 1)
    comb = binomial(num_variables, 2)
    var_data = Array{Union{Missing, Float64}}(missing, nobs, comb)
    
    pos = 1
    for i = 1:num_variables-1
        for j = i+1:num_variables
            var_data[:,pos] = data.expvars_data[:, get_column_index(interaction[i], expvars)] .* data.expvars_data[:, get_column_index(interaction[j], datanames)]
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

