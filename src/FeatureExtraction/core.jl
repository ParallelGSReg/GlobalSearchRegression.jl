function featureextraction(
    data::GSRegData;
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
        data, expvars, datanames = data_add_fe_sqr(data, fe_sqr, expvars, datanames)
    end

    #if fe_log != nothing
    #    fe_log = parse_fe_variables(fe_log, expvars, datanames)
    #    data, expvars, datanames = data_add_fe_log(data, fe_log, expvars, datanames)
    #end

    #if fe_inv != nothing
    #    fe_inv = parse_fe_variables(fe_inv, expvars, datanames)
    #    data, expvars, datanames = data_add_fe_inv(data, fe_inv, expvars, datanames)
    #end

    #if fe_lag != nothing
    #    fe_lag = parse_fe_variables(fe_lag, expvars, datanames, include_depvar=true, is_pair=true)
    #    data, expvars, datanames = data_add_fe_lag(data, fe_lag, expvars, datanames, panel=panel)
    #end

    #if interaction != nothing
    #    data, expvars, datanames = data_add_interaction(data, interaction, depvar, expvars, datanames, equation)
    #end

    return data
end

