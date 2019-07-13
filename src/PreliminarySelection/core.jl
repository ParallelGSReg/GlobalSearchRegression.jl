function lasso!(data::GlobalSearchRegression.GSRegData)
    new_data = lasso(data)
    data = GlobalSearchRegression.copy_data(new_data)

    return data
end

function lasso(data::GlobalSearchRegression.GSRegData)
    new_data = GlobalSearchRegression.copy_data(new_data)

    new_data = GlobalSearchRegression.filter_data_by_empty_values(new_data)
    new_data = GlobalSearchRegression.convert_data(new_data)

    vars = lassoselection(new_data)
    
    new_data.expvars = new_data.expvars[vars]
    new_data.expvars_data = new_data.expvars_data[:,vars]
    
    return new_data
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
    map(b -> b != 0, path.betas[:, best])
end
