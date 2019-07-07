########################################################
#
# The gsregp_linux.ado package is not published yet
# Nevertheless, it is avaible upon request from authors
#
########################################################

qui clear all
# Define your working directory path here

clear all
set seed 1234
set obs 100

set processor 1
matrix timings=J(4,4,.)

gen y=runiform()
forvalues i = 1(1)15{
qui gen x`i'=runiform()
loc lista "x`i'"
}

local h=1
foreach num of numlist 1 4 16 32 {
timer on `num'
gsregp_linux y x*,  parallel(`num') nocount res(timer_15_100_`num'.dta)  replace
timer off `num'
timer list `num'
local t_15_100_`num' = r(t`num')
matrix timings[`h',1]=`t_15_100_`num''
local ++h
}

clear
set obs 1000
gen y=runiform()
forvalues i = 1(1)15{
qui gen x`i'=runiform()
loc lista "x`i'"
}

local h=1
foreach num of numlist 1 4 16 32 {
timer on `num'
gsregp_linux y x*,  parallel(`num') nocount res(timer_15_1000_`num'.dta)  replace
timer off `num'
timer list `num'
local t_15_1000_`num' = r(t`num')
matrix timings[`h',2]=`t_15_1000_`num''
local ++h
}


clear
set obs 10000
gen y=runiform()
forvalues i = 1(1)15{
qui gen x`i'=runiform()
loc lista "x`i'"
}

local h=1
foreach num of numlist 1 4 16 32 {
timer on `num'
gsregp_linux y x*,  parallel(`num') nocount res(timer_15_10000_`num'.dta)  replace
timer off `num'
timer list `num'
local t_15_10000_`num' = r(t`num')
matrix timings[`h',3]=`t_15_10000_`num''
local ++h
}


clear
set obs 100
gen y=runiform()
forvalues i = 1(1)20{
qui gen x`i'=runiform()
loc lista "x`i'"
}

local h=1
foreach num of numlist 1 4 16 32 {
timer on `num'
gsregp_linux y x*,  parallel(`num') nocount res(timer_20_100_`num'.dta)  replace
timer off `num'
timer list `num'
local t_20_100_`num' = r(t`num')
matrix timings[`h',4]=`t_20_100_`num''
local ++h
}
clear
svmat timings
rename timings1 15x100
rename timings2 15x1000
rename timings3 15x10000
rename timings4 20x100
export delimited using "timingstata.csv", replace


