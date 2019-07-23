function gsr(
    equation::Union{String, Array{String}, Array{Symbol}},
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing};
    datanames::Union{Array, Array{Symbol, 1}, Nothing}=nothing,
    method::Union{Symbol, String}=Preprocessing.METHOD_DEFAULT,
    intercept::Bool=Preprocessing.INTERCEPT_DEFAULT,
    panel::Union{Symbol, String, Nothing}=Preprocessing.PANEL_DEFAULT,
    time::Union{Symbol, String, Nothing}=Preprocessing.TIME_DEFAULT,
    seasonaladjustment::Union{Dict, Array, Nothing}=Preprocessing.SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool=Preprocessing.REMOVEOUTLIERS_DEFAULT,
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array}=nothing,
    preliminaryselection::Union{Nothing, Symbol}=nothing,
    fixedvariables::Union{Nothing, Array}=AllSubsetRegression.FIXEDVARIABLES_DEFAULT,
    outsample=AllSubsetRegression.OUTSAMPLE_DEFAULT,
    criteria::Array=AllSubsetRegression.CRITERIA_DEFAULT,
    ttest::Bool=AllSubsetRegression.TTEST_DEFAULT,
    modelavg::Bool=AllSubsetRegression.MODELAVG_DEFAULT,
    residualtest::Bool=AllSubsetRegression.RESIDUALTEST_DEFAULT,
    orderresults::Bool=AllSubsetRegression.ORDERRESULTS_DEFAULT,
    kfoldcrossvalidation::Bool=KFOLDCROSSVALIDATION_DEFAULT,
    numfolds::Int=NUMFOLDS_DEFAULT,
    testsetshare::Union{Float32, Float64}=TESTSETSHARE_DEFAULT,
    exportcsv::Union{Nothing, String}=EXPORTCSV_DEFAULT,
    exportsummary::Union{Nothing, String}=EXPORTSUMMARY_DEFAULT
    )

    gsr(
        equation,
        data=data,
        datanames=datanames,
        method=method,
        intercept=intercept,
        panel=panel,
        time=time,
        seasonaladjustment=seasonaladjustment,
        removeoutliers=removeoutliers,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        interaction=interaction,
        preliminaryselection=preliminaryselection,
        fixedvariables=fixedvariables,
        outsample=outsample,
        criteria=criteria,
        ttest=ttest,
        modelavg=modelavg,
        residualtest=residualtest,
        orderresults=orderresults,
        kfoldcrossvalidation=kfoldcrossvalidation,
        numfolds=numfolds,
        testsetshare=testsetshare,
        exportcsv=exportcsv,
        exportsummary=exportsummary
    )
end

function gsr(
    equation::Union{String, Array{String}, Array{Symbol}};
    data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing},
    datanames::Union{Array, Array{Symbol, 1}, Nothing}=nothing,
    method::Union{Symbol, String}=Preprocessing.METHOD_DEFAULT,
    intercept::Bool=Preprocessing.INTERCEPT_DEFAULT,
    panel::Union{Symbol, String, Nothing}=Preprocessing.PANEL_DEFAULT,
    time::Union{Symbol, String, Nothing}=Preprocessing.TIME_DEFAULT,
    seasonaladjustment::Union{Dict, Array, Nothing}=Preprocessing.SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool=Preprocessing.REMOVEOUTLIERS_DEFAULT,
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array}=nothing,
    preliminaryselection::Union{Nothing, Symbol}=nothing,
    fixedvariables::Union{Nothing, Array}=AllSubsetRegression.FIXEDVARIABLES_DEFAULT,
    outsample=AllSubsetRegression.OUTSAMPLE_DEFAULT,
    criteria::Array=AllSubsetRegression.CRITERIA_DEFAULT,
    ttest::Bool=AllSubsetRegression.TTEST_DEFAULT,
    modelavg::Bool=AllSubsetRegression.MODELAVG_DEFAULT,
    residualtest::Bool=AllSubsetRegression.RESIDUALTEST_DEFAULT,
    orderresults::Bool=AllSubsetRegression.ORDERRESULTS_DEFAULT,
    kfoldcrossvalidation::Bool=KFOLDCROSSVALIDATION_DEFAULT,
    numfolds::Int=NUMFOLDS_DEFAULT,
    testsetshare::Union{Float32, Float64}=TESTSETSHARE_DEFAULT,
    exportcsv::Union{Nothing, String}=EXPORTCSV_DEFAULT,
    exportsummary::Union{Nothing, String}=EXPORTSUMMARY_DEFAULT
)

    if fe_lag == nothing || seasonaladjustment != nothing
        removemissings = true
    else
        removemissings = false
    end

    data = Preprocessing.input(
        equation,
        data=data,
        datanames=datanames,
        method=method,
        intercept=intercept,
        panel=panel,
        time=time,
        seasonaladjustment=seasonaladjustment,
        removeoutliers=removeoutliers,
        removemissings=removemissings
    )

    if featureextraction_enabled(fe_sqr, fe_log, fe_inv, fe_lag, interaction)
        data = FeatureExtraction.featureextraction!(data, fe_lag=fe_lag, fe_log=fe_log, fe_inv=fe_inv, interaction=interaction, removemissings=true)
    end

    original_data = copy_data(data)
    
    if preliminaryselection_enabled(preliminaryselection)
        preliminaryselection = Symbol(preliminaryselection)
        if !validate_preliminaryselection(preliminaryselection)
            error(INVALID_PRELIMINARYSELECTION)
        end
        data = PreliminarySelection._lasso!(data)
        original_data.extras = data.extras
    end
    
    AllSubsetRegression.ols!(
        data,
        fixedvariables=fixedvariables,
        outsample=outsample,
        criteria=criteria,
        ttest=ttest,
        modelavg=modelavg,
        residualtest=residualtest,
        orderresults=orderresults
    )

    original_data.extras = data.extras
    
    if kfoldcrossvalidation
        CrossValidation.kfoldcrossvalidation!(data, original_data, numfolds, testsetshare)
    end

    if exportcsv != nothing
        GlobalSearchRegression.Output.csv(data, exportcsv)
    end

    println(GlobalSearchRegression.Output.summary(data, filename=exportsummary))

    return data
end
