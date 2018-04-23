function get_selected_cols(i)
    # NOTE:
    # (adanmauri) Get cols entirely changed because we need start from index 2
    cols = zeros(Int64, 0)
    binary = bin(i)
    k = 2
    for i = 1:length(binary)
        if binary[length(binary)-i+1] == '1'
            append!(cols, k)
        end
        k = k + 1
    end
    return cols
end


# returns an array of symbols with y as first item.
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

function export_csv(output, result)
    criteria = result.criteria

    if !(:r2adj in criteria)
        criteria = vcat(criteria, [:r2adj])
    end

    if result.outsample > OUTSAMPLE_DEFAULT && !(:rmseout in criteria)
        criteria = vcat(criteria, [:rmseout])
    end

    headers = vcat([:index ], [Symbol(string(v,n)) for v in result.expvars for n in ["_b","_t"]], [:nobs, :ncoef], criteria)
    CSV.write(output, result.results[headers])
end

# NOTE:
# Frozen until we know what to do with this
"""
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
"""
