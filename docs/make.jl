using Documenter, GlobalSearchRegression

makedocs(
    # options
    format = Documenter.HTML(assets = ["assets/logo.png"]),
    modules = [GlobalSearchRegression],
    doctest = false,
    clean = false,
    sitename = "GlobalSearchRegression.jl",
    pages = Any[
        "Introduction" => "index.md",
        "API" => "api.md"
    ]
)

# Deploy built documentation from Travis.
# =======================================

deploydocs(
    repo = "github.com/ParallelGSReg/GlobalSearchRegression.jl.git",
    target = "build",
    julia = "1.0",
    deps = nothing,
    make = nothing,
)
