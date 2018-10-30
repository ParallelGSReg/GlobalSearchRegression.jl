#   - Variables
#       Intercambiar variables
#       Remover una variable del medio
#       Cambiar la variable dependiente
#       
using Test, GSReg, DataFrames, Distributions, DelimitedFiles

data = readdlm("testdata.csv", ',', Float64, header=true)
data = gsreg("x2 x1 x3", data; ttest=true, residualtest=true, criteria=[:aic, :bic, :r2adj], csv="output.csv")
println(data)

#@test size(res.results,1) == 31


data = readdlm("withmissing.csv", ',', header=true)