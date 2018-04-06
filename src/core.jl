function gsreg(depvar::Array, indepvars::Array; noconstant::Bool=NOCONSTANT_DEFAULT, varnames::Array{Symbol}=nothing)
    indepvars_num = size(indepvars, 2)

    if varnames == nothing
        varnames = get_default_varnames(indepvars_num)
    end

    num_operations = 2 ^ indepvars_num - 1

    if !noconstant
        indepvars = hcat(ones(size(indepvars, 1)), indepvars)
        push!(varnames, :_cons)
    end
        
    results = DataFrame()
    for i = 1:num_operations
        cols = get_cols(i)

        if !noconstant
            append!(cols, indepvars_num+1) #add constant
        end
        single_result = GSRegSingleResult(@view(indepvars[1:end, cols]), depvar)
        push!(results, get_partial_row(single_result))
    end

    return results
end