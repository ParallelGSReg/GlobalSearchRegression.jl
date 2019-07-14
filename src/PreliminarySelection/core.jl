function lasso(data::GlobalSearchRegression.GSRegData)
    lasso!(GlobalSearchRegression.copy_data(data))
end

function lasso!(data::GlobalSearchRegression.GSRegData)
    betas = lassoselection(data)

    data.extras[:lasso_betas] = betas

    vars = map(b -> b != 0, betas)

    if data.intercept
        vars[GlobalSearchRegression.get_column_index(:_cons, data.expvars)] = true
    end

    data.expvars = data.expvars[vars]
    data.expvars_data = data.expvars_data[:,vars]
    
    data = addextras(data)

    return data, vars
end

function computablevars(nvars::Int)
    return 15
    min(Int(floor(log(2,Sys.total_memory()/2 ^30) + 21)), nvars)
end

function lassoselection(data)
    data = GlobalSearchRegression.filter_data_by_empty_values(data)
    data = GlobalSearchRegression.convert_data(data)
    nvars = computablevars(size(data.expvars,1))

    if nvars >= size(data.expvars,1)
        return data.expvars
    end

    path = glmnet(data.expvars_data, data.depvar_data; nlambda=1000)
    
    best = 1
    for (i, cant) in enumerate(nactive(path.betas))
        if cant >= nvars
            if cant == nvars 
                best = i
            end
            break;
        end
        best = i
    end

    path.betas[:, best]
end
