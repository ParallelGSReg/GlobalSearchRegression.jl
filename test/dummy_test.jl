using CSV, GlobalSearchRegression, Distributed

data = CSV.read("data/small.csv")
data = GlobalSearchRegression.Preprocessing.input("y x*", data, intercept=true)
data = GlobalSearchRegression.FeatureExtraction.featureextraction!(data, fe_lag=[:x1=>1, :y=>2])
data = GlobalSearchRegression.AllSubsetRegression.ols!(data)
println(data)
print(GlobalSearchRegression.Output.summary(data))
