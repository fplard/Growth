# Growth model selection

This function fit a series of growth models to a dataset and select the
best one by wAIC.

## Usage

``` r
Gro_analysis(
  data_weight,
  all_mods = c("vonbertalanffy"),
  random = list(),
  logtransform = FALSE,
  run = list(nit = 100, nburnin = 10, nthin = 1, nch = 1),
  parallel = FALSE
)
```

## Arguments

- data_weight:

  `data.frame` including at least the numeric columns *Age*,
  *MeasurementValue* and *AnimalAnonID*

- all_mods:

  `vector of character` indicating the growth models that need to be
  fit.The following models are supported :logistic, gompertz, tpgm,
  power, richards, vonbertalanffy. default = "vonBertalanffy"

- random:

  list of the model names giving the parameters that should include an
  individual random effect. See the example

- logtransform:

  logical whether age and measurement values should be log transform (+1
  is added to avoid having log(0))

- run:

  `list` Bayesian parameters. They should be increased to reach
  convergence

  - `nch` number of chains.

  - `nthin` interval between iterations to keep.

  - `nburnin` number of iterations to discard.

  - `nit` total number of iterations.

- parallel:

  `logical` Whether the model should be run in parallel

## Value

a list including:

- model: the fit of the best model

- the wAIC table of the model

## Examples

``` r
Age <- sample(c(0:10), 1000, replace = TRUE)
MeasurementValue <- exp(0.2+15 * (1 - exp(-(0.1) * log(Age+1)))+ rnorm(1000,0,0.01))-1 
AnimalAnonID <- sample(c(0:20), 100, replace = TRUE)
dat = data.frame(Age = Age, MeasurementValue = MeasurementValue, 
                 AnimalAnonID = AnimalAnonID, MeasurementType = "Live Weight")

#Test 4 models: vonbertalanffy including an individual random effect on z0
#               vonbertalanffy including individual random effects on z0 and zinf
#               gompertz including an individual random effect on gamma 
#               gompertz including no individual random effect
a = Gro_analysis(dat, all_mods  = c("vonbertalanffy", "gompertz"),
                 random = list(vonbertalanffy = c("z0", "z0, zinf"), gompertz = c("gamma", "")),
                 run = list(nit = 1000, nburnin = 100, nthin = 1, nch = 1))
#>  * parallel has been set to FALSE, please wait more !
#> nimble version 1.3.0 is loaded.
#> For more information on NIMBLE and a User Manual,
#> please visit https://R-nimble.org.
#> 
#> Note for advanced users who have written their own MCMC samplers:
#>   As of version 0.13.0, NIMBLE's protocol for handling posterior
#>   predictive nodes has changed in a way that could affect user-defined
#>   samplers in some situations. Please see Section 15.5.1 of the User Manual.
#> 
#> Attaching package: ‘nimble’
#> The following object is masked from ‘package:stats’:
#> 
#>     simulate
#> The following object is masked from ‘package:base’:
#> 
#>     declare
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 1 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 22 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
```
