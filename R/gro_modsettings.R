# WARNING - Generated by {fusen} from dev/flat_main.Rmd: do not edit by hand


#' Growth model settings
#' 
#' This function gets the parameter and equations for the growth model
#' 
#' @param data \code{data.frame} including at least the numeric columns *age* and *z* 
#' @param random \code{vector of character} name of the parameters that must include an individual random effect
#' @param mod \code{character} Name of the model to fit. The following models are supported : logistic, gompertz, tpgm, power, richards, vonbertalanffy
#' 
#' 
#' @import dplyr assertthat
#' @importFrom nimble nimbleFunction 
#'
#' @return a list including the function of the growth model,  the number of parameter, their names, their initial values and their lowest possible values
#' 
#' @export
#' @examples
#' age <- rnorm(100, 0, 1)
#' z <- 0.2+ 15 * (1 - exp(-(1) * age)) +rnorm(100, 0, 0.01)
#' dat = data.frame(age = age, z = z,IND =sample(c(0:20), 100, replace = TRUE)
#' )
#' model <- Gro_ModSettings(data = dat, mod = "vonbertalanffy")
# Set growth model parameters:
Gro_ModSettings <- function(data, random =NULL, mod = "vonbertalanffy") {
  
  assert_that(mod %in% c("logistic", "gompertz", "richards", "vonbertalanffy", "tpgm", "power"), msg = "The growth models supported are: logistic, gompertz, tpgm, power, richards, vonbertalanffy")
  assert_that(is.data.frame(data))
  assert_that(data %has_name% c('age', 'z', 'IND'))
  assert_that(is.numeric(data$age))
  assert_that(is.numeric(data$z))
  if(length(random)>0) {
    assert_that(is.character(random))
  }
  if(mod == "vonbertalanffy"){
    
    model_nim <- "
   for (j in 1:N){{
       z[j] ~dnorm(z0[IND[j]] + (zinf[IND[j]] - z0[IND[j]]) *
    (1 - exp(- gamma[IND[j]] * age[j])), sigma_res)}}"
    model <- function(age,coef){
      coef$mu_z0 + (coef$mu_zinf-coef$mu_z0) * (1 - exp(- coef$mu_gamma * age))
    }
    
    inits <-  list(mu_z0= min(exp(data$z)),
                 mu_zinf = max(data$z),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(z0 =  25, zinf = max(data$z)*50, gamma = 2)
  minval = list(z0 = 0, zinf = 0, gamma = 0)
  param = c("mu_z0","mu_zinf", "mu_gamma",
            "sigma_res",
            "z0", "zinf", "gamma")
  }
  
if(mod == "gompertz"){
    model_nim <- "
   for (j in 1:N){{
       z[j] ~dnorm( zinf[IND[j]] * exp(-alpha[IND[j]]*exp(- gamma[IND[j]] * age[j])), sigma_res)}}"
    model <- function(age,coef){
         coef$mu_zinf * exp(-coef$mu_alpha*exp(-coef$mu_gamma * age))
    }
    inits <-  list(mu_alpha= 0,
                 mu_zinf = max(data$z),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(alpha =  40, zinf = max(data$z)*50, gamma = 2)
  minval = list(alpha = -40, zinf = 0, gamma = 0)
  param = c("mu_alpha","mu_zinf", "mu_gamma",
            "sigma_res",
            "alpha", "zinf", "gamma")
}
  
  
   if(mod == "logistic"){
    model_nim <- "
   for (j in 1:N){{
       z[j] ~dnorm(zinf[IND[j]] / (1 + exp(- gamma[IND[j]] * (age[j] - xinfl[IND[j]]))), sigma_res)}}"
    model <- function(age,coef){
           coef$mu_zinf / (1 + exp(- coef$mu_gamma * (age - coef$mu_xinfl)))
    }
     inits <-  list(mu_xinfl= mean(data$age),
                 mu_zinf = max(data$z),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(xinfl =  max(data$age), zinf = max(data$z)*50, gamma = 2)
  minval = list(xinfl = min(data$age), zinf = 0, gamma = 0)
  param = c("mu_xinfl","mu_zinf", "mu_gamma",
            "sigma_res",
            "xinfl", "zinf", "gamma")
 }
     if(mod == "tpgm"){
      
    model_nim <- "
   for (j in 1:N){{
       z[j] ~dnorm(zinf[IND[j]] *    (1 - exp(- gamma[IND[j]] *(1- h[IND[j]]/((age[j] -th[IND[j]])^2+1)) *(age[j] - age0[IND[j]]))), sigma_res)}}"
    model <- function(age,coef){
      coef$mu_zinf * (1 - exp(- coef$mu_gamma*(1-coef$mu_h/((age -coef$mu_th)^2+1)) * (age - coef$mu_age0)))
    }
         inits <-  list(mu_age0= 0,
                 mu_zinf = max(data$z), mu_h = 0, mu_th = 1,
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(age0 =  0, zinf = max(data$z)*50, gamma = 2, h= 5, th = max(data$age))
  minval = list(age0 = -20, zinf = 0, gamma = 0, h= -5, th = 0)
  param = c("mu_age0","mu_zinf", "mu_gamma","mu_h", "mu_th",
            "sigma_res",
            "age0", "zinf", "gamma", "h", "th")
}
  
     if(mod == "power"){
    model_nim <- "
   for (j in 1:N){{
       z[j] ~dnorm(alpha0[IND[j]] + alpha1[IND[j]] * (age[j]^(beta[IND[j]])), sigma_res)}}"
    model <- function(age,coef){
   
      coef$mu_alpha0 + coef$mu_alpha1 * (age^(coef$mu_beta))
    }
      inits <-  list(mu_alpha0= 0,
                 mu_alpha1 = 1,
                 mu_beta = 1, sigma_res  = 1
                 
                 
                 
  )
  minval = list(alpha0 =  -10, alpha1 = -10, beta = 0)
  maxval = list(alpha0 = 10, alpha1 = 10, beta = 5)
  param = c("mu_alpha0","mu_alpha1", "mu_beta",
            "sigma_res",
            "alpha0", "alpha1", "beta")
   }
     if(mod == "richards"){
    model_nim <- "
   for (j in 1:N){{
       z[j] ~dnorm(zinf[IND[j]] * (1 - z0[IND[j]] *exp(- gamma[IND[j]] * age[j]))^(P[IND[j]]), sigma_res)}}"
    model <- function(age,coef){
  
       coef$mu_zinf * (1 - coef$mu_z0* exp(- coef$mu_gamma * age))^(coef$mu_P)
    }
     inits <-  list(mu_z0= 1,mu_P = 1,
                 mu_zinf = max(data$z),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(z0 =  25, zinf = max(data$z)*50, gamma = 2, P = 5)
  minval = list(z0 = 0, zinf = 0, gamma = 0, P = 0)
  param = c("mu_z0","mu_zinf", "mu_gamma","mu_P",
            "sigma_res",
            "z0", "zinf", "gamma", "P")
 }

  if(length(random)>0){
    for( p in random){
      param = c(param, glue("sigma_{p}")) 
      a =list(1)
      names(a) = glue("sigma_{p}")
      inits = append(inits, a)
    }
  }
  
  const <- list(N = nrow(data),
                Nind = length(unique(data$IND)),
                IND = data$IND
  )
  
  
  
  dat_nim <- list(z = data$z,
                  age = data$age
  )
  
  ARG = list(model_nim  =model_nim,
             model_fun  =model,
             const_nim = const,
             data_nim = dat_nim,
             inits_nim = inits,
             parameters = param,
             maxval = maxval,
             minval = minval
  )
  return(ARG)
  
}
