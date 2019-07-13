module AllSubsetRegression

    using Distributed, Distributions, SharedArrays, LinearAlgebra
    using ..GlobalSearchRegression

    export ols, run_ols, AllSubsetRegressionResult

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("estimators/ols.jl")
    include("structs/result.jl")
end
