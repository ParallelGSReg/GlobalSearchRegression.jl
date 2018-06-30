addprocs(2)
println(nprocs())
include("GSReg.jl")
data = CSV.read("/home/adanmauri/Documentos/julia/12mb.csv")
@time GSReg.gsreg("y x1 x2", data; resultscsv=nothing, csv=nothing)

