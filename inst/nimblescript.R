args = commandArgs(TRUE)
ARG0 = args[1]
library(nimble)
nimbleOptions(showCompilerOutput = F,
              verbose = F)

 ARG <- readRDS(ARG0)
  assign_to_global <- function(Name, object, pos=1){
    assign(Name, object, envir=as.environment(pos) )
  }
# print(ARG)

Rmodel <- nimbleModel(ARG$model_nim, ARG$const_nim,
                      ARG$data_nim, ARG$inits_nim, check = F)

## configure MCMC
conf<- configureMCMC(Rmodel, monitors = ARG$parameters,
                     thin = ARG$run$nthin, enableWAIC = TRUE,
                     useConjugacy = TRUE)


# conf$getSamplers()
Rmcmc <- buildMCMC(conf)
# print("0")
## compile model and MCMC

Cmodel <- compileNimble(Rmodel, showCompilerOutput = FALSE)

Cmcmc <- compileNimble(Rmcmc, project = Rmodel)
set.seed(0)

chain_output<- runMCMC(Cmcmc, niter=ARG$run$nit,
                       nburnin = ARG$run$nburnin, nchains=ARG$run$nch,
                       progressBar = FALSE, summary = FALSE, WAIC = TRUE)


if(is.na(chain_output$WAIC)){
  chain_output$WAIC = calculateWAIC(Cmcmc, nburnin = ARG$run$nburnin)
  }


saveRDS(chain_output, file = ARG0)
