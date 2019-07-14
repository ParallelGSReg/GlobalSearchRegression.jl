
"""
to_string
"""
function to_string(data::GlobalSearchRegression.GSRegData, result::AllSubsetRegressionResult)
    datanames_index = GlobalSearchRegression.create_datanames_index(result.datanames)

    out = ""
    out *= @sprintf("\n")
    out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
    out *= @sprintf("                              Best model results                              \n")
    out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
    out *= @sprintf("                                                                              \n")
    out *= @sprintf("                                     Dependent variable: %s                   \n", data.depvar)
    out *= @sprintf("                                     ─────────────────────────────────────────\n")
    out *= @sprintf("                                                                              \n")
    out *= @sprintf(" Selected covariates                 Coef.")
    if result.ttest
        out *= @sprintf("        Std.         t-test")
    end
    out *= @sprintf("\n")
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")

    cols = get_selected_variables(Int64(result.bestresult_data[datanames_index[:index]]), data.expvars, data.intercept)

    for pos in cols
        varname = data.expvars[pos]
        out *= @sprintf(" %-35s", varname)
        out *= @sprintf(" %-10f", result.bestresult_data[datanames_index[Symbol(string(varname, "_b"))]])
        if result.ttest
            out *= @sprintf("   %-10f", result.bestresult_data[datanames_index[Symbol(string(varname, "_bstd"))]])
            out *= @sprintf("   %-10f", result.bestresult_data[datanames_index[Symbol(string(varname, "_t"))]])
        end
        out *= @sprintf("\n")
    end

    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    out *= @sprintf(" Observations                        %-10d\n", result.bestresult_data[datanames_index[:nobs]])
    out *= @sprintf(" Adjusted R²                         %-10f\n", result.bestresult_data[datanames_index[:r2adj]])
    out *= @sprintf(" F-statistic                         %-10f\n", result.bestresult_data[datanames_index[:F]])
    for criteria in result.criteria
        if AVAILABLE_CRITERIA[criteria]["verbose_show"]
    out *= @sprintf(" %-30s      %-10f\n", AVAILABLE_CRITERIA[criteria]["verbose_title"], result.bestresult_data[datanames_index[criteria]])
        end
    end

    if !result.modelavg
        out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    else 
        out *= @sprintf("\n")
        out *= @sprintf("\n")
        out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
        out *= @sprintf("                            Model averaging results                           \n")
        out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
        out *= @sprintf("                                                                              \n")
        out *= @sprintf("                                     Dependent variable: %s                   \n", data.depvar)
        out *= @sprintf("                                     ─────────────────────────────────────────\n")
        out *= @sprintf("                                                                              \n")
        out *= @sprintf(" Covariates                          Coef.")
        if result.ttest
            out *= @sprintf("        Std.         t-test")
        end
        out *= @sprintf("\n")
        out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")



        for varname in data.expvars
            out *= @sprintf(" %-35s", varname)
            out *= @sprintf(" %-10f", result.modelavg_data[datanames_index[Symbol(string(varname, "_b"))]])
            if result.ttest
                out *= @sprintf("   %-10f", result.modelavg_data[datanames_index[Symbol(string(varname, "_bstd"))]])
                out *= @sprintf("   %-10f", result.modelavg_data[datanames_index[Symbol(string(varname, "_t"))]])
            end
            out *= @sprintf("\n")
        end
        out *= @sprintf("\n")
        out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
        out *= @sprintf(" Observations                        %-10d\n", result.modelavg_data[datanames_index[:nobs]])
        out *= @sprintf(" Adjusted R²                         %-10f\n", result.modelavg_data[datanames_index[:r2adj]])
        out *= @sprintf(" F-statistic                         %-10f\n", result.modelavg_data[datanames_index[:F]])
        out *= @sprintf(" Combined criteria                   %-10f\n", result.modelavg_data[datanames_index[:order]])
        out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
        
    end

    return out
end
