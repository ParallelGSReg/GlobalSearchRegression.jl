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

function in_vector(sub_vector, vector)
    for sv in sub_vector
        if !in(sv, vector)
            return false
        end
    end
    return true
end

function get_data_position(name, expvars, intercept, ttest, criteria)
    INDEX = :index
    EQUATION_GENERAL_INFORMATION = [:nobs, :ncoef, :sse, :r2, :F, :rmse]
    ORDER = :order

    # HEADER = [:index, :variables, :nobs, :ncoef, :sse, :r2, :F, :rmse, :criteria, :order]

    data_cols_num = (intercept==true)?length(expvars)+1:length(expvars)
    mult_col = (ttest == true)?3:1    

    # INDEX
    if name == INDEX
        return 1
    end
    displacement = 1
    displacement = displacement + mult_col * (data_cols_num)

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

function export_csv(output, result)
    criteria = result.criteria

    if !(:r2adj in criteria)
        criteria = vcat(criteria, [:r2adj])
    end

    if result.outsample > OUTSAMPLE_DEFAULT && !(:rmseout in criteria)
        criteria = vcat(criteria, [:rmseout])
    end

    sub_headers = (result.ttest) ? ["_b", "_t"] : ["_b"]
    
    headers = vcat([:index ], [Symbol(string(v,n)) for v in result.expvars for n in sub_headers], [:nobs, :ncoef, :F], criteria)

    head = ""

    l = length(headers)
    for i = 1:l
        head = string(head,String(headers[i]))
        if ( i != l )
            head = string(head,",")
        end
    end

    file = open(string("asd",output), "w")
    write(file, head)
    writecsv(file, "\n")
    writecsv(file, result.results)#Array(result.results[headers]))
    close(file)
end
