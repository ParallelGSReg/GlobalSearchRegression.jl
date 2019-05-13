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
