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
        create_workspace(path)
        if data.results[1].ttest
            create_figures(data, path)
        end
        render_latex(dict, path)
        zip_folder(path)
    end
end

function latex!(dict::Dict, data::GlobalSearchRegression.GSRegData)
    # Preprocessing    
    preprocessing_dict = process_dict(data.extras[Preprocessing.PREPROCESSING_EXTRAKEY])
    preprocessing_dict["equation"] = join(map(x -> "$x", filter(x -> x != :_cons, preprocessing_dict["datanames"])), " ")
    preprocessing_dict["datanames"] = string("[:", join(preprocessing_dict["datanames"], ", :"), "]")
    preprocessing_dict["descriptive"] = []

    datanames_index = GlobalSearchRegression.create_datanames_index(data.expvars) 
    
    for (i, var) in enumerate(data.expvars)
        orig = data.expvars_data[:, datanames_index[var]]
        obs = collect(skipmissing(orig))
        c_obs = length(obs)
        c_miss = length(orig) - c_obs
        push!(preprocessing_dict["descriptive"], Dict(
            "name" => string(var),
            "nobs" => length(obs),
            "mean" => @sprintf("%.2f", mean(obs)),
            "std"  => @sprintf("%.2f", std(obs)),
            "max"  => @sprintf("%.2f", maximum(obs)),
            "min"  => @sprintf("%.2f", minimum(obs)),
            "miss" => @sprintf("%.2f", (c_miss/c_obs)*100)
        ))
        if( (i + 1) % 54 == 0 )
            push!(preprocessing_dict["descriptive"], Dict("name" => false))
        end
    end

    if "seasonaladjustment" in keys(preprocessing_dict) && preprocessing_dict["seasonaladjustment"] != nothing
        preprocessing_dict["seasonaladjustment"] = get_array_details(preprocessing_dict["seasonaladjustment"])
    end
    dict[string(Preprocessing.PREPROCESSING_EXTRAKEY)] = preprocessing_dict

    # FeatureExtraction
    if FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY in keys(data.extras)
        featureextraction_dict = process_dict(featureextraction_dict[FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY])
        if featureextraction_dict["featureextraction"]["fe_lag"] != nothing
            featureextraction_dict["featureextraction"]["fe_lag"] = 
                get_array_details( featureextraction_dict["featureextraction"]["fe_lag"])
        end
        if featureextraction_dict["featureextraction"]["fe_log"] != nothing
            featureextraction_dict["featureextraction"]["fe_log"] = 
                get_array_simple_details( featureextraction_dict["featureextraction"]["fe_log"])
        end
        if featureextraction_dict["featureextraction"]["fe_inv"] != nothing
            featureextraction_dict["featureextraction"]["fe_inv"] = 
                get_array_simple_details( featureextraction_dict["featureextraction"]["fe_inv"])
        end
        if featureextraction_dict["featureextraction"]["fe_sqr"] != nothing
            featureextraction_dict["featureextraction"]["fe_sqr"] = 
                get_array_simple_details( featureextraction_dict["featureextraction"]["fe_sqr"])
        end
        if featureextraction_dict["featureextraction"]["interaction"] != nothing
            featureextraction_dict["featureextraction"]["interaction"] = 
                get_array_simple_details( featureextraction_dict["featureextraction"]["interaction"])
        end
        if  featureextraction_dict["featureextraction"]["fe_lag"] == nothing && 
            featureextraction_dict["featureextraction"]["fe_log"] == nothing &&
            featureextraction_dict["featureextraction"]["fe_inv"] == nothing &&
            featureextraction_dict["featureextraction"]["fe_sqr"] == nothing &&
            featureextraction_dict["featureextraction"]["interaction"] == nothing
            featureextraction_dict["featureextraction"] = false
        end
        dict[string(FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY)] = featureextraction_dict
    end

    # PreliminarySelection
    if PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY in keys(data.extras)
        dict[string(PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY)] = process_dict(data.extras[PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY])
    end

    # Output
    if Output.OUTPUT_EXTRAKEY in keys(data.extras)
        dict[string(Output.OUTPUT_EXTRAKEY)] = process_dict(data.extras[Output.OUTPUT_EXTRAKEY])
    end


    """
    dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)] = process_dict(data.extras[GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY])

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


    """
    return dict
end

function latex!(dict::Dict, data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult)
    if GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY in keys(data.extras)
        dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)] = process_dict(data.extras[GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY])
        
        datanames_index = GlobalSearchRegression.create_datanames_index(result.datanames)
        cols = GlobalSearchRegression.get_selected_variables(Int64(result.bestresult_data[datanames_index[:index]]), data.expvars, data.intercept)
        
        modelavg_datanames = GlobalSearchRegression.AllSubsetRegression.get_varnames(result.modelavg_datanames)

        d_bestmodel = Dict()
        d_bestmodel["depvar"] = data.depvar
        d_bestmodel["bmexpvars"] = []

        for var in data.expvars
            intercept = if (data.intercept) 1 else 0 end
            d = Dict()
            d["name"] = var
            
            if (var in data.expvars[cols] && !isnan(result.bestresult_data[datanames_index[Symbol("$(var)_b")]]))
                d["best"] = Dict()
                d["best"]["b"] = @sprintf("%.3f", result.bestresult_data[datanames_index[Symbol("$(var)_b")]])
                if (result.ttest)
                    d["best"]["ttest"] = true
                    d["best"]["bstd"] = @sprintf("%.3f", result.bestresult_data[datanames_index[Symbol("$(var)_bstd")]])
                    t = result.bestresult_data[datanames_index[Symbol("$(var)_t")]]
                    if (t < 0.01)
                        d["best"]["stars"] = "***"
                    else 
                        if (t < 0.05)
                            d["best"]["stars"] = "**"
                        else 
                            d["best"]["stars"] = "*"
                        end
                    end
                end
            end

            if (result.modelavg && !isnan(result.modelavg_data[datanames_index[Symbol("$(var)_b")]]))
                d_bestmodel["modelavg"] = true
                d["avg"] = Dict()
                d["avg"]["b"] = @sprintf("%.3f", result.modelavg_data[datanames_index[Symbol("$(var)_b")]])
                if (result.ttest)
                    d["avg"]["ttest"] = true
                    d["avg"]["bstd"] = @sprintf("%.3f", result.modelavg_data[datanames_index[Symbol("$(var)_bstd")]])
                    t = result.modelavg_data[datanames_index[Symbol("$(var)_t")]]
                    if (t < 0.01)
                        d["avg"]["stars"] = "***"
                    else 
                        if (t < 0.05)
                            d["avg"]["stars"] = "**"
                        else 
                            d["avg"]["stars"] = "*"
                        end
                    end
                end
            end
            if ("best" in keys(d) || "avg" in keys(d))
                push!(d_bestmodel["bmexpvars"], d)
            end
        end

        dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["bestmodel"] = d_bestmodel

        if dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["criteria"] != nothing
            dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["criteria"] = 
            get_array_simple_details(dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["criteria"])
        end

        if dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["residualtest"] != false
            if "time" in keys(dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]) && 
                dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["time"] != nothing
                dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["residualtestfortex2"] = true
            else
                dict[string(GlobalSearchRegression.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["residualtestfortex"] = true
            end
        end
    end
    return dict
end

function latex!(dict::Dict, data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.CrossValidation.CrossValidationResult)
    if GlobalSearchRegression.CrossValidation.CROSSVALIDATION_EXTRAKEY in keys(data.extras)
        dict[string(GlobalSearchRegression.CrossValidation.CROSSVALIDATION_EXTRAKEY)] = 
        process_dict(data.extras[GlobalSearchRegression.CrossValidation.CROSSVALIDATION_EXTRAKEY])
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
    cp(TEX_TEMPLATE_FOLDER, destfolder, force=true)
end

"""
Write template based on dict info
"""
function render_latex(dict, destfolder::AbstractString)
    print(dict)
    io = open(joinpath(destfolder, "main.tex"), "w")
    render = render_from_file(joinpath(TEX_TEMPLATE_FOLDER, "../tpl.tex"), dict)
    write(io, render)
    close(io)
end

function zip_folder(destfolder::AbstractString)
    create_zip(joinpath(destfolder,"GSREG.zip"), map(p->joinpath(destfolder, p),readdir(destfolder)))
end

"""
Create required figures by the template. Generate png images into the dest folder
"""
function create_figures(data, destfolder)
    expvars2 = data.expvars
    deleteat!(expvars2, GlobalSearchRegression.get_column_index(:_cons, data.expvars))

    criteria_diff = Array{Any}(undef, size(expvars2,1), 2)

    for (i, expvar) in enumerate(expvars2)
        bcol = GlobalSearchRegression.get_column_index(Symbol("$(expvar)_b"), data.results[1].datanames)
        tcol = GlobalSearchRegression.get_column_index(Symbol("$(expvar)_t"), data.results[1].datanames)
        r2col = GlobalSearchRegression.get_column_index(:r2adj, data.results[1].datanames)
        
        x = data.results[1].data[findall(x -> !isnan(x), data.results[1].data[:, bcol]), bcol]
        y = data.results[1].data[findall(x -> !isnan(x), data.results[1].data[:, tcol]), tcol]
        
        biden = kde((x, y), npoints=(100,100))
        
        contour(biden.x, biden.y, biden.density; xlabel="Coef. $expvar", ylabel="t-test $expvar")
        savefig(joinpath(destfolder, "contour_$(expvar)_b_t.png"))
    
        wireframe(biden.x, biden.y, biden.density; xlabel="Coef. $expvar", ylabel="t-test $expvar", camera=(45,45))
        savefig(joinpath(destfolder, "wireframe_$(expvar)_b_t.png"))
    
        criteria_with = data.results[1].data[findall(x -> !isnan(x), data.results[1].data[:, bcol]), r2col]
        criteria_without = data.results[1].data[findall(x -> isnan(x), data.results[1].data[:, bcol]), r2col]
        
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

        println(joinpath(destfolder, "asdasd"))
        
        criteria_diff[i, 1] = mean(criteria_with) - mean(criteria_without)
        criteria_diff[i, 2] = "$(expvar)"
    end

    a = sortslices(criteria_diff, dims = 1)
    labels = convert(Array{String}, a[:,2])
    bar(labels, a[:,1], legend = false, color = :blues, orientation = :horizontal, xlabel="Average impact of each variable on the Adj. R2")
    savefig(joinpath(destfolder, "cov_relevance.png"))
    println(joinpath(destfolder, "cov_relevance.png"))
end
