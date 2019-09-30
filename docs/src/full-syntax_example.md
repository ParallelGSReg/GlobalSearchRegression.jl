## Full-syntax example
This is a full-syntax example, assuming Julia 1.0.1 (or newer version), GlobalSearchRegression and DataFrames are already installed in a quad-core personal computer.
```julia
# The first four lines are used to simulate data with random variables
julia> using DataFrames
julia> data = DataFrame(Array{Union{Missing,Float64}}(randn(100,16)))
julia> headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
julia> names!(data, headers)
# The following two lines enable multicore calculations
julia> using Distributed
julia> addprocs(4)
# Next line defines the working directory (where output results will be saved), for example:
julia> cd("c:\\")  # in Windows, or
julia> cd("/home/")  # in Linux
# Final two lines are used to perform all-subset-regression
julia> using GlobalSearchRegression
julia> gsreg("y x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15", data, 
    intercept=true, 
    outsample=10, 
    criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse], 
    ttest=true, 
    method="precise", 
    vectoroperation=true,
    modelavg=true,
    residualtest=true,
    time=:x1,
    csv="output.csv",
    parallel=4,
    orderresults=false)
```