# Estimate Rhat values

Derived Rubin Gelman convergence statistics from output chains of a
Bayesian model

## Usage

``` r
Rhatfun(rb, nch, it, nparam)
```

## Arguments

- rb:

  `array of dimension 3` estimates of output chains of a bayesian model.
  The rows should be the iterations, the column the different chains and
  the 3rd dimension the parameters

- nch:

  `numeric` number of chains

- it:

  `numeric` number of iterations

- nparam:

  `numeric` number of parameters

## Value

`numeric vector` of size `nparam` giving Rhat statistics for each
parameter

## Examples

``` r
rb = array(rnorm(15*3*4), dim = c(15,3,4))
Rhatfun(rb, nch = 3, it = 15, nparam = 4)
#> [1] 0.9879035 0.9940266 1.1703602 1.0001813
```
