clear all
set processor 1

set seed 1234
set obs 1000

gen y=runiform()
forvalues i = 1(1)200{
qui gen x`i'=runiform()
loc lista "x`i'"
}

timer clear

timer on 1
reg y x1-x200
timer off 1

timer list
