# GSReg [![Build Status](https://travis-ci.org/ParallelGSReg/GSReg.jl.svg?branch=master)](https://travis-ci.org/ParallelGSReg/GSReg.jl)

## Syntax

```julia
GSReg.gsreg(equation::String, data::DataFrame; noconstant::Bool=true)
GSReg.gsreg(equation::Array{String}, data::DataFrame; noconstant::Bool=true)
GSReg.gsreg(equation::Array{Symbol}, data::DataFrame; noconstant::Bool=true)
GSReg.gsreg(equation::Array{Symbol}; data::DataFrame, noconstant::Bool=true)

```

## Basic usage

To load the module:

```julia
Pkg.clone("git://git@github.com:ParallelGSReg/GSReg.jl.git")
```

To perform a regression analysis:

```julia
using CSV
data = CSV.read("data.csv")

result = GSReg.gsreg([:y, :x1, :x2, :x3], data; noconstant=true)
```

## Other usage methods:

```julia

# Stata like
result = GSReg.gsreg("y x1 x2 x3", data)

# Stata like with comma
result = GSReg.gsreg("y,x1,x2,x3", data)

# R like
result = GSReg.gsreg("y ~ x1 + x2 + x3", data)
result = GSReg.gsreg("y ~ x1 + x2 + x3", data=data)

# Array of strings
result = GSReg.gsreg(["y", "x1", "x2", "x3"], data)

# Also, with wildcard
result = GSReg.gsreg("y *", data)
result = GSReg.gsreg("y x*", data)
result = GSReg.gsreg("y x1 z*", data)
result = GSReg.gsreg("y ~ x*", data)
result = GSReg.gsreg("y ~ .", data)
```

outsample
samesample
threads
criteria => r2adj
            rmseout

Go to usage comparison for more information about how to use GSReg with a R and Stata comparison. *TODO*

## Credits

The GSReg module, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Valentín Mari](https://github.com/vmari/) and [Adán Mauri Ungaro](https://github.com/adanmauri/). The GSReg module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).
