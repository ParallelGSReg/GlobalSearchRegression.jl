function equation_str_to_strarr(equation)
    if contains(equation, "~")
        equation = replace(equation, r"\s+|\s+$/g", "")
        dep_indep = split(equation, "~")
        equation = [String(ss) for ss in vcat(dep_indep[1], split(dep_indep[2], "+"))]
    else
        equation = [String(ss) for ss in split(replace(equation, r"\s+|\s+$/g", ","), ",")]
    end
    return equation
end

function equation_strarr_to_symarr(equation, data, datanames)
    data, datanames = parse_data(data, datanames)
    n_equation = []
    for e in equation
        replace("*", ".", e)
        if e[end] == '*'
            append!(n_equation, filter!(x->x!=nothing, [String(key)[1:length(e[1:end-1])] == e[1:end-1]?String(key):nothing for key in datanames]))
        else
            append!(n_equation, [e])
        end
    end
    return map(Symbol, unique(n_equation))
end

function datanames_strarr_to_symarr!(datanames)
    dn = datanames
    datanames = []
    for name in dn
        push!(datanames, Symbol(name))
    end
    return datanames
end

function parse_data(data, datanames)
    if isa(data, DataFrames.DataFrame)
        datanames = names(data)
        data = convert(Array{Float64}, data)
    elseif isa(data, Tuple)
        datanames = data[2]
        data = data[1]
    elseif isa(data, Array{Any, 2}) && datanames != nothing
        if !isa(data, Array{Float32, 2}) && !isa(data, Array{Float64, 2})
            data = []
            datanames = []
        end
    end 
    return data, datanames
end




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
    mult_col = (ttest == true)?3:1

    # INDEX
    if name == INDEX
        return 1
    end
    displacement = 1
    displacement += mult_col * (data_cols_num) + 1

    # EQUATION_GENERAL_INFORMATION
    testfields = (residualtest!=nothing && residualtest)?((time != nothing)?RESIDUAL_TESTS_TIME:RESIDUAL_TESTS_CROSS):[]
    equation_general_information_and_criteria = unique([ EQUATION_GENERAL_INFORMATION; criteria; testfields ])
    if name in equation_general_information_and_criteria
        return displacement + findfirst(equation_general_information_and_criteria, name)-1
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
    base_name = Symbol(replace(replace(replace(string_name, "_bstd", ""), "_t", ""), "_b", ""))
    if base_name in expvars
        displacement = displacement + (findfirst(expvars, base_name)-1) * mult_col
        if contains(string_name, "_bstd")
            return displacement + 2
        end
        if contains(string_name, "_b")
            return displacement + 1
        end
        if contains(string_name, "_t")
            return displacement + 3
        end
    end

end

"""
Constructs the header for results based in get_data_position orders.
"""
function get_result_header(expvars, intercept, ttest, residualtest, time, criteria, modelavg)
    header = Dict{Symbol,Int64}()
    header[:index] = get_data_position(:index, expvars, intercept, ttest, residualtest, time, criteria)
    for expvar in expvars
        header[Symbol(string(expvar,"_b"))] = get_data_position(Symbol(string(expvar,"_b")), expvars, intercept, ttest, residualtest, time, criteria)
        if ttest
            header[Symbol(string(expvar,"_bstd"))] = get_data_position(Symbol(string(expvar,"_bstd")), expvars, intercept, ttest, residualtest, time, criteria)
            header[Symbol(string(expvar,"_t"))] = get_data_position(Symbol(string(expvar,"_t")), expvars, intercept, ttest, residualtest, time, criteria)
        end
    end

    keys = unique([ EQUATION_GENERAL_INFORMATION; criteria ])

    if residualtest != nothing && residualtest
        keys = unique([ keys; (time != nothing)?RESIDUAL_TESTS_TIME:RESIDUAL_TESTS_CROSS ])
    end

    for key in keys
        header[key] = get_data_position(key, expvars, intercept, ttest, residualtest, time, criteria)
    end

    header[:order] = get_data_position(:order, expvars, intercept, ttest, residualtest, time, criteria)
    if modelavg
        header[:weight] = get_data_position(:weight, expvars, intercept, ttest, residualtest, time, criteria)
    end
    return header
end

function in_vector(sub_vector, vector)
    for sv in sub_vector
        if !in(sv, vector)
            return false
        end
    end
    return true
end

"""
Returns selected appropiate covariates for each iteration
"""
function get_selected_cols(i)
    cols = zeros(Int64, 0)
    binary = bin(i)
    k = 2
    for i = 1:length(binary)
        if binary[length(binary) - i + 1] == '1'
            append!(cols, k)
        end
        k = k + 1
    end
    return cols
end

function export_csv(io::IO, result::GSRegResult)
    head = []
    for elem in sort(collect(Dict(value => key for (key, value) in result.header)))
         push!(head, elem[2])
    end
    writecsv(io, [head])
    writecsv(io, result.results)
end

"""
Exports main results with headers to file
"""
function export_csv(output::String, result::GSRegResult)
    file = open(output, "w")
    export_csv(file, result)
    close(file)
end
