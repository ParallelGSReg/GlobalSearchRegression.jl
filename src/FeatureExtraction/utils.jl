"""
Parse fe variables
"""
function parse_fe_variables(fe_vars, expvars; depvar=nothing, is_pair=false)
    valid_vars = copy(expvars)

    if depvar != nothing
        append!(valid_vars, [depvar])
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

    if !GlobalSearchRegression.in_vector(selected_vars, valid_vars)
        error(SOME_VARIABLES_NOT_FOUND)
    end

    return fe_vars
end

"""
Adds square feature extraction to data
"""
function data_add_fe_sqr(data, fe_vars)
    postfix = "_sqrt"
    new_vars = []
    existent_vars = []
    for fe_var in fe_vars
        if !(Symbol(string(fe_var, postfix)) in data.expvars)
            append!(new_vars, [fe_var])
        else
            append!(existent_vars, [fe_var])
        end
    end

    if size(new_vars, 1) > 0
        data.expvars_data = hcat(data.expvars_data, (data.expvars_data[:, [ GlobalSearchRegression.get_column_index(var, data.expvars) for var in new_vars ]]).^2)
        data.expvars = vcat(data.expvars, [Symbol(string(var, postfix)) for var in new_vars ])
    end

    if size(existent_vars, 1) > 0
        data.expvars_data[:, [ GlobalSearchRegression.get_column_index(Symbol(string(var, postfix)), data.expvars) for var in existent_vars ]] = data.expvars_data[:, [ GlobalSearchRegression.get_column_index(var, data.expvars) for var in existent_vars ]].^2
    end

    return data
end

"""
Adds log feature extraction to data
"""
function data_add_fe_log(data, fe_vars)
    try
        postfix = "_log"
        new_vars = []
        existent_vars = []
        for fe_var in fe_vars
            if !(Symbol(string(fe_var, postfix)) in data.expvars)
                append!(new_vars, [fe_var])
            else
                append!(existent_vars, [fe_var])
            end
        end

        if size(new_vars, 1) > 0
            data.expvars_data = hcat(data.expvars_data, log.(data.expvars_data[:, [ GlobalSearchRegression.get_column_index(var, data.expvars) for var in new_vars ]]))
            data.expvars = vcat(data.expvars, [Symbol(string(var, postfix)) for var in new_vars ])
        end

        if size(existent_vars, 1) > 0
            data.expvars_data[:, [ GlobalSearchRegression.get_column_index(Symbol(string(var, postfix)), data.expvars) for var in existent_vars ]] = log.(data.expvars_data[:, [ GlobalSearchRegression.get_column_index(var, data.expvars) for var in existent_vars ]])
        end
        return data
    catch
        error(LOG_FUNCTION_ERROR)
    end
end

"""
Adds inverse feature extraction to data
"""
function data_add_fe_inv(data, fe_vars)
    postfix = "_inv"
    new_vars = []
    existent_vars = []
    for fe_var in fe_vars
        if !(Symbol(string(fe_var, postfix)) in data.expvars)
            append!(new_vars, [fe_var])
        else
            append!(existent_vars, [fe_var])
        end
    end

    if size(new_vars, 1) > 0
        data.expvars_data = hcat(data.expvars_data, 1 ./ (data.expvars_data[:, [ GlobalSearchRegression.get_column_index(var, data.expvars) for var in new_vars ]]))
        data.expvars = vcat(data.expvars, [Symbol(string(var, postfix)) for var in new_vars ])
    end

    if size(existent_vars, 1) > 0
        data.expvars_data[:, [ GlobalSearchRegression.get_column_index(Symbol(string(var, postfix)), data.expvars) for var in existent_vars ]] = 1 ./ (data.expvars_data[:, [ GlobalSearchRegression.get_column_index(var, data.expvars) for var in existent_vars ]])
    end
    return data
end

"""
Adds lag feature extraction to data
"""
function data_add_fe_lag(data, fe_vars)
    nobs = size(data.expvars_data, 1)
    postfix = "_l"
    csis = (data.panel != nothing) ? unique(data.panel_data) : [nothing]
    depvar_enabled = false

    for var in fe_vars
        if var[1] in data.expvars
            col = GlobalSearchRegression.get_column_index(var[1], data.expvars)
            num_cols = 0
            for i = 1:var[2]
                if !(Symbol(string(var[1], postfix, i)) in data.expvars)
                    num_cols = num_cols + 1
                end
            end
            var_data = Array{Union{Missing, data.datatype}}(missing, nobs, num_cols)
            m = 1
            for i = 1:var[2]
                expvar = Symbol(string(var[1], postfix, i))
                
                col_added = false
                for csi in csis
                    rows = (csi != nothing) ? findall(x->x == csi, data.panel_data) : collect(1:1:nobs)
                    num_rows = size(rows, 1)
                    if !(expvar in data.expvars)
                        var_data[rows[1]:rows[1]+num_rows-1, m] .= lag(data.expvars_data[rows[1]:rows[1]+num_rows-1, col], i)
                        col_added = true
                    else
                        n = GlobalSearchRegression.get_column_index(expvar, data.expvars)
                        data.expvars_data[rows[1]:rows[1]+num_rows-1, n].= lag(data.expvars_data[rows[1]:rows[1]+num_rows-1, col], i)
                    end
                end
                if col_added
                    m = m + 1
                end

                if !(expvar in data.expvars)
                    data.expvars = vcat(data.expvars, [expvar])
                end
            end
        else
            num_cols = 0
            for i = 1:var[2]
                if !(Symbol(string(var[1], postfix, i)) in data.expvars)
                    num_cols = num_cols + 1
                end
            end
            var_data = Array{Union{Missing, data.datatype}}(missing, nobs, num_cols)
            m = 1
            for i = 1:var[2]
                expvar = Symbol(string(var[1], postfix, i))
                
                col_added = false
                for csi in csis
                    rows = (csi != nothing) ? findall(x->x == csi, data.panel_data) : collect(1:1:nobs)
                    num_rows = size(rows, 1)
                    if !(expvar in data.expvars)
                        var_data[rows[1]:rows[1]+num_rows-1, m] .= lag(data.depvar_data[rows[1]:rows[1]+num_rows-1], i)
                        col_added = true
                    else
                        n = GlobalSearchRegression.get_column_index(expvar, data.expvars)
                        data.expvars_data[rows[1]:rows[1]+num_rows-1, n].= lag(data.depvar_data[rows[1]:rows[1]+num_rows-1], i)
                    end
                end
                if col_added
                    m = m + 1
                end

                if !(expvar in data.expvars)
                    data.expvars = vcat(data.expvars, [expvar])
                end
            end
        end
        if size(var_data, 2) > 0
            data.expvars_data = hcat(data.expvars_data, var_data)
        end
    end
    
    return data
end

"""
Adds interaction between variables
"""
function data_add_interaction(data, interaction)
    if GlobalSearchRegression.get_column_index(data.depvar, interaction) != nothing
        error(INTERACTION_DEPVAR_ERROR)
    end
    
    if !GlobalSearchRegression.in_vector(interaction, data.expvars)
        error(INTERACTION_EQUATION_ERROR)
    end
    
    num_variables = size(interaction, 1)
    infix = "_"
    
    for i = 1:num_variables-1
        for j = i+1:num_variables
            col = Symbol(string(interaction[i], infix, interaction[j]))
            var_1 = data.expvars_data[:, GlobalSearchRegression.get_column_index(interaction[i], data.expvars)]
            var_2 = data.expvars_data[:, GlobalSearchRegression.get_column_index(interaction[j], data.expvars)]
            res = var_1 .* var_2
            if !(col in data.expvars)
                data.expvars_data = hcat(data.expvars_data, res)
                data.expvars = vcat(data.expvars, [Symbol(string(interaction[i], infix, interaction[j]))])
            else
                data.expvars_data[:, GlobalSearchRegression.get_column_index(col, data.expvars)] = res
            end
        end
    end

    return data
end

"""
Add values to extras
"""
function addextras(data, fe_sqr, fe_log, fe_inv, fe_lag, interaction, removemissings)
    data.extras[GlobalSearchRegression.generate_extra_key(FEATUREEXTRACTION_EXTRAKEY, data.extras)] = Dict(
        :fe_sqr => fe_sqr,
        :fe_log => fe_log,
        :fe_inv => fe_inv,
        :fe_lag => fe_lag,
        :interaction => interaction,
        :removemissings => removemissings
    )
    return data
end
