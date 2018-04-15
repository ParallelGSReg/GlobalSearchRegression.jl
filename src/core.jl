function gsreg(depvar::Array, expvars::Array; intercept::Bool=INTERCEPT_DEFAULT, varnames::Array{Symbol}=nothing)
    expvars_num = size(expvars, 2)

    if varnames == nothing
        varnames = get_default_varnames(expvars_num)
    end

    num_operations = 2 ^ expvars_num - 1

    if intercept
        expvars = hcat(ones(size(expvars, 1)), expvars)
        push!(varnames, :_cons)
    end

    results = DataFrame()
    for i = 1:num_operations
        cols = get_cols(i)

        if intercept
            append!(cols, expvars_num + 1) #add constant
        end
        single_result = GSRegSingleResult(@view(expvars[1:end, cols]), depvar)
        push!(results, get_partial_row(single_result))
    end

    return results
end
