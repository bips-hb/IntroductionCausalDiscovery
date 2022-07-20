## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      fig.width = 6, 
                      message = F, 
                      warning = F, 
                      cache = T, 
                      eval = TRUE)

## -----------------------------------------------------------------------------
library(IntroductionCausalDiscovery)
library(tidyverse)
library(pcalg)

## ----read_tcga----------------------------------------------------------------
data(tcgas)

## ----dim_tcga-----------------------------------------------------------------
dim(tcgas)

## ----head_tcga----------------------------------------------------------------
head(tcgas)

## ----plot_tcga----------------------------------------------------------------
plot(tcgas, cex = 0.3)

## ----hist_tcga----------------------------------------------------------------
tcgas %>% 
  gather() %>% 
  ggplot(aes(x = value)) +
  geom_histogram(col = "black", fill = "white") + 
  theme_light() +
  facet_wrap(~ key)

## ----fitpc_tcga---------------------------------------------------------------
pcfit.tcga <- pc(
  suffStat = list(C = cor(tcgas), n = dim(tcgas)[1]), # correlation matrix and the number of observations
  indepTest = gaussCItest, # our choice of independence test
  alpha = 0.05, # our choice of "significance level"
  labels = colnames(tcgas), # variable names
  maj.rule = T, solve.confl = T, u2pd = "relaxed"
)

## ----fitalpha_tcga------------------------------------------------------------
plot(pc(
  suffStat = list(C = cor(tcgas), n = dim(tcgas)[1]),
  indepTest = gaussCItest,
  alpha = 0.01,
  labels = colnames(tcgas),
  maj.rule = T, solve.confl = T, u2pd = "relaxed"
  )@graph, main = "alpha = 1%")

plot(pcfit@graph, main = "alpha = 5%")

plot(pc(
  suffStat = list(C = cor(tcgas), n = dim(tcgas)[1]),
  indepTest = gaussCItest,
  alpha = 0.1,
  labels = colnames(tcgas),
  maj.rule = T, solve.confl = T, u2pd = "relaxed"
  )@graph, main = "alpha = 10%")

## ----fitfci-------------------------------------------------------------------
fcifit <- fci(
  suffStat = list(C = cor(tcgas), n = dim(tcgas)[1]),
  indepTest = gaussCItest,
  alpha = 0.05,
  labels = colnames(tcgas),
  maj.rule = TRUE,
  selectionBias = FALSE
)

## ----plotfci------------------------------------------------------------------
plot(fcifit)

## ----fitges_tcga--------------------------------------------------------------
gesfit <- ges(new("GaussL0penObsScore", tcgas))

## ----plotges------------------------------------------------------------------
plot(gesfit$essgraph)

## ----fitlingam_tcga-----------------------------------------------------------
lingamfit <- lingam(tcgas)

## ----lingamfct----------------------------------------------------------------
lingam2graph <- function(fit,data){
  
  amat <- t(fit$Bpruned!=0)
  
  colnames(amat) <- colnames(data)
  
  output <- as(amat, "graphNEL")
  
  return(output)
}

## ----graphlingam_tcga---------------------------------------------------------
lingamgraph <- lingam2graph(fit = lingamfit, # fitted object
                            data = tcgas) # data used to fit the object

## ----plotlingam---------------------------------------------------------------
plot(lingamgraph)

## ----lib_kpcalg---------------------------------------------------------------
library(kpcalg)

## ----kpcfit-------------------------------------------------------------------
pcfit_kernel05 <- pc(suffStat = list(data = tcgas, ic.method = "dcc.perm"),
                     indepTest = kernelCItest,
                     alpha = 0.05,
                     labels = colnames(tcgas),
                     maj.rule = TRUE, solve.confl = TRUE, u2pd = "relaxed"
                     )
pcfit_kernel10 <- pc(suffStat = list(data = tcgas, ic.method = "dcc.perm"),
                     indepTest = kernelCItest,
                     alpha = 0.1,
                     labels = colnames(tcgas),
                     maj.rule = TRUE, solve.confl = TRUE, u2pd = "relaxed")

## ----plotkernel---------------------------------------------------------------
par(mfrow = c(1,2))
plot(pcfit_kernel05, main = "alpha = 5%")
plot(pcfit_kernel10, main = "alpha = 10%")

## ----gcm_lib------------------------------------------------------------------
library(GeneralisedCovarianceMeasure)

## ----gcm_wrapper--------------------------------------------------------------
use_gcm <- function(x, y, S, suffStat){
  
  a <- as.matrix(suffStat$data)[,x]
  b <- as.matrix(suffStat$data)[,y]
  c <- as.matrix(suffStat$data)[,S]
  
  test <- gcm.test(a, b, c, alpha = suffStat$alpha)
  p_value <- test[[1]]
  
  return(p_value)
} 

