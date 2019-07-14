module PreliminarySelection
    using GLMNet
    using ..GlobalSearchRegression

    export lasso!, lasso, lassoselection, PRELIMINARYSELECTION_EXTRAKEY, _lasso!, _lasso

    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("core.jl")
end
