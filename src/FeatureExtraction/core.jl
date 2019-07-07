function featureextraction(
    data::GlobalSearchRegression.GSRegData;
    fe_sqr=nothing,
    fe_log=nothing,
    fe_inv=nothing,
    fe_lag=nothing,
    interaction=nothing,
    removemissings=REMOVEMISSINGS_DEFAULT,
    keepdata=KEEPDATA_DEFAULT
    )

    if fe_sqr != nothing
        fe_sqr = parse_fe_variables(fe_sqr, data.expvars)
        data = data_add_fe_sqr(data, fe_sqr)
    end

    if fe_log != nothing
        fe_log = parse_fe_variables(fe_log, data.expvars)
        data = data_add_fe_log(data, fe_log)
    end

    if fe_inv != nothing
        fe_inv = parse_fe_variables(fe_inv, data.expvars)
        data = data_add_fe_inv(data, fe_inv)
    end

    if fe_lag != nothing
        fe_lag = parse_fe_variables(fe_lag, data.expvars, depvar=data.depvar, is_pair=true)
        data = data_add_fe_lag(data, fe_lag)
    end

    if interaction != nothing
        interaction = parse_fe_variables(interaction, data.expvars)
        data = data_add_interaction(data, interaction)
    end

    if removemissings
        data = GlobalSearchRegression.filter_data_by_empty_values(data)
    end

    data = GlobalSearchRegression.convert_data(data)

    return data
end
