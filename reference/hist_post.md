# Histogram

Prepare a histogram ggplot for posterior distribution of a given
parameter. To be used within codes for plotting grids of posterior
distributions of several parameters.

## Usage

``` r
hist_post(x, namex = "", namelab = "")
```

## Arguments

- x:

  `numeric vector` raw estimates of parameters

- namex:

  `character` x axis label

- namelab:

  `character` title label of the plot

## Value

histogram plot

## Examples

``` r
hist_post(rnorm(1000))
```
