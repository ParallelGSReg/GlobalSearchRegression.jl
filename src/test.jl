addprocs(2)
include("GSReg.jl")
using CSV
data = CSV.read("/home/sdf/Documentos/20x100.csv")
@time result = GSReg.gsreg("y x*", data; vectoroperation=false, resultscsv=nothing)
