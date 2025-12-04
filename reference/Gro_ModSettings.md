# Growth model settings

This function gets the parameter and equations for the growth model

## Usage

``` r
Gro_ModSettings(data, random = NULL, mod = "vonbertalanffy")
```

## Arguments

- data:

  `data.frame` including at least the numeric columns *age* and *z*

- random:

  `vector of character` name of the parameters that must include an
  individual random effect

- mod:

  `character` Name of the model to fit. The following models are
  supported : logistic, gompertz, tpgm, power, richards, vonbertalanffy

## Value

a list including the function of the growth model, the number of
parameter, their names, their initial values and their lowest possible
values

## Examples

``` r
age <- rnorm(100, 0, 1)
z <- 0.2+ 15 * (1 - exp(-(1) * age)) +rnorm(100, 0, 0.01)
dat = data.frame(age = age, z = z,IND =sample(c(0:20), 100, replace = TRUE)
)
model <- Gro_ModSettings(data = dat, mod = "vonbertalanffy")
```
