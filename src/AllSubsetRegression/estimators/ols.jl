function ols(
        data::GlobalSearchRegression.GSRegData;
        outsample=nothing,
        criteria=nothing,
        ttest=nothing,
        modelavg=MODELAVG_DEFAULT,
        residualtest=RESIDUALTEST_DEFAULT,
        orderresults=ORDERRESULTS_DEFAULT
    )

    result = GSRegResult(
        vcat([data.depvar], data.expvars),
        outsample,
        criteria,
        ttest,
        modelavg,
        residualtest,
        orderresults
    )

    result.datanames = create_datanames(data.expvars, criteria, ttest, residualtest, data.time, modelavg)
    
    proc!(data, result)

    return result
end

function gsreg_single_proc_result!(
        order,
        datanames,
        result_data,
        depvar,
        expvars,
        depvar_data,
        expvars_data,
        intercept,
        outsample,
        criteria,
        ttest,
        time,
        residualtest,
        datatype,
        header
    )

    cols = get_selected_cols(order, intercept, expvars)

    dep_data = @view(depvar_data[1:end-outsample])
    exp_data = @view(expvars_data[1:end-outsample, cols])

    nobs = size(dep_data, 1)
    ncoef = size(exp_data, 2)
    qrf = qr(exp_data)
    b = qrf \ dep_data                      # estimate
    ŷ = exp_data * b                        # predicted values
    er = dep_data - ŷ                       # in-sample residuals
    er2 = er .^ 2                           # squared errors
    sse = sum(er2)                          # residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom
    rmse = sqrt(sse / nobs)                 # root mean squared error
    r2 = 1 - var(er) / var(dep_data)        # model R-squared

    if ttest
        bstd = sqrt.( sum( (UpperTriangular(qrf.R) \ Matrix(1.0LinearAlgebra.I, ncoef, ncoef) ) .^ 2, dims=2) * (sse / df_e) )
    end

    if outsample > 0
        depvar_out = @view(depvar_data[end-outsample:end])
        expvars_out = @view(expvars_data[end-outsample:end, cols])
        erout = depvar_out - expvars_out * b                        # out-of-sample residuals
        sseout = sum(erout .^ 2)                                    # residual sum of squares
        rmseout = sqrt(sseout / outsample)                          # root mean squared error
        result_data[ order, header[:rmseout] ] = rmseout
    end

    result_data[ order, header[:index] ] = order
    for (index, col) in enumerate(cols)
        result_data[ order, header[Symbol(string(expvars[col], "_b"))] ] = datatype(b[index])
        if ttest
            result_data[ order, header[Symbol(string(expvars[col], "_bstd"))] ] = datatype(bstd[index])
            result_data[ order, header[Symbol(string(expvars[col], "_t"))] ] = result_data[order, header[Symbol(string(expvars[col], "_b"))]] / result_data[order, header[Symbol(string(expvars[col], "_bstd"))]]
        end
    end

    result_data[ order, header[:nobs] ] = nobs
    result_data[ order, header[:ncoef] ] = ncoef
    result_data[ order, header[:sse] ] = datatype(sse)
    result_data[ order, header[:r2 ] ] = datatype(r2)
    result_data[ order, header[:rmse] ] = datatype(rmse)
    result_data[ order, header[:order] ] = 0

    if :aic in criteria || :aicc in criteria
        aic = 2 * result_data[ order, header[:ncoef] ] + result_data[ order, header[:nobs] ] * log(result_data[ order, header[:sse] ] / result_data[ order, header[:nobs] ])
    end

    if :aic in criteria
        result_data[ order, header[:aic] ] = aic
    end

    if :aicc in criteria
        result_data[ order, header[:aicc] ] = aic + (2(result_data[ order, header[:ncoef] ] + 1) * (result_data[ order, header[:ncoef] ] + 2)) / (result_data[ order, header[:nobs] ] - (result_data[ order, header[:ncoef] ] + 1 ) - 1)
    end

    if :bic in criteria
        result_data[ order, header[:bic] ] = result_data[ order, header[:nobs] ] * log.(result_data[ order, header[:rmse] ]) + ( result_data[ order, header[:ncoef] ] - 1 ) * log.(result_data[ order, header[:nobs] ]) + result_data[ order, header[:nobs] ] + result_data[ order, header[:nobs] ] * log(2π)
    end

    if :r2adj in criteria
        result_data[ order, header[:r2adj] ] = 1 - (1 - result_data[ order, header[:r2] ]) * ((result_data[ order, header[:nobs] ] - 1) / (result_data[ order, header[:nobs] ] - result_data[ order, header[:ncoef] ]))
    end

    result_data[ order, header[:F] ] = (result_data[ order, header[:r2] ] / (result_data[ order, header[:ncoef] ] - 1)) / ((1 - result_data[ order, header[:r2] ]) / (result_data[ order, header[:nobs] ] - result_data[ order, header[:ncoef] ]))

    if residualtest
        x = er
        n = length(x)
        m1 = sum(x) / n
        m2 = sum((x .- m1) .^ 2) / n
        m3 = sum((x .- m1) .^ 3) / n
        m4 = sum((x .- m1) .^ 4) / n
        b1 = (m3 / m2 ^ (3 / 2)) ^ 2
        b2 = (m4 / m2 ^ 2)
        statistic = n * b1 / 6 + n * (b2 - 3) ^ 2 / 24
        d = Chisq(2.)
        jbtest = 1 .- cdf(d, statistic)

        regmatw = hcat((ŷ .^ 2), ŷ , ones(size(ŷ, 1)))
        qrfw = qr(regmatw)
        regcoeffw = qrfw \ er2
        residw = er2 - regmatw * regcoeffw
        rsqw = 1 - dot(residw, residw) / dot(er2, er2) # uncentered R^2
        statisticw = n * rsqw
        wtest = ccdf(Chisq(2), statisticw)

        result_data[ order, header[:wtest] ] = wtest
        result_data[ order, header[:jbtest] ] = jbtest
        if time != nothing
            e = er
            lag = 1
            xmat = exp_data

            n = size(e,1)
            elag = zeros(Float64,n,lag)
            for ii = 1:lag
                elag[ii+1:end, ii] = e[1:end-ii]
            end

            offset = lag
            regmatbg = [xmat[offset+1:end,:] elag[offset+1:end,:]]
            qrfbg = qr(regmatbg)
            regcoeffbg = qrfbg \ e[offset+1:end]
            residbg = e[offset+1:end] .- regmatbg * regcoeffbg
            rsqbg = 1 - dot(residbg,residbg) / dot(e[offset+1:end], e[offset+1:end]) # uncentered R^2
            statisticbg = (n - offset) * rsqbg
            bgtest = ccdf(Chisq(lag), statisticbg)
            result_data[ order, header[:bgtest] ] = bgtest
        end
    end
end

function gsreg_proc_result!(num_job, num_jobs, ops_by_worker, opts...)
    for j = 1:ops_by_worker
        gsreg_single_proc_result!( (j-1) * num_jobs + num_job, opts...)
    end
end

function proc!(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.GSRegResult)
    expvars_num = size(data.expvars, 1)
    if data.intercept
        expvars_num = expvars_num - 1
    end
    num_operations = 2 ^ expvars_num - 1

    depvar_data = convert(SharedArray, data.depvar_data)
    expvars_data = convert(SharedArray, data.expvars_data)
    
    result_data = fill!(SharedArray{data.datatype}(num_operations, size(result.datanames, 1)), NaN)

    header = create_header(result.datanames)

    if nprocs() == nworkers()
        for order = 1:num_operations
            gsreg_single_proc_result!(order, result.datanames, result_data, data.depvar, data.expvars, depvar_data, expvars_data, data.intercept, result.outsample, result.criteria, result.ttest, data.time, result.residualtest, data.datatype, header)
        end
    else
        num_workers = nworkers()
        ops_by_worker = div(num_operations, num_workers)
        num_jobs = (num_workers > num_operations) ? num_operations : num_workers
        remainder = num_operations - ops_by_worker * num_jobs
        jobs = []
        for num_job = 1:num_jobs
            push!(jobs, @spawnat num_job+1 gsreg_proc_result!(num_job, num_jobs, ops_by_worker, order, result.datanames, result_data, data.depvar, data.expvars, depvar_data, expvars_data, data.intercept, result.outsample, result.criteria, result.ttest, data.time, result.residualtest, data.datatype, header)) 
        end
        for job in jobs
            fetch(job)
        end

        if remainder > 0
            for j = 1:remainder
                order = j + ops_by_worker * num_jobs
                gsreg_single_proc_result!(order, result.datanames, result_data, data.depvar, data.expvars, depvar_data, expvars_data, data.intercept, result.outsample, result.criteria, result.ttest, data.time, result.residualtest, data.datatype, header)
            end
        end
    end

    result.data = Array(result_data)
    
    if :cp in result.criteria
        result.data[ :, header[:cp] ] = (result.data[ :, header[:nobs] ] .- maximum(result.data[ :, header[:ncoef] ]) .- 2) .* (result.data[ :, header[:rmse] ] ./ minimum(result.data[ :, header[:rmse] ])) .- (result.data[ :, header[:nobs] ] .- 2 .* result.data[ :, header[:ncoef] ])
    end

    len_criteria = length(result.criteria)
    for criteria in result.criteria
        result.data[ :, header[:order] ] += AVAILABLE_CRITERIA[criteria]["index"] * (1 / len_criteria) * ( (result.data[ :, header[criteria] ] .- mean(result.data[ :, header[criteria] ]) ) ./ std(result.data[ :, header[criteria] ]) )
    end
    
    if result.modelavg
        delta = maximum(result.data[ :, header[:order]]) .- result.data[ :, header[:order] ]
        w1 = exp.(-delta/2)
        result.data[ :, header[:weight] ] = w1./sum(w1)
        result.modelavg_datanames = filter(x->(!x in [:index, :weight]), result.datanames)       
        result.modelavg_data = Array{Float64}(undef, 1, length( result.modelavg_datanames ))
        modelavg_header = create_header(result.datanames)
        for key in header
            result.modelavg_data[ modelavg_header[key] ] = sum( result.data[:, key] .* result.data[ :, :weight] )
        end
    end

    if result.orderresults
        result.data = sortrows(result.data, [header[:order]]; rev=true)
        result.bestresult_data = result.results[1,:]
    else
        max_order = argmax(result.data[ 1, header[:order] ])
        result.bestresult_data = result.data[ max_order, : ]
    end
end
