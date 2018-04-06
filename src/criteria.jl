"""
#AKAIKE
aic = obs*log(rmse_in) + 2*(nvar-1) + obs + obs*log(2*_pi)

#CORRECTED AKAIKE
caic = aic + (2*(nvar+1)*(nvar+2))/(obs-(nvar+1)-1)

#MALLOW'S CP
sum nvar
local m = r(max)
sum rmse_in
local min_rmse_in = r(min)
cp = (obs - `m' - 2)*(rmse_in/`min_rmse_in') - (obs - 2 * nvar)

#BIC
bic = obs*log(rmse_in) + (nvar-1)*log(obs) + obs + obs*log(2*_pi)

#R2adj
R2adj = 1 - (1 - R2) * ((obs - 1) / (obs - nvar))
"""