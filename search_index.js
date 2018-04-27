var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Syntax-1",
    "page": "Introduction",
    "title": "Syntax",
    "category": "section",
    "text": "GSReg.gsreg(equation::String, data::DataFrame; noconstant::Bool=true)\nGSReg.gsreg(equation::Array{String}, data::DataFrame; noconstant::Bool=true)\nGSReg.gsreg(equation::Array{Symbol}, data::DataFrame; noconstant::Bool=true)\nGSReg.gsreg(equation::Array{Symbol}; data::DataFrame, noconstant::Bool=true)\n"
},

{
    "location": "index.html#Basic-usage-1",
    "page": "Introduction",
    "title": "Basic usage",
    "category": "section",
    "text": "To load the module:Pkg.clone(\"git://git@github.com:adanmauri/GSReg.jl.git\")To perform a regression analysis:using CSV\ndata = CSV.read(\"data.csv\")\n\nresult = GSReg.gsreg([:y, :x1, :x2, :x3], data; noconstant=true)"
},

{
    "location": "index.html#Other-usage-methods:-1",
    "page": "Introduction",
    "title": "Other usage methods:",
    "category": "section",
    "text": "\n# Stata like\nresult = GSReg.gsreg(\"y x1 x2 x3\", data)\n\n# Stata like with comma\nresult = GSReg.gsreg(\"y,x1,x2,x3\", data)\n\n# R like\nresult = GSReg.gsreg(\"y ~ x1 + x2 + x3\", data)\nresult = GSReg.gsreg(\"y ~ x1 + x2 + x3\", data=data)\n\n# Array of strings\nresult = GSReg.gsreg([\"y\", \"x1\", \"x2\", \"x3\"], data)\n\n# Also, with wildcard\nresult = GSReg.gsreg(\"y x*\", data)\nresult = GSReg.gsreg(\"y x1 x*\", data)\nresult = GSReg.gsreg(\"y ~ x*\", data)"
},

{
    "location": "index.html#Credits-1",
    "page": "Introduction",
    "title": "Credits",
    "category": "section",
    "text": "The GSReg module, which perform regression analysis, was written primarily by Demian Panigo, Valentín Mari and Adán Mauri Ungaro. The GSReg module was inpired by GSReg for Stata, written by Pablo Gluzmann and Demian Panigo."
},

{
    "location": "lib/functions.html#",
    "page": "Functions",
    "title": "Functions",
    "category": "page",
    "text": "a"
},

]}
