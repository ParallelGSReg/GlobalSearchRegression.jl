function featureextraction(
    data::GlobalSearchRegression.GSRegData;
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array}=nothing,
    removemissings=REMOVEMISSINGS_DEFAULT
    )

    return featureextraction!(
        GlobalSearchRegression.copy_data(data),
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        interaction=interaction,
        removemissings=removemissings
    )
end

function featureextraction!(
    data::GlobalSearchRegression.GSRegData;
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array}=nothing,
    removemissings=REMOVEMISSINGS_DEFAULT
    )

    data = execute!(
        GlobalSearchRegression.copy_data(data),
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        interaction=interaction,
        removemissings=removemissings
    )

    data = addextras(data, fe_sqr, fe_log, fe_inv, fe_lag, interaction, removemissings)

    return data
end

function execute!(
    data::GlobalSearchRegression.GSRegData;
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array}=nothing,
    removemissings=REMOVEMISSINGS_DEFAULT
    )

    if fe_sqr != nothing
        data = data_add_fe_sqr(data, parse_fe_variables(fe_sqr, data.expvars))
    end

    if fe_log != nothing
        data = data_add_fe_log(data, parse_fe_variables(fe_log, data.expvars))
    end

    if fe_inv != nothing
        data = data_add_fe_inv(data, parse_fe_variables(fe_inv, data.expvars))
    end

    if fe_lag != nothing
        data = data_add_fe_lag(data, parse_fe_variables(fe_lag, data.expvars, depvar=data.depvar, is_pair=true))
    end

    if interaction != nothing
        data = data_add_interaction(data, parse_fe_variables(interaction, data.expvars))
    end

    if removemissings
        data = GlobalSearchRegression.filter_data_by_empty_values(data)
    end

    data = GlobalSearchRegression.convert_data(data)

    return data
end
