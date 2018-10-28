#   - Variables
#       Intercambiar variables
#       Remover una variable del medio
#       Cambiar la variable dependiente
#       
using Test, GSReg, DataFrames, Distributions, DelimitedFiles

data = readdlm("testdata.csv", ',', Float64, header=true)
data = gsreg("y x1 x3", data; ttest=true, residualtest=true, criteria=[:aic, :bic])
println(data)

#@test size(res.results,1) == 31
