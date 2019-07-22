const TEX_TEMPLATE_FOLDER = joinpath(dirname(@__FILE__), "tpl")
const DEFAULT_LATEX_DEST_FOLDER = "./Latex"

function latex(data::GlobalSearchRegression.GSRegData; path::Union{Nothing, String}=DEFAULT_LATEX_DEST_FOLDER)
    addextras(data, :latex, nothing, path)
    if size(data.results, 1) > 0
        dict = Dict()
        latex!(dict, data)
        for i in 1:size(data.results, 1)
            latex!(dict, data, data.results[i])
        end
        render_latex(dict, path)
    end
end

function latex!(dict::Dict, data::GlobalSearchRegression.GSRegData)
    preprocessing_dict = process_dict(data.extras[Preprocessing.PREPROCESSING_EXTRAKEY])

    if "seasonaladjustment" in keys(preprocessing_dict) && preprocessing_dict["seasonaladjustment"] != nothing
        sa = preprocessing_dict["seasonaladjustment"] 
        fe_seasonaladjustment_names=Array{String}(undef, size(sa, 1))
        fe_seasonaladjustment_vals=Array{Int64}(undef, size(sa, 1))
        for i = 1:size(sa,1)
            fe_seasonaladjustment_names[i] = string(sa[i][1])
            fe_seasonaladjustment_vals[i] = sa[i][2]
        end
        preprocessing_dict["tabseasonalfortex"]=Dict(
            :fe_seasonaladjustment_names => fe_seasonaladjustment_names,
            :fe_seasonaladjustment_vals => fe_seasonaladjustment_vals
        )
    end

    if "removeoutliers" in keys(preprocessing_dict) && preprocessing_dict["removeoutliers"]
        preprocessing_dict["removeoutliersfortex"] = Dict(:content=>true)
    end

    dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)] = process_dict(data.extras[GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY])

    preprocessing_dict["descriptive"] = []
    actual_data = collect(skipmissing(data.depvar_data))
    c_obs = length(actual_data)
    c_miss = length(data.depvar_data) - c_obs
    push!(preprocessing_dict["descriptive"], Dict(
        "name" => string(data.depvar),
        "nobs" => length(actual_data),
        "mean" => @sprintf("%.2f", mean(actual_data)),
        "std"  => @sprintf("%.2f", std(actual_data)),
        "max"  => @sprintf("%.2f", maximum(actual_data)),
        "min"  => @sprintf("%.2f", minimum(actual_data)),
        "miss" => @sprintf("%.2f", (c_miss/c_obs)*100)
    ))

    for expvar in data.expvars
        col = data.expvars_data[:, GlobalSearchRegression.get_column_index(expvar, data.expvars)]
        actual_data = collect(skipmissing(col))
        c_obs = length(actual_data)
        c_miss = length(col) - c_obs
        push!(preprocessing_dict["descriptive"], Dict(
            "name" => string(expvar),
            "nobs" => length(actual_data),
            "mean" => @sprintf("%.2f", mean(actual_data)),
            "std"  => @sprintf("%.2f", std(actual_data)),
            "max"  => @sprintf("%.2f", maximum(actual_data)),
            "min"  => @sprintf("%.2f", minimum(actual_data)),
            "miss" => @sprintf("%.2f", (c_miss/c_obs)*100)
        ))
    end
   
    dict[string(Preprocessing.PREPROCESSING_EXTRAKEY)] = preprocessing_dict

    if FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY in keys(data.extras)
        featureextraction_dict = process_dict(data.extras[FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY])

        if "fe_lag" in keys(featureextraction_dict) && featureextraction_dict["fe_lag"] != nothing
            fe_lag = featureextraction_dict["fe_lag"]
            fe_lag_names = Array{String}(undef, size(fe_lag,1), 1)
            fe_lag_vals = Array{Int64}(undef, size(fe_lag,1), 1)
            for i = 1:size(fe_lag, 1)
                fe_lag_names[i,1]=string(fe_lag[i][1])
                fe_lag_vals[i,1]=fe_lag[i][2]
            end
            featureextraction_dict["fe_lag_names"] = fe_lag_names
            featureextraction_dict["fe_lag_lags"] = fe_lag_vals
        end

        if (featureextraction_dict["fe_lag"] != nothing || featureextraction_dict["fe_log"] != nothing ||
            featureextraction_dict["fe_inv"] != nothing || featureextraction_dict["fe_sqr"] != nothing ||
            featureextraction_dict["interaction"] != nothing)
            featureextraction_dict["removeoutliersfortex"] = Dict(:content => true)
        end

        dict[string(FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY)] = featureextraction_dict
    end

    if Output.OUTPUT_EXTRAKEY in keys(data.extras)
        dict[string(Output.OUTPUT_EXTRAKEY)] = process_dict(data.extras[Output.OUTPUT_EXTRAKEY])
    end

    return dict
end

function latex!(dict::Dict, data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult)
    if GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY in keys(data.extras)
        dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)] = process_dict(data.extras[GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY])
    end
    return dict
end

function latex!(dict::Dict, data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.CrossValidation.CrossValidationResult)
    if GlobalSearchRegression.CrossValidation.CROSSVALIDATION_EXTRAKEY in keys(data.extras)
        dict[string(GlobalSearchRegression.CrossValidation.CROSSVALIDATION_EXTRAKEY)] = process_dict(data.extras[GlobalSearchRegression.CrossValidation.CROSSVALIDATION_EXTRAKEY])
    end
    return dict
end

function process_dict(dict)
    dict_str = Dict()
    for key in keys(dict)
        key_str = string(key)
        if dict[key] != nothing
            dict_str[key_str] = dict[key]
        end
    end
    return dict_str
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
function render_latex(dict, destfolder::AbstractString)
    io = open(joinpath(destfolder, "main.tex"), "w")
    render = render_from_file(joinpath(TEX_TEMPLATE_FOLDER, "../tpl.tex"), dict)
    write(io, replace(render, "&quot;" => "\""))
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
