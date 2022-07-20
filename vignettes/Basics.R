## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  echo = TRUE,
  eval = TRUE,
  collapse = TRUE,
  fig.width = 6)


## ----dagitty, warning=FALSE, message=FALSE------------------------------------
library(dagitty)
# Build the graph
g <- dagitty("dag {
              ESRD [outcome]
              current.smoking [exposure]
              baseline.covariates -> earlier.smoking
              baseline.covariates -> prior.disease
              baseline.covariates -> ESRD
              current.smoking -> ESRD
              earlier.smoking -> current.smoking
              earlier.smoking -> prior.disease
              prior.disease -> current.smoking
              prior.disease -> ESRD
              }")
plot(graphLayout(g))


## ----unobserved---------------------------------------------------------------
g.unob <- g
latents(g.unob) <- c("earlier.smoking")


## ----adjustmentsets-----------------------------------------------------------
adjustmentSets(g, type = "minimal", effect = "total")
adjustmentSets(g.unob, type = "minimal", effect = "total")


## -----------------------------------------------------------------------------
print(impliedConditionalIndependencies(g))
print(impliedConditionalIndependencies(g.unob))


## ----totalEffects-------------------------------------------------------------
for(n in names(g.unob)){
  for(m in setdiff(dagitty::descendants(g.unob, n), n)){
    a <- adjustmentSets(g.unob, n, m)
    if(length(a) > 0){
      cat("The total effect of ", n," on ", m,
          " is identifiable controlling for:\n", sep = "")
      print(a, prefix=" * ")
    }
  }
}


## ----paths--------------------------------------------------------------------
## show paths
(pfad <- paths(g.unob, from = "current.smoking", to = "ESRD"))
# number of open back-door paths
sum(pfad$open)


## -----------------------------------------------------------------------------
g2 <- dagitty("dag {
              ESRD [outcome]
              current.smoking [exposure]
              unknown [latent]
              baseline.covariates -> earlier.smoking
              baseline.covariates -> prior.disease
              baseline.covariates -> ESRD
              current.smoking -> ESRD
              earlier.smoking -> current.smoking
              earlier.smoking -> prior.disease
              prior.disease -> current.smoking
              prior.disease -> ESRD
              prior.disease <- unknown -> ESRD
              }")
plot(graphLayout(g2))
adjustmentSets(g2)


## -----------------------------------------------------------------------------
library(gRbase)


## ---- out.width="50%", echo = F-----------------------------------------------
plot(dag(~X1, ~L, ~X2*X1*L, ~Y*L))


## -----------------------------------------------------------------------------
N <- 1000
x1 <- sample(c(1,0), N, replace = T)
l <- rnorm(N, 1, 2)
p <- 1/(1 + exp(-1.5*x1 * l + 2)) 
x2 <- rbinom(N, 1, p)

y <- 0.5 * l + rnorm(N, 2)


## -----------------------------------------------------------------------------
summary(lm(y ~ x1))$coefficients


## -----------------------------------------------------------------------------
summary(lm(y ~ x1 + x2))$coefficients


## -----------------------------------------------------------------------------
summary(lm(y ~ x1 + x2 + l))$coefficients


## ---- out.width="50%", echo = F-----------------------------------------------
plot(dag(~X1, ~U, ~L*X1*U, ~X2*X1*L, ~Y*L*U*X1*X2))


## -----------------------------------------------------------------------------
N <- 1000
x1 <- sample(c(1,0), N, replace = T)
u <- rnorm(N, 2)
l <- 2 * x1 - u + rnorm(N, 1, 2)
p <- 1/(1 + exp(-3 * x1 + l)) 
x2 <- rbinom(N, 1, p)
y <- u + x1 + l + x2 + rnorm(N)


## -----------------------------------------------------------------------------
summary(lm(y ~ x1 + x2))$coefficients


## -----------------------------------------------------------------------------
summary(lm(y ~ x1 + x2 + l))$coefficients


## -----------------------------------------------------------------------------
x2_new <- sample(c(1,0), N, replace = T)
y_new <- u + x1 + l + x2_new + rnorm(N)


## -----------------------------------------------------------------------------
summary(lm(y_new ~ x1 + x2_new))$coefficients


## -----------------------------------------------------------------------------
log_model <- glm(x2 ~ x1 + l, family = binomial(link="logit"))
p_hat <- predict(log_model, type = "response")
w <- (x2 * p_hat + (1 - x2) * (1 - p_hat))^(-1)


## -----------------------------------------------------------------------------
summary(lm(y ~ x1 + x2, weights = w))$coefficients

