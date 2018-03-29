# GSReg

[![Build Status](https://travis-ci.org/adanmauri/GSReg.jl.svg?branch=master)](https://travis-ci.org/adanmauri/GSReg.jl)

[![Coverage Status](https://coveralls.io/repos/adanmauri/GSReg.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/adanmauri/GSReg.jl?branch=master)

[![codecov.io](http://codecov.io/github/adanmauri/GSReg.jl/coverage.svg?branch=master)](http://codecov.io/github/adanmauri/GSReg.jl?branch=master)

## Syntax

```julia
GSReg.gsreg(equation::String, data::DataFrame, noconstant::Bool=true)
GSReg.gsreg(equation::Array{String}, data::DataFrame, noconstant::Bool=true)
GSReg.gsreg(equation::Array{Symbol}, data::DataFrame, noconstant::Bool=true)
```

## Basic usage

To load the module:

```julia
include("gsreg.jl")
```

To perform a regression analysis:

```julia
using CSV
data = CSV.read("data.csv")

result = GSReg.gsreg([:y, :x1, :x2, :x3], data, false)
```

## Other usage methods:

```julia

result = GSReg.gsreg(["y", "x1", "x2", "x3"], data, false)
result = GSReg.gsreg("y x1 x2 x3"], data, false)
result = GSReg.gsreg("y,x1,x2,x3"], data, false)

# Also, with wildcard
result = GSReg.gsreg("y x*"], data, false)
result = GSReg.gsreg("y x1 x*"], data, false)
```

## Credits

The GSReg module, which perform regression analysis, was written primarily by [Demián Panigo](https://github.com/dpanigo/), [Valentín Mari](https://github.com/vmari/), [Adán Mauri Ungaro](https://github.com/adanmauri/). The GSReg module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demián Panigo](https://github.com/dpanigo/).
