extras = Dict()


extras = Dict()

extras[get_keys(:a, extras)] = "hola"
println(extras)
extras[get_keys(:a, extras)] = "hola"
println(extras)


"""using CSV, GlobalSearchRegression, Distributed

data = CSV.read("data/small.csv")
data = GlobalSearchRegression.Preprocessing.input("y x*", data, intercept=true)
println(data.expvars)
data = GlobalSearchRegression.FeatureExtraction.featureextraction!(data, fe_lag=[:x1=>1, :y=>2])
println(data.extras)

#data = GlobalSearchRegression.AllSubsetRegression.ols!(data)

#GlobalSearchRegression.Output.summary(data, "summary.txt")
#GlobalSearchRegression.Output.csv(data, "salida.csv")
"""