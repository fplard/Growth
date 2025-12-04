# Run growth model

Build and run the bayesian growth model `x` of `all_mods`.

## Usage

``` r
Gro_run(
  x,
  dat,
  all_mods,
  random = "",
  run = list(nit = 100, nburnin = 10, nthin = 1, nch = 1)
)
```

## Arguments

- x:

  `numeric` index of the formula used to build the model

- dat:

  `data.frame`including at least the numeric columns *age*, *z* and
  *IND*

- all_mods:

  `vector of characters` of model names. The following models are
  supported: logistic, gompertz, tpgm, power, richards, vonbertalanffy.

- random:

  vector of character of the same length as `all_mods` giving the
  parameters that should be included an individual random effect

- run:

  `list` Bayesian parameters. They should be increased to reach
  convergence

  - `nch` number of chains.

  - `nthin` interval between iterations to keep.

  - `nburnin` number of iterations to discard.

  - `nit` total number of iterations.

## Value

This function returns a `list`:

- `model` a list including estimates of coefficients and model
  characteristics

- `tab` a data frame with information on models & WAIC

## Examples

``` r
age <- rnorm(10000, 0, 1)
id1 =  rnorm(21,0, 0.5)
id2 =  rnorm(21,0, 0.4)
id3 =  rnorm(21,0, 0.3)
IND =sample(c(1:20), 100, replace = TRUE)
z <- 0.2+ id1[IND]+ (15 + id2[IND])* (1 - exp(-(1+ id3[IND]) * age)) +
  rnorm(100, 0, 0.01)
dat = data.frame(age = age, z = z, 
                 IND = as.numeric(factor(IND ,labels = c(1:length(unique(IND)))))
)

#Run a vonbertalanffy model including an individual effect on z0
out = Gro_run(1, 
              dat,
              all_mods  = c("vonbertalanffy"),
              random = c("z0"),
              run = list(nit = 500, nburnin = 100, nthin = 10, nch = 3))
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 3569 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
out$tab
#>       model_type random index Nparam      WAIC      lppd
#> 1 vonbertalanffy     z0     1      7 605700407 -39053.41
```
