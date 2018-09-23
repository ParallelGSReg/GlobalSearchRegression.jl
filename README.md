# GSReg [![Build Status](https://travis-ci.org/ParallelGSReg/GSReg.jl.svg?branch=master)](https://travis-ci.org/ParallelGSReg/GSReg.jl)

## Abstract
GSReg is an automatic model selection command for time series, cross-section and panel data regressions. By default (otherwise, users have many options to modify this simplest specification), gsreg performs alternative OLS regressions looking for the best depvar Data Generating Process, iterating over all possible combinations among explanatory variables

## Syntax

```julia
gsreg(equation::String, data::DataFrame)
gsreg(equation::Array{String}, data::DataFrame)
gsreg(equation::Array{Symbol}, data::DataFrame)
```

## Basic usage

To perform a regression analysis:

```julia
using CSV, GSReg

data = CSV.read("data.csv")

result = gsreg("y x*", data)
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
result = gsreg("y *", data)
result = gsreg("y x*", data)
result = gsreg("y x1 z*", data)
result = gsreg("y ~ x*", data)
result = gsreg("y ~ .", data)
```
## Full usage options

```julia
using CSV, GSReg

data = CSV.read("data.csv")

result = gsreg("y x*", data,
    intercept=true,
    outsample=10,
    criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse],
    ttest=true,
    method="fast", #precise
    vectoroperation=true,
    modelavg=true,
    residualtest=false,
    time=:date,
    summary=false,
    csv="output.csv",
    resultscsv="output.csv",
    orderresults=false
)
```

## Options:

intercept::Bool,
outsample::Int,
samesample::Bool,
criteria::Array,
ttest::Bool,
method{fast,precise},
vectoroperation::Bool,
modelavg::Bool,
residualtest::Bool,
time=Symbol,
summary=Bool,
csv=String,
resultscsv=String (alias),
orderresults=Boolean(false)


## Parallel

You must run julia with -p option

 
## Credits

The GSReg module, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Valentín Mari](https://github.com/vmari/) and [Adán Mauri Ungaro](https://github.com/adanmauri/). The GSReg module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).
