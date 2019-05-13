# GlobalSearchRegression Modules

This document should be refactored and merged as an usage and arquitecture documentation. Also explain better if is needed.

## FeatureExtraction
The module converts from many datatypes and formats to a GlobalSearchRegression standard one.

### Features
- Parse a given equation from multiple formats, including R, Stata and DataFrames
- Reduce the database based on the equation (Including time if is not included)
- Order the database by time and panel variables then remove time if is not used as covariate
- Transforms data representation for faster compute (Float64, Float32)
- Feature extraction. Optional creation of non-linear realtionships: sqrt, log, inv, lag
- Fixed effect
- First differences
- Excludes observations with missing or null values
- Adds the intercept if it was expecified

### Basic usage

```julia
# String as Stata like
julia> featureextraction("y x1 x2 x3", data)

# String as R like
julia> featureextraction("y ~ x1 + x2 + x3", data)
julia> featureextraction("y ~ x1 + x2 + x3", data=data)

# Strings separated with comma
julia> featureextraction("y,x1,x2,x3", data)

# Array of strings
julia> featureextraction(["y", "x1", "x2", "x3"], data)

# Using wildcards
julia> featureextraction("y *", data)
julia> featureextraction("y x*", data)
julia> featureextraction("y x1 z*", data)
julia> featureextraction("y ~ x*", data)
julia> featureextraction("y ~ .", data)

# Using symbols
julia> featureextraction([:y, :x1, :x2, :x3], data)

# if the database is an array you should set the header independently
julia> featureextraction("y x1 x2 x3", data, datanames=header)

# if the database is a Tuble you should set the tuple with the first element as the data and the second element as the header
julia> featureextraction("y x1 x2 x3", (data, header))
```

### Advanced usage
* **`intercept`:** by default the GUM includes an intercept as a fixed covariate (e.g. it's included in every model). The default is `true`
* **`method`:** this option can be used to alternatively run estimations with Float32 of Float64 datatype. The default is `FAST` (Float32), to speed-up calculations. The available options are:
    - Float32: `FAST`, `:FAST`, `:fast`, `"FAST"`, `"fast"`
    - Float64: `PRECISE`, `:PRECISE`, `:precise`, `"PRECISE"`, `"precise"`
* **`time`:** determines which variable will be used to date (and pre-sort) observations. Time variable must be included as a symbol (e.g. `time=:x1`). Neither, gaps nor missing observations are allowed in this variable (missing observations are allowed in any other variable). By using this option, additional residuals tests are enabled.
* **`fe_sqr`:** defines which variables will be process for square feature extraction (e.g. `fe_sqr=:x1` or `fe_sqr=[:x1, :x2]`).
* **`fe_log`:** defines which variables will be process for logarithm feature extraction (e.g. `fe_log=:x1` or `fe_log=[:x1, :x2]`).
* **`fe_inv`:** defines which variables will be process for inverse feature extraction (e.g. `fe_inv=:x1` or `fe_inv=[:x1, :x2]`).
* **`fe_inv`:** defines which variables will be process for lag feature extraction (e.g. `fe_lag=:x1=>2` or `fe_lag=[:x1=>2, :x2=>5]`).
* **`fixedeffect`:** defines if fixed effect will be applied (e.g. fixedeffect=true). The default is `false`.
* **`panel`:** defines which variable is defined as panel (e.g. `panel=:x1`). 
* **`interaction`**: defines the product of two or more independent variables (e.g. `interaction=[x1, :x2, :x3]`).

### Full-syntax example

```julia
# The first four lines are used to simulate data with random variables
julia> using DataFrames
julia> data = DataFrame(Array{Union{Missing,Float64}}(randn(100,16)))
julia> headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
julia> names!(data, headers)
julia> using GlobalSearchRegression.FeatureExtraction
julia> FeatureExtraction.featureextraction("y x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15", data, 
    intercept=true, 
    method=FAST, 
    time=:x1,
    fe_sqr=[:x1, :x2],
    fe_log=[:x1, :x2],
    fe_inv=[:x1, :x2],
    fe_lag=[:x1=>2, :x2=>5],
    fixedeffect=true,
    panel=:y,
    interaction=[x1, :x2, :x3]
    )
```

## Response

```julia
# The response is a GSRegData datatype
julia> response.
        equation    depvar    expvars    depvar_data    expvars_data    intercept    time   panel    datatype
        nobs    original_nobs    fe_sqr    fe_log    fe_inv    fe_lag    fixedeffect    interaction     results
```

## Credits
The FeatureExtraction module is a sub-module of GlobalSearchRegression, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Adán Mauri Ungaro](https://github.com/adanmauri/) and [Valentín Mari](https://github.com/vmari/). The GlobalSearchRegression.jl module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).
