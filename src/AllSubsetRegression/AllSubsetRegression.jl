module AllSubsetRegression

    using Printf

    using Distributed, Distributions, SharedArrays, LinearAlgebra
    using ..GlobalSearchRegression

    export ols, ols!, to_string, AllSubsetRegressionResult, ALLSUBSETREGRESSION_EXTRAKEY
    
    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("structs/result.jl")
    include("core.jl")
    include("estimators/ols.jl")
end
