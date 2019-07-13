"""
Initialize options
"""
function create_result(data, outsample, criteria, ttest, modelavg, residualtest, orderresults)  

    if :r2adj ∉ criteria
        push!(criteria, :r2adj)
    end

    if :rmseout ∉ criteria && outsample != OUTSAMPLE_DEFAULT
        push!(criteria, :rmseout)
    end

    datanames = create_datanames(data, criteria, ttest, modelavg, residualtest)

    if modelavg
        modelavg_datanames = []
    else
        modelavg_datanames = nothing
    end

    outsample_max = data.nobs - INSAMPLE_MIN - size(data.expvars, 1) - if (data.intercept) 1 else 0 end

    if isa(outsample, Int) && outsample_max <= outsample
        outsample = 0
    end

    return AllSubsetRegressionResult(
        datanames,
        modelavg_datanames,
        outsample,
        criteria,
        modelavg,
        ttest,
        residualtest,
        orderresults
    )
end

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
function create_datanames(data, criteria, ttest, modelavg, residualtest)

    datanames = []

    push!(datanames, INDEX)
    
    for expvar in data.expvars
        push!(datanames, Symbol(string(expvar, "_b")))
        if ttest
            push!(datanames, Symbol(string(expvar, "_bstd")))
            push!(datanames, Symbol(string(expvar, "_t")))
        end
    end

    testfields = (residualtest != nothing && residualtest) ? ((data.time != nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS) : []
    general_information_criteria = unique([ EQUATION_GENERAL_INFORMATION; criteria; testfields ])
    datanames = vcat(datanames, general_information_criteria)

    push!(datanames, ORDER)
    if modelavg
        push!(datanames, WEIGHT)
    end

    return datanames
end

"""
Creates an array with keys and array positions
"""
function create_datanames_index(datanames)
    header = Dict{Symbol,Int64}()
    for (index, name) in enumerate(datanames)
        header[name] = index
    end
    return header
end

"""
Returns selected appropiate covariates for each iteration
"""
function get_selected_variables(order, datanames, intercept; num_jobs=nothing, num_job=nothing, iteration_num=nothing)
    #if num_jobs != nothing && iseven(num_jobs) && iteration_num != nothing && iseven(iteration_num)
    #    if iseven(num_job)
    #        order = order - 1
    #    else
    #        order = order + 1
    #    end
    #end
    
    cols = zeros(Int64, 0)
    binary = string(order, base = 2)
    k = 1

    for order = 1:length(binary)
        if binary[length(binary) - order + 1] == '1'
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
Get insample data view
"""
function get_insample_views(depvar_data, expvars_data, outsample, selected_variables_index)
    depvar_view = nothing
    expvars_view = nothing
    if isa(outsample, Array)
        nobs = size(depvar_data, 1)
        insample = findall(x -> !(x in outsample), collect(1:nobs))
        depvar_view = depvar_data[insample, 1]
        expvars_view = expvars_data[insample, selected_variables_index]
    else
        depvar_view = depvar_data[1:end-outsample, 1]
        expvars_view = expvars_data[1:end-outsample, selected_variables_index]
    end
    return depvar_view,expvars_view 
end

"""
Get outsample data view
"""
function get_outsample_views(depvar_data, expvars_data, outsample, selected_variables_index)
    depvar_view = nothing
    expvars_view = nothing
    if isa(outsample, Array)
        nobs = size(depvar_data, 1)
        depvar_view = depvar_data[outsample, 1]
        expvars_view = expvars_data[outsample, selected_variables_index]
    else
        depvar_view = depvar_data[end-outsample:end, 1]
        expvars_view = expvars_data[end-outsample:end, selected_variables_index]
    end
    return depvar_view,expvars_view
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
