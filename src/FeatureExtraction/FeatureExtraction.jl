module FeatureExtraction
    using Statistics
    using ShiftedArrays
    using ..GlobalSearchRegression

    export featureextraction

    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("core.jl")
end
