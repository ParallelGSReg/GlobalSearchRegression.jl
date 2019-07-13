module AllSubsetRegression

    using Printf

    using Distributed, Distributions, SharedArrays, LinearAlgebra
    using ..GlobalSearchRegression

    export ols, ols!, AllSubsetRegressionResult
    
    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("structs/result.jl")
    include("estimators/ols.jl")
end
