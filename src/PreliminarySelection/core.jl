function lasso(data::GlobalSearchRegression.GSRegData)
    new_data = 
    lasso!(GlobalSearchRegression.copy_data(data))
end

function lasso!(data::GlobalSearchRegression.GSRegData)
    data = GlobalSearchRegression.filter_data_by_empty_values(data)
    data = GlobalSearchRegression.convert_data(data)

    betas = lassoselection(data)
    data.extras[:lasso_betas] = betas

    vars = map(b -> b != 0, betas)
    data.expvars = data.expvars[vars]
    data.expvars_data = data.expvars_data[:,vars]
    
    data
end

computablevars(nvars) = min(Int(floor(log(2,Sys.total_memory()/2 ^30) + 21)), nvars)

function lassoselection(data::GlobalSearchRegression.GSRegData; nvars::Int64=nothing)
    nvars = (nvars != nothing) ? nvars : computablevars(size(data.expvars,1))
    if nvars >= size(data.expvars,1)
        return data.expvars
    end
    path = glmnet(data.expvars_data, data.depvar_data; nlambda=1000)
    best = nvars
    for cant in nactive(path.betas)
        if cant >= nvars
            if cant == nvars 
                best = cant
            end
            break;
        end
        best = cant
    end
    path.betas[:, best]
end
