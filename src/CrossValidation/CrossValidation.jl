module CrossValidation
    
    using ..GlobalSearchRegression
    using Random
    import Base: iterate

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("core.jl")

    export kfoldcrossvalidation
end