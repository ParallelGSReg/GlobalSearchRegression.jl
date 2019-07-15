const TEX_TEMPLATE_FOLDER = joinpath(dirname(@__FILE__), "tex")
const DEFAULT_LATEX_DEST_FOLDER = "./Latex"

function latex(data::GlobalSearchRegression.GSRegData, path::Union{Nothing, String}=DEFAULT_LATEX_DEST_FOLDER)
    return latex(data, path=path)
end

function latex(data::GlobalSearchRegression.GSRegData; path::Union{Nothing, String}=DEFAULT_LATEX_DEST_FOLDER)
    if size(data.results, 1) > 0
        dict = Dict()
        #dict basico
        for i in 1:size(data.results, 1)
            append!(dict, latex(data, data.results[i], path))
        end
        #cierre basico
        render_latex(path, dict)
    end
end

function latex(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult, path::AbstractString)
    dict = GlobalSearchRegression.AllSubsetRegression.to_latex_dict(data, result)
    create_figures(result, path)
    return :allsubsetregression => dict
end

function latex(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.CrossValidation.CrossValidationResult, path::AbstractString)
    dict = GlobalSearchRegression.CrossValidation.to_latex_dict(data, result)
    create_figures(result, path)
    return :kfoldcrossvalidation => dict
end

function latex(data::GlobalSearchRegression.GSRegData; path::String=DEFAULT_LATEX_DEST_FOLDER)
    res = Dict()

    res[:base] = base(data)

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

function base(data::GlobalSearchRegression.GSRegData)
    dict = Dict()
    equation::Array{Symbol}
    depvar::Symbol
    expvars::Array{Symbol}
    panel::Union{Symbol, Nothing} 
    time::Union{Symbol, Nothing}
    depvar_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float64, Missing}}, Array{Union{Float32, Missing}}}
    expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float64, Missing}}, Array{Union{Float32, Missing}}}
    panel_data::Union{Nothing, Array{Int64}, Array{Int32}, Array{Union{Int64, Missing}}, Array{Union{Int32, Missing}}}
    time_data::Union{Nothing, Array{Float64}, Array{Float32}, Array{Union{Float64, Missing}}, Array{Union{Float32, Missing}}}
    intercept::Bool
    datatype::DataType
    removemissings::Bool
    nobs::Int64
    options::Array{Any}
    extras::Dict
    previous_data::Array{Any}
    results::Array{Any}
    
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

"""
Copy the required files from the tpl folder. The existent content will be replaced. The folder is created if not exists.
"""
function create_workspace(destfolder::AbstractString)
    cp(joinpath(TEX_TEMPLATE_FOLDER, "tpl"), destfolder)
end

"""
Write template based on dict info
"""
function render_latex(destfolder::AbstractString, dict)
    io = open(joinpath(destfolder, "main.tex"), "w")
    write(io, render_from_file(joinpath(TEX_TEMPLATE_FOLDER, "tpl.tex"), dict))
    close(io)
end

dropnans(res, var) = res.results[findall(x -> !isnan(x), res.results[:, res.header[var]]), res.header[var]]


"""
Create required figures by the template. Generate png images into the dest folder
"""
function create_figures(res, destfolder)
    expvars2 = res.expvars[:,1]
    expvars2 = deleteat!(expvars2, findfirst(isequal(:_cons), expvars2))
    criteria_diff = Array{Any}(undef, size(expvars2,1), 2)

    for (i, expvar) in enumerate(expvars2)
        x = dropnans(res, Symbol("$(expvar)_b"))
        y = dropnans(res, Symbol("$(expvar)_t"))
        
        biden = kde( (x,y), npoints=(100,100))
        
        contour(biden.x, biden.y, biden.density; xlabel="Coef. $expvar", ylabel="t-test $expvar")
        savefig(joinpath(destfolder, "contour_$(expvar)_b_t.png"))
    
        wireframe(biden.x, biden.y, biden.density; xlabel="Coef. $expvar", ylabel="t-test $expvar", camera=(45,45))
        savefig(joinpath(destfolder, "wireframe_$(expvar)_b_t.png"))
    
        criteria_with = res.results[findall(x -> !isnan(x), res.results[:, res.header[Symbol("$(expvar)_b")]]), res.header[:r2adj]]
        criteria_without = res.results[findall(x -> isnan(x), res.results[:, res.header[Symbol("$(expvar)_b")]]), res.header[:r2adj]]
        
        uniden_with = kde(criteria_with)
        uniden_without= kde(criteria_without)
        
        p1 = plot(range(min(criteria_with...), stop = max(criteria_with...), length = 150), z -> pdf(uniden_with, z))
        p1 = plot!(range(min(criteria_without...), stop = max(criteria_without...), length = 150), z -> pdf(uniden_without,z))
        plot(p1, label=["Including $(expvar)" "Excluding $(expvar)"], ylabel = "Adj. R2")
        savefig(joinpath(destfolder, "Kdensity_criteria_$(expvar).png"))
        
        p2 = violin(["Including $(expvar)" "Excluding $(expvar)"], [criteria_with, criteria_without], leg = false, marker = (0.1, stroke(0)), alpha = 0.50, color = :blues)
        p2 = boxplot!(["Including $(expvar)" "Excluding $(expvar)"], [criteria_with, criteria_without], leg = false, marker = (0.3, stroke(2)), alpha = 0.6, color = :orange)
        plot(p2, ylabel = "Adj. R2")
        savefig(joinpath(destfolder, "BoxViolinDot_$(expvar).png"))
        
        criteria_diff[i, 2] = "$(expvar)"
        criteria_diff[i, 1] = mean(criteria_with) - mean(criteria_without)
    end

    a = sortslices(criteria_diff, dims = 1)
    labels = convert(Array{String}, a[:,2])
    bar(labels, a[:,1], legend = false, color = :blues, orientation = :horizontal, xlabel="Average impact of each variable on the Adj. R2")
    savefig(joinpath(destfolder, "cov_relevance.png"))
end
