# GlobalSearchRegression Modules

This document should be refactored and merged as an usage and arquitecture documentation. Also explain better if is needed.

## datatransformation
The module converts from many datatypes and formats to a GlobalSearchRegression standard one.

### Features
- Parse a given equation from multiple formats, including R, Stata and DataFrames
- Reduce the database based on the equation (Including time if is not included)
- Order the database by time and panel variables then remove time if is not used as covariate
- Transforms data representation for faster compute (Float64, Float32)
- Feature extraction. Optional creation of non-linear realtionships: sqrt, log, inv, [lag]

- [TODO: Explain better] Fixed effect. First differences
- Excludes observations with missing or null values
- Adds the intercept if it was expecified

### Basic usage

```julia
# String as Stata like
julia> datatransformation("y x1 x2 x3", data)

# String as R like
julia> datatransformation("y ~ x1 + x2 + x3", data)
julia> datatransformation("y ~ x1 + x2 + x3", data=data)

# Strings separated with comma
julia> datatransformation("y,x1,x2,x3", data)

# Array of strings
julia> datatransformation(["y", "x1", "x2", "x3"], data)

# Using wildcards
julia> datatransformation("y *", data)
julia> datatransformation("y x*", data)
julia> datatransformation("y x1 z*", data)
julia> datatransformation("y ~ x*", data)
julia> datatransformation("y ~ .", data)

# Using symbols
julia> datatransformation([:y, :x1, :x2, :x3], data)

# if the database is an array you should set the header independently
julia> datatransformation("y x1 x2 x3", data, datanames=header)

# if the database is a Tuble you should set the tuple with the first element as the data and the second element as the header
julia> datatransformation("y x1 x2 x3", (data, header))
```

### Advanced usage
* intercept: by default the GUM includes an intercept as a fixed covariate (e.g. it's included in every model). Alternatively, users can erase it by selecting the intercept=false boolean option.
* method: this option can be used to alternatively run estimations with Float32 of Float64 datatype. The default is Float32 (to speed-up calculations) but users can modify it through the method="precise" string option. The available options are:
    - Float32: FAST, :FAST, :fast, "FAST", "fast"
    - Float64: PRECISE, :PRECISE, :precise, "PRECISE", "precise"
* time: this option determines which variable will be used to date (and pre-sort) observations. Time variable must be included as a symbol (e.g. time=:x1). Neither, gaps nor missing observations are allowed in this variable (missing observations are allowed in any other variable). By using this option, additional residuals tests are enabled.

### Full-syntax example

```julia
# The first four lines are used to simulate data with random variables
julia> using DataFrames
julia> data = DataFrame(Array{Union{Missing,Float64}}(randn(100,16)))
julia> headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
julia> names!(data, headers)
julia> using GlobalSearchRegression
julia> datatransformation("y x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15", data, 
    intercept=true, 
    ttest=true, 
    method="precise", 
    time=:x1)
```

## Response

```julia
# The response is a GSRegData datatype
julia> response.
        datanames  datatype   depvar    depvar_data     expvars     expvars_data    intercept  nobs       time
```

## Credits
The datatransformation module is a sub-module of GlobalSearchRegression, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Valentín Mari](https://github.com/vmari/) and [Adán Mauri Ungaro](https://github.com/adanmauri/). The GlobalSearchRegression.jl module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).
