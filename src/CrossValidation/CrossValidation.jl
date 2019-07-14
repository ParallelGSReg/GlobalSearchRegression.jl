module CrossValidation
    
    using ..GlobalSearchRegression
    using Random, Statistics, Printf
    import Base: iterate

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("structs/result.jl")
    include("core.jl")

    export kfoldcrossvalidation, CROSSVALIDATION_EXTRAKEY
end