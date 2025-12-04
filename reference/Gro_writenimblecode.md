# Write nimble code for growth model

Write the nimble code needed to run growth model including random
effects

## Usage

``` r
Gro_writenimblecode(
  params,
  model,
  random = c(),
  maxval = list(),
  minval = list()
)
```

## Arguments

- params:

  `vector of character` names of all parameters of the model.

- model:

  `character` likelihood of the nimble model

- random:

  `vector of character` name of the parameters that must include an
  individual random effect

- maxval:

  `list` including the maximum values for prior for each parameter.
  Default value is 1000.

- minval:

  `list` including the minimum values for prior for each
  parameter.Default value is 0.

## Value

A character representing a nimble model

## Examples

``` r
#Example for a von bertalanffy model
Gro_writenimblecode(params = c('z0', 'zinf', 'gamma'), 
                    model = "for (j in 1:N){{
       logz[j] ~dnorm(z0[IND[j]] + zinf[IND[j]] * 
       (1 - exp(- gamma[IND[j]] * logx[j])), sigma_res)}}",
                    random = "gamma",
                    maxval = list(z0 = 5), 
                    minval= list(z0 = 0, zinf = 0, gamma = 0)
)
#> expression(sigma_res ~ dunif(0, 150), mu_z0 ~ dunif(0, 5), for (i in 1:Nind) {
#>     z0[i] <- mu_z0
#> }, mu_zinf ~ dunif(0, 1000), for (i in 1:Nind) {
#>     zinf[i] <- mu_zinf
#> }, mu_gamma ~ dunif(0, 1000), sigma_gamma ~ dunif(0, 150), for (i in 1:Nind) {
#>     gamma[i] ~ dnorm(mu_gamma, sd = sigma_gamma)
#> }, for (j in 1:N) {
#>     {
#>         logz[j] ~ dnorm(z0[IND[j]] + zinf[IND[j]] * (1 - exp(-gamma[IND[j]] * 
#>             logx[j])), sigma_res)
#>     }
#> })
```
