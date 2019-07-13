using CSV, GlobalSearchRegression, Distributed

data = randn(10,10)
for i in 1:10
    for n in 1:10
        data[i,n] = parse(Int, string(i,n))
    end
end
datanames = [:y, :x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9]

data = GlobalSearchRegression.Preprocessing.input(
    "y x*",
    data,
    datanames=datanames,
    intercept=true
)

data2 = GlobalSearchRegression.FeatureExtraction.featureextraction!(data, fe_sqr=:x1)
println(data2)
println(data2.expvars_data)
