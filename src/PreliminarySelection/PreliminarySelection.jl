module PreliminarySelection

    using GLMNet, ..GlobalSearchRegression: GSRegData

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("core.jl")

    export lasso

end