function get_cols(i)
    cols = zeros(Int64, 0)
    f = Int(ceil(log2(i+1)))
    for flag in base(2, i)
        if flag == '1'
            prepend!(cols,f)
        end
        f -= 1
    end
    return cols
end

# returns an array of symbols with y as first item.
function get_default_varnames(expvars_num::Integer)
    [ :y ; [ Symbol("x$i") for i = 1:expvars_num ] ]
end

function get_result_row( single_row::GSRegSingleResult )
    result_row = Array{Symbol}(0)
    push!(headers,:ID)
    for i = 1:single_row.b
        push!(headers, Symbol(string("x", i)))
        push!(headers, Symbol(string("x", i, "T")))
    end
    push!(headers, :sse)
    push!(headers, :R2)


    to_push = zeros(Float64,0)
    for b in single_result.b
        push!(to_push, b)
        push!(to_push, 0)
    end
    push!(to_push,single_result.sse)
    push!(to_push,single_result.R2)
    return []
end

function get_result_header(indepvars_num)
    headers = Array{Symbol}(0)
    push!(headers,:ID)
    for i = 1:indepvars_num
        push!(headers, Symbol(string("x", i)))
        push!(headers, Symbol(string("x", i, "T")))
    end
    push!(headers, :sse)
    push!(headers, :R2)
end


function get_available_criteria_by_sample(sample)
    return get_available_criteria_by("sample", sample)
end

function get_available_criteria_by_index(index)
    return get_available_criteria_by("index", index)
end

function get_available_criteria_by(by, value)
    criterias = []
    for k in keys(AVAILABLE_CRITERIA)
        if value == AVAILABLE_CRITERIA[k][by]
            push!(criterias, k)
        end
    end
    return criterias
end
