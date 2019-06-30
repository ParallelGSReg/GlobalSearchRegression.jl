module Preprocessing
    using DataFrames
    using ..GlobalSearchRegression
    using ..GlobalSearchRegression: get_column_index, in_vector

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("core.jl")

    export input
end