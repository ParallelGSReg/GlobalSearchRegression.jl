"""
Constructs the datanames array for results based on this structure.
    - Index
    - Covariates
        * b
        * bstd
        * T-test
    - Equation general information merged with criteria user-defined options
    - Order index from user combined criteria
    - Weight
"""
function create_datanames(expvars, criteria, ttest, residualtest, time, modelavg)
    datanames = []

    push!(datanames, INDEX)

    for expvar in expvars
        push!(datanames, Symbol(string(expvar, "_b")))
        if ttest
            push!(datanames, Symbol(string(expvar, "_bstd")))
            push!(datanames, Symbol(string(expvar, "_t")))
        end
    end

    testfields = (residualtest != nothing && residualtest) ? ((time != nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS) : []
    general_information_criteria = unique([ EQUATION_GENERAL_INFORMATION; criteria; testfields ])
    datanames = vcat(datanames, general_information_criteria)
    push!(datanames, ORDER)
    if modelavg
        push!(datanames, WEIGHT)
    end

    return datanames
end

"""
Returns selected appropiate covariates for each iteration
"""
function get_selected_cols(i, intercept, datanames)
    cols = zeros(Int64, 0)
    binary = string(i, base = 2)
    k = 1
    for i = 1:length(binary)
        if binary[length(binary) - i + 1] == '1'
            push!(cols, k)
        end
        k = k + 1
    end
    if intercept
        push!(cols, GlobalSearchRegression.get_column_index(:_cons, datanames))
    end
    return cols
end

"""
Creates an array with keys and array positions
"""
function create_header(datanames)
    header = Dict{Symbol,Int64}()
    for (index, name) in enumerate(datanames)
        header[name] = index
    end
    return header
end

"""
Sort rows
"""
function sortrows(B::AbstractMatrix,cols::Array; kws...)
    for i = 1:length(cols)
        if i == 1
            p = sortperm(B[:,cols[i]]; kws...)
            B = B[p,:]
        else
            i0_old = 0
            i1_old = 0
            i0_new = 0
            i1_new = 0
            for j = 1:size(B,1)-1
                if B[j,cols[1:i-1]] == B[j+1,cols[1:i-1]] && i0_old == i0_new
                    i0_new = j
                elseif B[j,cols[1:i-1]] != B[j+1,cols[1:i-1]] && i0_old != i0_new && i1_new == i1_old
                    i1_new = j
                elseif i0_old != i0_new && j == size(B,1)-1
                    i1_new = j+1
                end
                if i0_new != i0_old && i1_new != i1_old
                    p = sortperm(B[i0_new:i1_new,cols[i]]; kws...)
                    B[i0_new:i1_new,:] = B[i0_new:i1_new,:][p,:]
                    i0_old = i0_new
                    i1_old = i1_new
                end
            end
        end
    end
    return B
end