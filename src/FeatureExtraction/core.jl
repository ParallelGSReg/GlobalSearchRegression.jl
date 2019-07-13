function featureextraction!(
    data::GlobalSearchRegression.GSRegData;
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array}=nothing,
    removemissings=REMOVEMISSINGS_DEFAULT
    )

    new_data = featureextraction(
        data,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        interaction=interaction,
        removemissings=removemissings
    )

    data = GlobalSearchRegression.copy_data!(new_data, data)

    return data
end

function featureextraction(
    data::GlobalSearchRegression.GSRegData;
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array}=nothing,
    removemissings=REMOVEMISSINGS_DEFAULT
    )

    fe_data = GlobalSearchRegression.copy_data(data)

    if fe_sqr != nothing

        fe_sqr = parse_fe_variables(fe_sqr, fe_data.expvars)
        fe_data = data_add_fe_sqr(fe_data, fe_sqr)
    end

    if fe_log != nothing
        fe_log = parse_fe_variables(fe_log, fe_data.expvars)
        fe_data = data_add_fe_log(fe_data, fe_log)
    end

    if fe_inv != nothing
        fe_inv = parse_fe_variables(fe_inv, fe_data.expvars)
        fe_data = data_add_fe_inv(fe_data, fe_inv)
    end

    if fe_lag != nothing
        fe_lag = parse_fe_variables(fe_lag, fe_data.expvars, depvar=fe_data.depvar, is_pair=true)
        fe_data = data_add_fe_lag(fe_data, fe_lag)
    end

    if interaction != nothing
        interaction = parse_fe_variables(interaction, fe_data.expvars)
        fe_data = data_add_interaction(fe_data, interaction)
    end

    if removemissings
        fe_data = GlobalSearchRegression.filter_data_by_empty_values(dafe_datata)
    end

    fe_data = GlobalSearchRegression.convert_data(fe_data)

    return fe_data
end
