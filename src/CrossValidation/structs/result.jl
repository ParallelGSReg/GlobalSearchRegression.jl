mutable struct CrossValidationResult <: GlobalSearchRegression.GSRegResult

    k::Int64
    s::Float64

    mean
    median

    function CrossValidationResult(
            k,
            s,
            mean,
            median
        )
        new(k, s, mean, median)
    end
end
