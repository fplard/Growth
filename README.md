
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
out = Gro_analysis(dat, all_mods  = c("vonbertalanffy", "gompertz"),
                   random = list(vonbertalanffy = c("z0", "z0, zinf"), gompertz = c("alpha0", "")),
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

#### On your own computer

``` r
library(glue)
library(ISRverse)
library(tidyverse)
library(nimble)
library(Growth)
```

#### On Ucloud

``` r

# Install libraries:
instPacks <- installed.packages()[, 1]
if (!"snowfall" %in% instPacks) {
  install.packages("snowfall")
}
if (!"ggpubr" %in% instPacks) {
  install.packages("ggpubr")
}
if (!"bbmle" %in% instPacks) {
  install.packages("bbmle")
}
if (!"BasTA" %in% instPacks) {
  install.packages("BaSTA")
}
if (!"assertthat" %in% instPacks) {
  install.packages("assertthat")
}
if (!"glue" %in% instPacks) {
  install.packages("glue")
}
if (!"pbapply" %in% instPacks) {
  install.packages("pbapply")
}
if (!"ggpp" %in% instPacks) {
  install.packages("ggpp")
}
if (!"nimble" %in% instPacks) {
  install.packages("nimble")
}
if (!"checkmate" %in% instPacks) {
  install.packages("checkmate")
}

if (!"paramDemo" %in% instPacks) {
  install.packages("/work/Species360/Rpackages/latestVersion/paramDemo_1.0.0.tar.gz",
                   type = "source", repos = NULL)
}
if (!"ISRverse" %in% instPacks) {
  install.packages("/work/Species360/Rpackages/latestVersion/ISRverse_0.0.0.9000.tar.gz", 
                   type = "source", repos = NULL)
}
if (!"Growth" %in% instPacks) {
  install.packages("/work/Species360/Rpackages/latestVersion/Growth_0.0.0.9000.tar.gz", 
                   type = "source", repos = NULL)
}
library(glue)
library(ISRverse)
library(tidyverse)
library(Growth)
```

### Load Data

``` r
# Path to the ZIMSdata directory:
ZIMSdirdata <- "/work/Species360/ZIMSdata_ext240829"

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
                          Birth_Type = Birth_Type,
                          minDate = minDate , extractDate = extractDate,
                          Global = Global) 
```

### Clean data and look for outliers

``` r
# General directory:
analysisDir <- glue ("/work/Species360/growth/")
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
    p <- Gro_pred(data = data_weight, 
                  out = out$model, 
                  title =out$wAIC_tab$model[1])
  }      
  
}

#Look at the wAIC table comparing all models
out$wAIC_tab

#Look at the model prediction and convergence 
?Gro_pred
p$summary
p$predictions
p$GOF
p$plot_pred
p$convergence
p$posterior  
```

## Simulation to test functions

### functions to simulate data

``` r

#Functions to simulate data
vonbertalanffy <- function(N = 10000,Nind = 100, 
                             sd_z0 = 0, sd_gamma = 0,sd_zinf = 0, 
                           z0 = 0.2, zinf = 15, gamma = 0.5,
                           sd_res = 0.01){
age <- runif(N, 0, 10)
id1 =  rnorm(Nind,0, sd_z0)
id2 =  rnorm(Nind,0, sd_zinf)
id3 =  rnorm(Nind,0, sd_gamma)
IND =sample(c(1:Nind), N, replace = TRUE)
z <- z0+ id1[IND]+ (zinf + id2[IND])* (1 - exp(-(gamma+ id3[IND]) * age)) +
  rnorm(N, 0,sd_res)
dat = data.frame(Age = age, MeasurementValue = z, 
                 AnimalAnonID = as.numeric(factor(IND ,labels = c(1:length(unique(IND)))))
)
return(dat)
}

logistic <- function(N = 10000,Nind = 100, 
                           sd_zinf = 0, sd_gamma = 0, sd_xinfl = 0, 
                     xinfl = 2, zinf = 15, gamma = 0.5,
                           sd_res = 0.01){
age <- runif(N, 0, 10)
id1 =  rnorm(Nind,0, sd_xinfl)
id2 =  rnorm(Nind,0, sd_zinf)
id3 =  rnorm(Nind,0, sd_gamma)
IND =sample(c(1:Nind), N, replace = TRUE)
z <- (zinf + id2[IND])/ (1 + exp(-(gamma+ id3[IND]) * (age-(xinfl+ id1[IND])))) +
  rnorm(N, 0, sd_res)
dat = data.frame(Age = age, MeasurementValue = z, 
                 AnimalAnonID = as.numeric(factor(IND ,labels = c(1:length(unique(IND)))))
)
return(dat)
}
gompertz <- function(N = 10000,Nind = 100, 
                           sd_alpha = 0, sd_zinf = 0, sd_gamma = 0, 
                     alpha = -0.7, zinf = 15, gamma = 0.5,
                           
                           sd_res = 0){
age <- runif(N, 0, 10)
id1 =  rnorm(Nind,0, sd_alpha)
id2 =  rnorm(Nind,0, sd_zinf)
id3 =  rnorm(Nind,0, sd_gamma)
IND =sample(c(1:Nind), N, replace = TRUE)
z <-  (zinf + id2[IND])* exp(-(alpha+ id1[IND])* exp(-(gamma+ id3[IND]) * age)) +
  rnorm(N, 0, sd_res)
dat = data.frame(Age = age, MeasurementValue = z, 
                 AnimalAnonID = as.numeric(factor(IND ,labels = c(1:length(unique(IND)))))
)
return(dat)
}
tpgm <- function(N = 10000,Nind = 100, 
                           sd_zinf = 0, sd_gamma = 0, sd_age0 = 0,  sd_h = 0,  sd_th = 0, 
                 age0 = 1, h = 1, th = 0.5, zinf = 15, gamma = 0.5,
                           
                           sd_res = 0.01){
age <- runif(N, 0, 10)
id0 =  rnorm(Nind,0, sd_age0)
idh =  rnorm(Nind,0, sd_h)
idth =  rnorm(Nind,0, sd_th)
id2 =  rnorm(Nind,0, sd_zinf)
id3 =  rnorm(Nind,0, sd_gamma)
IND =sample(c(1:Nind), N, replace = TRUE)
z <- (zinf + id2[IND])*    (1 - exp(- (gamma+ id3[IND]) *(1- (h+idh[IND])/((age -(th+idth[IND]))^2+1)) *(age - (age0+id0[IND])))) +rnorm(N, 0, sd_res)
                   
dat = data.frame(Age = age, MeasurementValue = z, 
                 AnimalAnonID = as.numeric(factor(IND ,labels = c(1:length(unique(IND)))))
)
return(dat)
}
power <- function(N = 10000,Nind = 100, 
                             sd_alpha0 = 0, sd_alpha1 = 0, sd_beta = 0,
                  alpha0 = 9, alpha1 = 2.5, beta = 3.5,
                           
                           sd_res = 0.01){
age <- runif(N, 0, 10)
id0 =  rnorm(Nind,0, sd_alpha0)
id1 =  rnorm(Nind,0, sd_alpha1)
idb =  rnorm(Nind,0, sd_beta)
IND =sample(c(1:Nind), N, replace = TRUE)
z <- (alpha0+id0[IND]) + (alpha1+id1[IND]) * (age^(beta+idb[IND]))+  rnorm(N, 0, sd_res)
dat = data.frame(Age = age, MeasurementValue = z, 
                 AnimalAnonID = as.numeric(factor(IND ,labels = c(1:length(unique(IND)))))
)
return(dat)
}
richards <- function(N = 10000,Nind = 100, 
                           sd_z0 = 0, sd_gamma = 0, sd_zinf = 0, sd_P = 0,
                     z0 = 0.2, zinf = 15, gamma = 0.5,P = 0.1,
                                  sd_res = 0){.01
age <- runif(N, 0, 10)
id1 =  rnorm(Nind,0, sd_z0)
id2 =  rnorm(Nind,0, sd_zinf)
id3 =  rnorm(Nind,0, sd_gamma)
idP =  rnorm(Nind,0, sd_P)
IND =sample(c(1:Nind), N, replace = TRUE)
z <- (zinf + id2[IND])* (1 -  (z0+ id1[IND])*exp(-(gamma+ id3[IND]) * age))^(P+idP[IND]) +
  rnorm(N, 0, sd_res)
dat = data.frame(Age = age, MeasurementValue = z, 
                 AnimalAnonID = as.numeric(factor(IND ,labels = c(1:length(unique(IND)))))
)
return(dat)
}
```

\###Run simulation

``` r
library(Growth)
Nsim = 5
N = 10000
Nind = 100
run = list(nit = 1000, nburnin = 100, nthin = 1, nch = 3)

#Maximum uncertainty accepted for measurement dates: weight, in days
uncert_date = 365
models_gro  = c("logistic", "gompertz", "richards", "vonbertalanffy", "tpgm", "power")
random = list(logistic= c("", "zinf", "gamma", "zinf, gamma"),
              gompertz = c("","zinf", "gamma", "zinf, gamma"),
              richards = c("","z0","gamma", "z0, gamma"),
              vonbertalanffy = c("","z0","gamma", "z0, gamma", "zinf", "z0, zinf", "zinf, gamma", "zinf, z0, gamma"), 
              tpgm= c("zinf","gamma", "zinf, gamma"),
              power = c("alpha0","alpha1", "alpha0, alpha1"))
 funct = c(logistic, gompertz, richards, vonbertalanffy, tpgm, power)
#Simulate data
 TAB = tibble(sim=numeric(0),
                  model_type=character(0),
                  random=character(0),
                  truemodel = character(0),
                  truerandom =character(0),
                mu_z0 = numeric(0), 
                mu_zinf = numeric(0),
                mu_gamma = numeric(0), 
                mu_xinfl = numeric(0), 
                mu_age0 = numeric(0), 
                mu_alpha0 = numeric(0), 
                mu_alpha1 = numeric(0),
                mu_h = numeric(0), 
                mu_th = numeric(0), 
                mu_P = numeric(0), 
                mu_beta = numeric(0), 
                mu_alpha = numeric(0),
                sigma_z0 = numeric(0), 
                sigma_zinf = numeric(0),
                sigma_gamma = numeric(0), 
                sigma_xinfl = numeric(0), 
                sigma_age0 = numeric(0), 
                sigma_alpha0 = numeric(0), 
                sigma_alpha1 = numeric(0),
                sigma_h = numeric(0), 
                sigma_th = numeric(0), 
                sigma_P = numeric(0), 
                sigma_beta = numeric(0), 
                sigma_alpha = numeric(0),
                sigma_res= numeric(0))
 
for (fs in c(2,6)){
   fun = funct[fs]
  nfun = models_gro[fs]
print(nfun)
 for (rand in 1:length(random[[nfun]])){
print(rand)
  sd1 = sd2 = sd3 = 0
if(rand == 2){sd1 = 0.3}
if(rand == 3){sd2 = 0.2}
if(rand == 4){sd2 = 0.2; sd1 = 0.6}
if(rand == 5){sd3 = 0.2}
if(rand == 6){sd3 = 0.2; sd1 = 0.6}
if(rand == 7){sd2 = 0.2; sd3 = 0.4}
if(rand == 8){sd2 = 0.2; sd3 = 0.2; sd1 = 0.4}
for (sim in 1: Nsim){
  
   dat <- fun[[1]](N,Nind, 
             sd1,  sd2, sd3)%>%drop_na%>%filter(MeasurementValue >0)

  modelsgro = sample(models_gro,3, replace = FALSE)
    modelsgro = unique(c(modelsgro, nfun))
  
  rando = random[which(models_gro %in% modelsgro)]
    #run analysis
    out<- Growth::Gro_analysis(dat = dat , 
                       all_mods = modelsgro, random =rando,
                       run = run)
    
  toplot = c(str_which(names(out$model$coef), "mu"),
             str_which(names(out$model$coef), "sigma"))
  beta_tt <- out$model$coef[,toplot]
  print(out$wAIC_tab$model_type[1])
  
  resrb <- sum_nim(as.matrix( beta_tt), out$model$run$nch)%>%
    select(mean)%>%rownames_to_column%>%pivot_wider(names_from = rowname, values_from = mean)
    a = random[[nfun]][rand]
  TAB<- TAB%>%add_row(
   tibble_row (sim = sim,
                  model_type = out$wAIC_tab$model_type[1],
                  random=out$wAIC_tab$random[1],
                  truemodel = nfun,
                  truerandom =a, resrb)
  )

 
   }  

 }
save(TAB, file ="ressimu2.Rdata")
}
```
