"""
Returns if a vector is inside another vector
"""
function in_vector(sub_vector, vector)
    for sv in sub_vector
        if !in(sv, vector)
            return false
        end
    end
    return true
end

"""
Gets array column index by a name
"""
function get_column_index(name, names)
    return findfirst(isequal(name), names)
end

"""
Filter rawdata by empty values
"""
function filter_raw_data_by_empty_values(depvar_data, expvars_data, panel_data=nothing, time_data=nothing)
    keep_rows = Array{Bool}(undef, size(depvar_data, 1))
    keep_rows .= true
    keep_rows .&= map(b->!b, ismissing.(depvar_data))

    for i = 1:size(expvars_data, 2)
        keep_rows .&= map(b->!b, ismissing.(expvars_data[:, i]))
    end
    
    depvar_data = depvar_data[keep_rows, 1]
    expvars_data = expvars_data[keep_rows, :]

    if panel_data != nothing
        panel_data = panel_data[keep_rows, 1]
    end

    if time_data != nothing
        time_data = time_data[keep_rows, 1]
    end

    return depvar_data, expvars_data, panel_data, time_data
end

"""
Filter data by empty values
"""
function filter_data_by_empty_values(data)
    depvar_data, expvars_data, panel_data, time_data = filter_raw_data_by_empty_values(
        data.depvar_data,
        data.expvars_data,
        data.panel_data,
        data.time_data
    )

    data.depvar_data = depvar_data
    data.expvars_data = expvars_data
    data.panel_data = panel_data
    data.time_data = time_data

    return data
end

"""
Convert column by data content
"""
function convert_column(datatype, column)
    if column != nothing
        has_missings = false
        
        if size(column, 2) == 1
            has_missings |= findfirst(x -> ismissing(x), column) != nothing
        else
            for i in 1:size(column, 2)
                has_missings |= findfirst(x -> ismissing(x), column[:,i]) != nothing
            end
        end


        if has_missings
            return convert(Array{Union{Missing, datatype}}, column)
        else
            return convert(Array{datatype}, column)
        end
    end
    return nothing
end

"""
Convert rawdata by data content
"""
function convert_raw_data(datatype, depvar_data, expvars_data, panel_data=nothing, time_data=nothing)
    depvar_data = convert_column(datatype, depvar_data)
    expvars_data = convert_column(datatype, expvars_data)
    panel_data = convert_column(datatype == Float64 ? Int64 : Int32, panel_data)
    time_data = convert_column(datatype, time_data)

    return depvar_data, expvars_data, panel_data, time_data
end

"""
Convert data by data
"""
function convert_data(data)
    depvar_data, expvars_data, panel_data, time_data = convert_raw_data(
        data.datatype,
        data.depvar_data,
        data.expvars_data,
        data.panel_data,
        data.time_data
    )
    data.depvar_data = depvar_data
    data.expvars_data = expvars_data
    data.panel_data = panel_data
    data.time_data = time_data

    return data
end


# OLD

"""
Returns the position of the header value based on this structure.
    - Index
    - Covariates
        * b
        * bstd
        * T-test
    - Equation general information merged with criteria user-defined options.
    - Order from user combined criteria
    - Weight
"""
function get_data_position(name, expvars, intercept, ttest, residualtest, time, criteria)
    data_cols_num = length(expvars)
    mult_col = (ttest == true) ? 3 : 1

    # INDEX
    if name == INDEX
        return 1
    end
    displacement = 1
    displacement += mult_col * (data_cols_num) + 1

    # EQUATION_GENERAL_INFORMATION
    testfields = (residualtest != nothing && residualtest) ? ((time != nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS) : []
    equation_general_information_and_criteria = unique([ EQUATION_GENERAL_INFORMATION; criteria; testfields ])
    if name in equation_general_information_and_criteria
        return displacement + findfirst(isequal(name), equation_general_information_and_criteria) - 1
    end
    displacement += length(equation_general_information_and_criteria)

    if name == ORDER
        return displacement
    end
    displacement += 1

    if name == WEIGHT
        return displacement
    end
    displacement = 1

    # Covariates
    string_name = string(name)
    base_name = Symbol(replace(replace(replace(string_name, "_bstd" => ""), "_t" => ""), "_b" => ""))
    if base_name in expvars
        displacement = displacement + (findfirst(isequal(base_name), expvars) - 1) * mult_col
        if occursin("_bstd", string_name)
            return displacement + 2
        end
        if occursin("_b", string_name)
            return displacement + 1
        end
        if occursin("_t", string_name)
            return displacement + 3
        end
    end
end


function export_csv(io::IO, result::GSRegResult)
    head = []
    for elem in sort(collect(Dict(value => key for (key, value) in result.header)))
         push!(head, elem[2])
    end
    writedlm(io, [head], ',')
    writedlm(io, result.results, ',')
end

"""
Exports main results with headers to file
"""
function export_csv(output::String, result::GSRegResult)
    file = open(output, "w")
    export_csv(file, result)
    close(file)
end

function get_data_column_pos(name, datanames)
    return findfirst(x -> name==x, datanames)
end
