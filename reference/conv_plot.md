# Plot for convergence

Prepare a histogram ggplot for posterior distribution of a given
parameter. To be used within codes for plotting grids of posterior
distributions of several parameters.

## Usage

``` r
conv_plot(x, m)
```

## Arguments

- x:

  `numeric vector` raw estimates of parameters

- m:

  `numeric` number of iterations

## Value

plot

## Examples

``` r
conv_plot(rnorm(1500), m =500)
```
