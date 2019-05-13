module AllSubsetRegression

    using Distributed
    using Distributions
    using SharedArrays
    using LinearAlgebra
    using ..GlobalSearchRegression

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("estimators/ols.jl")

    export ols
end