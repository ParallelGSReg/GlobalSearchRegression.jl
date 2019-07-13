module OutputDecoration
    
    using ..GlobalSearchRegression
    using KernelDensity, Distributions, StatsPlots, Plots, Mustache, Statistics, Printf

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("core.jl")

    export latex

end