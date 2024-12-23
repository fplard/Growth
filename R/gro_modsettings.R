# WARNING - Generated by {fusen} from dev/flat_main.Rmd: do not edit by hand


#' Growth model settings
#' 
#' This function gets the parameter and equations for the growth model
#' 
#' @param data \code{data.frame} including at least the numeric columns *logx* and *logz* 
#' @param random \code{vector of character} name of the parameters that must include an individual random effect
#' @param mod \code{character} Name of the model to fit. The following models are supported : logistic, gompertz, tpgm, power, richards, vonbertalanffy, and fabens
#' 
#' 
#' @import dplyr assertthat
#' @importFrom nimble nimbleFunction 
#'
#' @return a list including the function of the growth model,  the number of parameter, their names, their initial values and their lowest possible values
#' 
#' @export
#' @examples
#' logx <- rnorm(100, 0, 1)
#' logz <- 0.2+ 15 * (1 - exp(-(1) * logx)) +rnorm(100, 0, 0.01)
#' dat = data.frame(logx = logx, logz = logz,IND =sample(c(0:20), 100, replace = TRUE)
#' )
#' model <- Gro_ModSettings(data = dat, mod = "vonbertalanffy")
# Set growth model parameters:
Gro_ModSettings <- function(data, random =NULL, mod = "vonbertalanffy") {
  
  assert_that(mod %in% c("logistic", "gompertz", "richards", "vonbertalanffy", "fabens", "tpgm", "power", "richard"), msg = "The growth models supported are: logistic, gompertz, tpgm, power, richards, vonbertalanffy, and fabens")
  assert_that(is.data.frame(data))
  assert_that(data %has_name% c('logx', 'logz', 'IND'))
  assert_that(is.numeric(data$logx))
  assert_that(is.numeric(data$logz))
  if(length(random)>0) {
    assert_that(is.character(random))
  }
  if(mod == "vonbertalanffy"){
    model_nim <- "
   for (j in 1:N){{
       logz[j] ~dnorm(z0[IND[j]] + zinf[IND[j]] * (1 - exp(- gamma[IND[j]] * logx[j])), sigma_res)}}"
    model <- function(logx,coef){
      coef$mu_z0 + coef$mu_zinf * (1 - exp(- coef$mu_gamma * logx))
    }
    inits <-  list(mu_z0= min(exp(data$logz)),
                 mu_zinf = max(data$logz),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(z0 =  5, zinf = max(exp(data$logz))*10, gamma = 2)
  minval = list(z0 = 0, zinf = 0, gamma = 0)
  param = c("mu_z0","mu_zinf", "mu_gamma",
            "sigma_res",
            "z0", "zinf", "gamma")
  }
  
  if(mod == "fabens"){
    model_nim <- "
   for (j in 1:N){{
       logz[j] ~dnorm(z0[IND[j]] + (zinf[IND[j]] - z0[IND[j]]) * (1 - exp(- gamma[IND[j]] * logx[j])), sigma_res)}}"
    model <- function(logx,coef){
      coef$mu_z0 + (coef$mu_zinf-coef$mu_z0) * (1 - exp(- coef$mu_gamma * logx))
    }
    
    inits <-  list(mu_z0= min(exp(data$logz)),
                 mu_zinf = max(data$logz),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(z0 =  5, zinf = max(exp(data$logz))*10, gamma = 2)
  minval = list(z0 = 0, zinf = 0, gamma = 0)
  param = c("mu_z0","mu_zinf", "mu_gamma",
            "sigma_res",
            "z0", "zinf", "gamma")
  }
  
if(mod == "gompertz"){
    model_nim <- "
   for (j in 1:N){{
       logz[j] ~dnorm( zinf[IND[j]] * exp(-alpha[IND[j]]*exp(- gamma[IND[j]] * logx[j])), sigma_res)}}"
    model <- function(logx,coef){
         coef$mu_zinf * exp(-coef$mu_alpha*exp(-mu_gamma * logx))
    }
    inits <-  list(mu_alpha= 0,
                 mu_zinf = max(data$logz),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(alpha =  5, zinf = max(exp(data$logz))*10, gamma = 2)
  minval = list(alpha = 0, zinf = 0, gamma = 0)
  param = c("mu_alpha","mu_zinf", "mu_gamma",
            "sigma_res",
            "alpha", "zinf", "gamma")
}
  
  
   if(mod == "logistic"){
    model_nim <- "
   for (j in 1:N){{
       logz[j] ~dnorm(zinf[IND[j]] / (1 + exp(- gamma[IND[j]] * (logx[j] - xinfl[IND[j]]))), sigma_res)}}"
    model <- function(logx,coef){
           coef$mu_zinf / (1 + exp(- coef$mu_gamma * (logx - coef$mu_xinfl)))
    }
     inits <-  list(mu_xinfl= mean(exp(data$logx)),
                 mu_zinf = max(data$logz),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(xinfl =  max(exp(data$logx)), zinf = max(exp(data$logz))*10, gamma = 2)
  minval = list(xinfl = min(exp(data$logx)), zinf = 0, gamma = 0)
  param = c("mu_xinfl","mu_zinf", "mu_gamma",
            "sigma_res",
            "xinfl", "zinf", "gamma")
 }
     if(mod == "tpgm"){
    model_nim <- "
   for (j in 1:N){{
       logz[j] ~dnorm(z0[IND[j]] + zinf[IND[j]] * (1 - exp(- gamma[IND[j]] * logx[j])), sigma_res)}}"
    model <- function(logx,coef){
        coef$mu_z0 + coef$mu_zinf * (1 - exp(- coef$mu_gamma * logx))
    }
         inits <-  list(mu_z0= min(exp(data$logz)),
                 mu_zinf = max(data$logz),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(z0 =  5, zinf = max(exp(data$logz))*10, gamma = 2)
  minval = list(z0 = 0, zinf = 0, gamma = 0)
  param = c("mu_z0","mu_zinf", "mu_gamma",
            "sigma_res",
            "z0", "zinf", "gamma")
}
  
     if(mod == "power"){
    model_nim <- "
   for (j in 1:N){{
       logz[j] ~dnorm(alpha0[IND[j]] + alpha1[IND[j]] * (logx[j]^(beta[IND[j]])), sigma_res)}}"
    model <- function(logx,coef){
   
      coef$mu_alpha0 + coef$mu_alpha1 * (logx)^(coef$mu_beta)
    }
      inits <-  list(mu_alpha0= 0,
                 mu_alpha1 = 1,
                 mu_beta = 1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(alpha0 =  -10, alpha1 = -10, beta = 0)
  minval = list(alpha0 = 10, alpha1 = 10, beta = 5)
  param = c("mu_alpha0","mu_alpha1", "mu_gamma",
            "sigma_res",
            "alpha0", "alpha1", "gamma")
   }
     if(mod == "richards"){
    model_nim <- "
   for (j in 1:N){{
       logz[j] ~dnorm(zinf[IND[j]] * (1 - beta[IND[j]] *exp(- gamma[IND[j]] * logx[j]))^(1 / (1 - m[IND[j]])), sigma_res)}}"
    model <- function(logx,coef){
  
       coef$mu_zinf * (1 - coef$mu_beta* exp(- coef$mu_gamma * logx))^(1 / (1 - m))
    }
     inits <-  list(mu_beta= 1,mu_m = 1,
                 mu_zinf = max(data$logz),
                 mu_gamma = 0.1, sigma_res  = 1
                 
                 
                 
  )
  maxval = list(beta =  15, zinf = max(exp(data$logz))*10, gamma = 2, m = 1000)
  minval = list(beta = 0, zinf = 0, gamma = 0, m = 0)
  param = c("mu_beta","mu_zinf", "mu_gamma","mu_m",
            "sigma_res",
            "beta", "zinf", "gamma", "m")
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
  
  
  
  dat_nim <- list(logz = data$logz,
                  logx = data$logx
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
