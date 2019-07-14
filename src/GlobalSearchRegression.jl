module GlobalSearchRegression

    using DataFrames

    include("structs/gsreg_data.jl")
    include("datatypes/gsreg_result.jl")
    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("core.jl")

    include("Preprocessing/Preprocessing.jl")
    include("FeatureExtraction/FeatureExtraction.jl")
    include("PreliminarySelection/PreliminarySelection.jl")
    include("AllSubsetRegression/AllSubsetRegression.jl")
    #include("CrossValidation/CrossValidation.jl")
    include("Output/Output.jl")

    using ..Preprocessing
    using ..FeatureExtraction
    using ..PreliminarySelection
    using ..AllSubsetRegression
    using ..Output

    export GSRegData, GSRegResult, gsr

    export Preprocessing, FeatureExtraction, PreliminarySelection, Output

end
