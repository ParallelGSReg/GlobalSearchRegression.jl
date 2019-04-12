## UI
- [ ] Graphics

## gsreg

### Interace
- [ ] Do all the next steps in one single call.

### Data transformation
- [ ] Parse formula from multiple formats, including R, Stata and DataFrames # [checkbox:unchecked]
- [ ] Reduce database based on formula. (GUM) *including time if it's not included*
- [ ] Order database with time and panel variables and remove if it's not used as covariate
- [ ] Transform data representation for faster compute (Float64, Float32)
- [ ] Feature extraction. Optional creation of non-linear realtionships (sqaure, lag, log, inv)
- [ ] Fixed effect, First differences
- [ ] Exclude observations with missing or null values 
- [ ] Add intercept
 
### Preliminary selection
- [ ] Preselection with Lasso.jl based on covariates number
 
### Selection
- [ ] Parallel processing
- [ ] Iterative estimators (LOGIT, PROBIT) *****
- [ ] OLS
- [ ] Adjust selection to interact with feature extraction
- [ ] Compute t-test/z value
- [ ] Outsample
- [ ] Compute selection criteria (aic, cic, bic, r2, r2adj, rmse, rmsout, cp)
- [ ] Model averaging
- [ ] Residual tests
- [ ] Sort by selection criteria
 
### Output decoration
- [ ] CSV
- [ ] JSON
- [ ] LaTeX
- [ ] Jupyter plot
- [ ] Short console text
