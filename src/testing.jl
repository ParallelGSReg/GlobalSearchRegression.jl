using DataFrames

addprocs(2)
println(nprocs())
include("GSReg.jl")
data = CSV.read("/home/adanmauri/Documentos/20x100.csv")
@time result = GSReg.gsreg("y x*", data; resultscsv=nothing, csv=nothing)
