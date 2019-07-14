using CSV, GlobalSearchRegression, Distributed

data = CSV.read("data/small.csv")
@time data = GlobalSearchRegression.gsr("y x*", data, intercept=true, fe_sqr=:x1, preliminaryselection=:lasso)

print(GlobalSearchRegression.Output.summary(data))

"""
data = GlobalSearchRegression.Preprocessing.input("y x*", data, intercept=true)
data = GlobalSearchRegression.FeatureExtraction.featureextraction!(data, fe_lag=[:x1=>1, :y=>2])
data = GlobalSearchRegression.AllSubsetRegression.ols!(data)
println(data)
print(GlobalSearchRegression.Output.summary(data))


extras = Dict()

key = :input
extras[key] = Dict()
extras[key][:datanames] = [:y :x1 :x2 :x3]
extras[key][:depvar] = :y
extras[key][:expvars] = [:x1 :x2 :x3]
extras[key][:data] = "dataname"
extras[key][:method] = :fast
extras[key][:intercept] = true
extras[key][:panel] = :panel
extras[key][:time] = :time
extras[key][:seasonaladjustment] = true
extras[key][:removeoutliers] = true
extras[key][:removemissings] = true

key = :featureextraction
extras[key] = Dict()
extras[key][:fe_sqr] = [:x1]
extras[key][:fe_log] = nothing
extras[key][:fe_inv] = :x2
extras[key][:fe_lag] = [:x1 => 2]
extras[key][:interaction] = nothing
extras[key][:removemissings] = true

key = :preliminaryselection
extras[key] = Dict()
extras[key][:enabled] = true

key = :allsubsetregression
extras[key] = Dict()
extras[key][:outsample] = 20
extras[key][:criteria] = [:rmseout]
extras[key][:ttest] = true
extras[key][:modelavg] = true
extras[key][:residualtest] = true
extras[key][:orderresults] = true
extras[key][:fixedvariables] = nothing
"""