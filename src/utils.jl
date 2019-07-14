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

"""
Filter rawdata by empty values
"""
function filter_raw_data_by_empty_values(datatype, depvar_data, expvars_data, panel_data=nothing, time_data=nothing)
    keep_rows = Array{Bool}(undef, size(depvar_data, 1))
    keep_rows .= true
    keep_rows .&= map(b->!b, ismissing.(depvar_data))

    for i = 1:size(expvars_data, 2)
        keep_rows .&= map(b->!b, ismissing.(expvars_data[:, i]))
    end
    
    depvar_data = convert(Array{datatype}, depvar_data[keep_rows, 1])
    expvars_data = convert(Array{datatype}, expvars_data[keep_rows, :])

    if panel_data != nothing
        panel_data = panel_data[keep_rows, 1]
    end

    if time_data != nothing
        time_data = time_data[keep_rows, 1]
    end

    return depvar_data, expvars_data, panel_data, time_data
end

"""
Filter data by empty values
"""
function filter_data_by_empty_values(data)
    depvar_data, expvars_data, panel_data, time_data = filter_raw_data_by_empty_values(
        data.datatype,
        data.depvar_data,
        data.expvars_data,
        data.panel_data,
        data.time_data
    )

    data.depvar_data = depvar_data
    data.expvars_data = expvars_data
    data.panel_data = panel_data
    data.time_data = time_data
    data.nobs = size(data.depvar_data, 1)

    return data
end

"""
Convert column by data content
"""
function convert_column(datatype, column)
    if column != nothing
        has_missings = false
        
        if size(column, 2) == 1
            has_missings |= findfirst(x -> ismissing(x), column) != nothing
        else
            for i in 1:size(column, 2)
                has_missings |= findfirst(x -> ismissing(x), column[:,i]) != nothing
            end
        end


        if has_missings
            return convert(Array{Union{Missing, datatype}}, column)
        else
            return convert(Array{datatype}, column)
        end
    end
    return nothing
end

"""
Convert rawdata by data content
"""
function convert_raw_data(datatype, depvar_data, expvars_data, panel_data=nothing, time_data=nothing)
    depvar_data = convert_column(datatype, depvar_data)
    expvars_data = convert_column(datatype, expvars_data)
    panel_data = convert_column(datatype == Float64 ? Int64 : Int32, panel_data)
    time_data = convert_column(datatype, time_data)

    return depvar_data, expvars_data, panel_data, time_data
end

"""
Convert data by data
"""
function convert_data(data)
    depvar_data, expvars_data, panel_data, time_data = convert_raw_data(
        data.datatype,
        data.depvar_data,
        data.expvars_data,
        data.panel_data,
        data.time_data
    )
    data.depvar_data = depvar_data
    data.expvars_data = expvars_data
    data.panel_data = panel_data
    data.time_data = time_data

    return data
end

"""
Copy GSRegData
"""
function copy_data(data::GSRegData)
    new_data = GSRegData(
        copy(data.equation),
        data.depvar,
        copy(data.expvars),
        data.panel,
        data.time,
        copy(data.depvar_data),
        copy(data.expvars_data),
        if (data.panel_data != nothing) copy(data.panel_data) else data.panel_data end,
        if (data.time_data != nothing) copy(data.time_data) else data.time_data end,
        data.intercept,
        data.datatype,
        data.removemissings,
        data.nobs
    )

    new_data.extras = data.extras
    new_data.options = copy(data.options)
    new_data.previous_data = copy(data.previous_data)
    new_data.results = copy(data.results)
    return new_data
end

"""
Copy GSRegData to another data
"""
function copy_data!(from_data::GSRegData, to_data::GSRegData)
    to_data.equation = from_data.equation
    to_data.depvar = from_data.depvar
    to_data.expvars = from_data.expvars
    to_data.panel = from_data.panel
    to_data.time = from_data.time
    to_data.depvar_data = from_data.depvar_data
    to_data.expvars_data = from_data.expvars_data
    to_data.panel_data = from_data.panel_data
    to_data.time_data = from_data.time_data
    to_data.intercept = from_data.intercept
    to_data.datatype = from_data.datatype
    to_data.removemissings = from_data.removemissings
    to_data.nobs = from_data.nobs
    to_data.extras = from_data.extras
    to_data.options = from_data.options
    to_data.previous_data = from_data.previous_data
    to_data.results = from_data.results
    
    return to_data
end

"""
Generate extra key
"""
function generate_extra_key(extra_key, extras)
    if !(extra_key in keys(extras))
        return extra_key
    else
        posfix = 2
        while Symbol(string(extra_key, "_", posfix)) in keys(extras)
            posfix = posfix + 1
        end
        return Symbol(string(extra_key, "_", posfix))
    end
end

"""
Returns if feature extraction module was selected
"""
function featureextraction_enabled(fe_sqr, fe_log, fe_inv, fe_lag, interaction)
    return fe_sqr != nothing || fe_log != nothing || fe_inv != nothing || fe_lag != nothing || interaction != nothing
end

"""
Returns if preliminary selection was selected
"""
function preliminaryselection_enabled(preliminaryselection)
    return preliminaryselection != nothing
end

"""
Validates if preliminary selecttion method exists
"""
function validate_preliminaryselection(preliminaryselection)
    return preliminaryselection in VALID_PRELIMINARYSELECTION
end

"""
Add result
"""
function addresult!(data, result)
    push!(data.results, result)

    return data
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
