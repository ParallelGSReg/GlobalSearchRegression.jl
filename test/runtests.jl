Pkg.add("Test")
using GSReg, Test, DataFrames, CSV, Distributions
data = DataFrame(randn(10,6))

res = gsreg("x1 x2 x3 x4 x5 x6", data; ttest=true, residualtest=true, criteria=[:aic, :bic], csv="pepe.csv")
@test size(res.results,1) == 31
