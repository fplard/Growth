# Summary statistics

Makes a summary table with main statistics for each parameter from
output chains of a Bayesian model

## Usage

``` r
sum_nim(rb2, nch)
```

## Arguments

- rb2:

  `array` of dimension 3 or 2 including estimates of output chains of a
  bayesian model. If of dimension 3, the rows should be the iterations,
  the columns the different chains and the 3rd dimension the parameters.
  If of dimension 2, the rows should be the iterations and chains, and
  the columns the parameters.

- nch:

  `numeric` number of chains

## Value

A summary matrix with columns giving mean, sd, credible interval at 2.5%
and 97.5%, and Rubin Gelman Rhat statistic. The different parameters are
on lines.

## Examples

``` r
rb = array(rnorm(15*3*4), dim = c(15,3,4))
sum_nim(rb, nch = 3)
#>          mean        sd    QI 2.5  QI 97.5     Rhat
#> 1 -0.14624548 0.8551749 -1.683163 1.459291 1.052677
#> 2 -0.26932273 0.9016633 -2.067553 1.303842 1.057474
#> 3 -0.06986326 1.0050649 -2.128322 1.803060 1.106293
#> 4 -0.04559715 1.0882099 -1.962553 2.104402 1.022497
```
