function get_data_position(name, expvars, intercept, ttest, criteria)
    data_cols_num = length(expvars)
    mult_col = (ttest == true)?3:1    

    # INDEX
    if name == INDEX
        return 1
    end
    displacement = 1
    displacement = displacement + mult_col * (data_cols_num) + 1

    # EQUATION_GENERAL_INFORMATION
    if name in EQUATION_GENERAL_INFORMATION
        return displacement + findfirst(EQUATION_GENERAL_INFORMATION, name)-1
    end
    displacement = displacement + length(EQUATION_GENERAL_INFORMATION)

    # ORDERING_CRITERIA
    if name in criteria
        return displacement + findfirst(criteria, name)-1
    end
    displacement = displacement + length(criteria) - 1

    # ORDER
    if name == ORDER
        return displacement + 1
    end
    displacement = 1

    # EXPVAR
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

function get_result_header(expvars, intercept, ttest, criteria)
    header = Dict{Symbol,Int64}()
    header[:index] = get_data_position(:index, expvars, intercept, ttest, criteria)
    for expvar in expvars
        header[Symbol(string(expvar,"_b"))] = get_data_position(Symbol(string(expvar,"_b")), expvars, intercept, ttest, criteria)
        if ttest
            header[Symbol(string(expvar,"_bstd"))] = get_data_position(Symbol(string(expvar,"_bstd")), expvars, intercept, ttest, criteria)
            header[Symbol(string(expvar,"_t"))] = get_data_position(Symbol(string(expvar,"_t")), expvars, intercept, ttest, criteria)
        end
    end
    header[:nobs] = get_data_position(:nobs, expvars, intercept, ttest, criteria)
    header[:ncoef] = get_data_position(:ncoef, expvars, intercept, ttest, criteria)
    header[:sse] = get_data_position(:sse, expvars, intercept, ttest, criteria)
    header[:r2] = get_data_position(:r2, expvars, intercept, ttest, criteria)
    header[:F] = get_data_position(:F, expvars, intercept, ttest, criteria)
    header[:rmse] = get_data_position(:rmse, expvars, intercept, ttest, criteria)
    header[:order] = get_data_position(:order, expvars, intercept, ttest, criteria)
    for c in criteria
        header[c] = get_data_position(c, expvars, intercept, ttest, criteria)    
    end
    header[:order] = get_data_position(:order, expvars, intercept, ttest, criteria)
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

function get_default_varnames(expvars_num::Integer)
    [ :y ; [ Symbol("x$i") for i = 1:expvars_num ] ]
end

function export_csv(output, result)
    sub_headers = (result.ttest) ? ["_b", "_bstd", "_t"] : ["_b"]

    headers = vcat([INDEX], [Symbol(string(v,n)) for v in result.expvars for n in sub_headers], EQUATION_GENERAL_INFORMATION, result.criteria, ORDER)
    head = ""
    l = length(headers)
    for i = 1:l
        head = string(head, string(headers[i]))
        if ( i != l )
            head = string(head,",")
        end
    end

    file = open(string("asd",output), "w")
    write(file, head)
    #writecsv(file, "\n")
    writecsv(file, result.results)
    close(file)
end
