function latex(result::GlobalSearchRegression.GSRegData)
    #construir diccionario desde data parcial
        #formula
        #input features extraction
        #preselccion lasso
        #bestmodel
        #kfold cross validation robustez
    #crear env (copiar files estaticos necesarios)
    #renderizar plots
    #renderizar tpl
end
    
function get_variable_summary(data)
    result = []

    for var in names(data)
        orig = data[var]
        obs = collect(skipmissing(orig))
        push!(result, Dict(
            "name" => string(var),
            "nobs" => length(obs),
            "mean" => @sprintf("%.2f", mean(obs)),
            "std"  => @sprintf("%.2f", std(obs)),
            "max"  => @sprintf("%.2f", maximum(obs)),
            "min"  => @sprintf("%.2f", minimum(obs)),
            "miss" => @sprintf("%.2f", 100 - (length(obs) / length(orig))*100 )
        ))
    end

    return result
end

function get_lasso_summary(selectedvars)
    selectedvars = lasso.betas[:,113]
    result = []

    for var in headers[[false; map(v -> v > 0, selectedvars)]]
        push!(result, Dict(
            "var" => var,
            "coef" => 1
        ))
    end

    return result
end

function get_tex_summary()
    Dict(
        "indep" => "y",
        "depvar" => "xasxasx", 
        "var_summary" => get_variable_summary(data),
        # "lasso" => Dict(
        #     "summary" => get_lasso_summary(lasso)
        # )
    )
end

function create_workspace()
    cp(joinpath(TEX_TEMPLATE_FOLDER, "tpl"), DEFAULT_DEST_FOLDER)
end

function render()
    d = get_tex_summary()
    io = open(joinpath(DEFAULT_DEST_FOLDER, "main.tex"), "w")
    write(io, render_from_file(joinpath(TEX_TEMPLATE_FOLDER, "tpl.tex"), d))
    close(io)
end

function plot(results)
    dropnans(arr) = findall(x -> !isnan(x), arr)
    expvars2 = results.expvars[:,1]
    expvars2 = deleteat!(expvars2, findfirst(isequal(:_cons), expvars2))
    criteria_diff = Array{Any}(undef, size(expvars2,1), 2)

    for expvar in expvars2   
        xobs = dropnans(results.results[:,results.header[Symbol("$(expvar)_b")]])
        x= results.results[xobs,results.header[Symbol("$(expvar)_b")]]
        yobs = dropnans(results.results[:,results.header[Symbol("$(expvar)_t")]])
        y=results.results[yobs,results.header[Symbol("$(expvar)_t")]]
        biden = kde((x,y),npoints=(100,100))
        
        contour(biden.x, biden.y, biden.density; xlabel="Coef. $expvar", ylabel="t-test $expvar")
        savefig("contour_$(expvar)_b_t.png")
    
        wireframe(biden.x, biden.y, biden.density; xlabel="Coef. $expvar", ylabel="t-test $expvar", camera=(45,45))
        savefig("wireframe_$(expvar)_b_t.png")
    
        criteria_with = results.results[findall(x -> !isnan(x), results.results[:, results.header[Symbol("$(expvar)_b")]]), results.header[:r2adj]]
        criteria_without = results.results[findall(x -> isnan(x), results.results[:, results.header[Symbol("$(expvar)_b")]]), results.header[:r2adj]]
        uniden_with = kde(criteria_with)
        uniden_without= kde(criteria_without)
        
        p1 = plot(range(min(criteria_with...), stop = max(criteria_with...), length = 150), z -> pdf(uniden_with, z))
        p1 = plot!(range(min(criteria_without...), stop = max(criteria_without...), length = 150), z -> pdf(uniden_without,z))
        plot(p1,label=["Including $(expvar)" "Excluding $(expvar)"], ylabel="Adj. R2")
        savefig("Kdensity_criteria_$(expvar).png")
        
        p2=violin(["Including $(expvar)" "Excluding $(expvar)"],[criteria_with, criteria_without],leg=false,marker=(0.1,stroke(0)), alpha=0.50, color=:blues)
        p2=boxplot!(["Including $(expvar)" "Excluding $(expvar)"],[criteria_with, criteria_without],leg=false,marker=(0.3,stroke(2)), alpha=0.6, color=:orange)
        plot(p2, ylabel="Adj. R2")
        savefig("BoxViolinDot_$(expvar).png")
        i=findfirst(x-> x==expvar,expvars2)
        criteria_diff[i,2]= "$(expvar)"
        criteria_diff[i,1]= mean(criteria_with) - mean(criteria_without)
    end

    a=sortslices(criteria_diff, dims=1)
    labels=convert(Array{String},a[:,2])
    bar(labels,a[:,1],legend=false, color=:blues, orientation = :horizontal, xlabel="Average impact of each variable on the Adj. R2")
    savefig("cov_relevance.png")
end