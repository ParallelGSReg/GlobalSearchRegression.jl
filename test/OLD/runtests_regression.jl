using CSV, GlobalSearchRegression.FeatureExtraction, GlobalSearchRegression.AllSubsetRegression, DataFrames

filename = "/home/adanmauri/Documentos/julia/15x1000.csv"
data = CSV.read(filename)

function test()
    gsreg_data = FeatureExtraction.featureextraction("y x1 x2 x3", data=data, intercept=true)
    gsreg_data = AllSubsetRegression.ols(gsreg_data, outsample=10, criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse], ttest=true)
end

@time test()

