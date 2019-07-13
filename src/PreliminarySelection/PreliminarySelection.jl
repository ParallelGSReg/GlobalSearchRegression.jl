module PreliminarySelection
    using GLMNet
    using ..GlobalSearchRegression

    export lasso, lassoselection

    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("core.jl")
end
