
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Growth

<!-- badges: start -->

[![R-CMD-check](https://github.com/fplard/Growth/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/fplard/Growth/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/fplard/Growth/branch/main/graph/badge.svg)](https://app.codecov.io/gh/fplard/Growth?branch=main)
<!-- badges: end -->

Growth can be used to run growth models including individual random
effects on clean dataset.

## Installation

#### Install `nimble`

If you never used the package `nimble`, you first need to install it
following recommendations [here](https://r-nimble.org/download)

You can install the development version of Growth from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fplard/Growth")
```

## Documentation

You can open the documentation locally on your machine using

``` r
path <- system.file("docs", "index.html", package = "Growth")
browseURL(path)
```

## Simple example

``` r
library(Growth)

## basic example code
#Create a simple data frame
Age <- sample(c(0:10), 100, replace = TRUE)
AnimalAnonID <- sample(c(0:20), 100, replace = TRUE)
MeasurementValue <- 0.2+15 * (1 - exp(-(0.1) * Age))+ 
                          rnorm(100,0,0.01) + AnimalAnonID*0.1 
dat = data.frame(Age = Age, MeasurementValue = MeasurementValue, 
                 AnimalAnonID = AnimalAnonID, MeasurementType = "Live Weight")

#Test 4 models: vonbertalanffy including an individual random effect on z0
#               vonbertalanffy including individual random effects on z0 and zinf
#               fabens including an individual random effect on gamma 
#               fabens including no individual random effect
out = Gro_analysis(dat, all_mods  = c("vonbertalanffy", "fabens"),
                   random = list(vonbertalanffy = c("z0", "z0, zinf"), fabens = c("gamma", "")),
                   run = list(nit = 1000, nburnin = 100, nthin = 1, nch = 1))

#Look at best model predictions and convergence
p <- Gro_pred(data = dat, 
              out = out$model, 
              title =out$wAIC_tab$model[1])
p$summary
p$predictions
p$GOF
p$plot_pred
p$convergence
p$posterior
```

## From data from the science extract

### Load ISRverse

First you will need the package ISRvers to load and prepare data

You can install the development version of ISRverse from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fplard/ISRverse")
```

Full documentation website on: <https://fplard.github.io/ISRverse>

Set up your Rstudio environnement as explained in the documentation of
ISRverse and load the needed libraries

### Load Data

``` r
library(ISRverse)
library(glue)
library(tidyverse)

# Path to the ZIMSdata directory:
ZIMSdirdata <- "C:/Users/flopy/Documents/ISR/TaxonProfiles/Data"

extractDate ="2024-08-29"

taxa = "Chondrichthyes"

#Filters
# Earliest date to include records
minDate <- "1980-01-01"
# Earliest birth date to include records
minBirthDate <- "1900-01-01"
#Whether to include only Global individuals
Global = TRUE
#Birth Type of Animals: "Captive", "Wild" or "All"
Birth_Type = "Captive"
#Maximum uncertainty accepted for birth dates, in days
uncert_birth = 365


#Load all data for this taxa
Data <- Load_Zimsdata(taxa = taxa, ZIMSdir = ZIMSdirdata, 
                      species = list(Chondrichthyes = "All"),
                      Animal = TRUE,
                      tables= c('Collection', "Weight", 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[taxa]]$Animal, extractDate = extractDate, minBirthDate =minBirthDate)


#Choose Species
List_species = unique(Data$Chondrichthyes$Animal$binSpecies)
species ="Rhinoptera bonasus"

Dataspe <- select_species(species, Animal, Data[[taxa]]$Collection, uncert_birth = uncert_birth,
                          Birth_Type = Birth_Type,uncert_death= 3600,
                          minDate = minDate , extractDate = extractDate,
                          Global = Global) 
```

### Clean data and look for outliers

``` r
#Directory where to save results
SaveDir = glue ("{analysisDir}savegrowth")
PlotDir = glue ("{analysisDir}plotgrowth")


#Maximum uncertainty accepted for measurement dates: weight, in days
uncert_date = 365

# Measure type to select
MeasureType = "Live weight"

# Conditions to estimate age at sexual maturity
minNrepro = 100   #Minimum number of birth records
minNparepro = 30  #Minimum number of unique parent records

#Choose sex
sx = "All" #can also be "Female" or "Male"

if(nrow(Dataspe$data)>0){
  repr = list()
  if(sx != "All"){
    coresubset <- Dataspe$data%>%filter(SexType == sx)
  }else{coresubset <- Dataspe$data}
  if(nrow(coresubset)>0){
    #Estimate age at sexual maturity
    repr[[sx]] <- Rep_main(coresubset= coresubset, Data[[taxa]]$Collection, 
                           Data[[taxa]]$Parent, Data[[taxa]]$Move,  
                           Repsect = "agemat",
                           BirthType_parent = Birth_Type, BirthType_offspring = Birth_Type, 
                           Global = Global, 
                           minNrepro = minNrepro, minNparepro =  minNparepro
    )
    
    agemat = NULL
    if(length(repr[[sx]])>0){
      if(repr[[sx]]$summary$amat_analyzed){
        agemat =repr[[sx]]$agemat$ageMat
      }
    }
    
    #Clean measures
    ouput <- Gro_cleanmeasures(data = Data[[taxa]]$Weight, coresubse = coresubset,
                               Birth_Type = Birth_Type, type ="weight", 
                               uncert_date = uncert_date,
                               MeasureType = MeasureType,
                               mindate = minDate)
    #Look for outliers
    if(nrow(ouput$data)>0){
      data_weight <- ouput$data%>%
        Gro_remoutliers (taxa = taxa, ageMat = agemat, maxweight = NULL, 
                         variableid = "AnimalAnonID", min_Nmeasures = 7,
                         perc_weight_min=0.2, perc_weight_max=2.5,
                         IQR=2.75, minq=0.025, Ninterval_juv = 10)
      
    
        p1 <-Gro_outplot(data_weight, title = glue("{species} {sx}"), ylimit = NULL, xlimit = NULL)
      }
      
    }
  }

p1

#Remove outliers
data_weight <- data_weight %>%filter(KEEP ==1)
```

### Run growth models

``` r
library(Growth)

#Maximum uncertainty accepted for measurement dates: weight, in days
uncert_date = 365

#Models: "logistic", "gompertz", "chapmanRichards", "vonBertalanffy", "gam", and/or "polynomial"
models_gro  = c("vonbertalanffy", "gompertz")
random = list(vonbertalanffy = c("z0", "z0, zinf"), gompertz = c("gamma", ""))
run = list(nit = 1000, nburnin = 100, nthin = 1, nch = 1)
# Conditions to run the growth analysis
minNgro = 100 #Minimum number of weights
minNIgro = 50 #Minimum number of individuals


if (nrow(data_weight) >= minNgro) {
  if (length(unique(data_weight$AnimalAnonID)) >= minNIgro) {
    #run analysis
    out<- Growth::Gro_analysis(dat = data_weight , 
                       all_mods = models_gro, random =random,
                       run = run)
    
    #Look at best model predictions and convergence
    p <- Gro_pred(data = dat, 
                  out = out$model, 
                  title =out$wAIC_tab$model[1])
  }      
  
}

#Look at the wAIC table comparing all models
out$tab

#Look at the model prediction and convergence 
?Gro_pred
p$summary
p$predictions
p$GOF
p$plot_pred
p$convergence
p$posterior  
```
