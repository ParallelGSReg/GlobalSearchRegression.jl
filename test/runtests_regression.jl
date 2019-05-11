using CSV, GlobalSearchRegression.FeatureExtraction, GlobalSearchRegression.Regression, DataFrames

filename = "/home/adanmauri/Documentos/julia/15x1000.csv"
data = CSV.read(filename)
gsreg_data = FeatureExtraction.featureextraction("y x1 x2 x3", data=data, intercept=true)
gsreg_result = Regression.ols(gsreg_data, outsample=10, criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse], ttest=true)
#names!(dt, gsreg_result.datanames)
println(gsreg_result.bestresults)