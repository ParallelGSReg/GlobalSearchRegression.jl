## Syntax

```julia
gsreg(equation::String, data::DataFrame; noconstant::Bool=true)
gsreg(equation::Array{String}, data::DataFrame; noconstant::Bool=true)
gsreg(equation::Array{Symbol}, data::DataFrame; noconstant::Bool=true)
gsreg(equation::Array{Symbol}; data::DataFrame, noconstant::Bool=true)

```

## Basic usage

To load the module:

```julia
Pkg.clone("git://git@github.com:ParallelGSReg/GlobalSearchRegression.jl.git")
```

To perform a regression analysis:

```julia
using CSV
data = CSV.read("data.csv")

result = gsreg([:y, :x1, :x2, :x3], data; noconstant=true)
```

## Other usage methods:

```julia

# Stata like
result = gsreg("y x1 x2 x3", data)

# Stata like with comma
result = gsreg("y,x1,x2,x3", data)

# R like
result = gsreg("y ~ x1 + x2 + x3", data)
result = gsreg("y ~ x1 + x2 + x3", data=data)

# Array of strings
result = gsreg(["y", "x1", "x2", "x3"], data)

# Also, with wildcard
result = gsreg("y x*", data)
result = gsreg("y x1 x*", data)
result = gsreg("y ~ x*", data)
```

## Credits

The GlobalSearchRegression module, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Valentín Mari](https://github.com/vmari/) and [Adán Mauri Ungaro](https://github.com/adanmauri/). The GlobalSearchRegression and the GlobalSearchRegressionGUI module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).
