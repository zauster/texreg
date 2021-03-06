% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract.R
\name{extract,survreg-method}
\alias{extract,survreg-method}
\alias{extract.survreg}
\title{\code{\link{extract}} method for \code{survreg} objects}
\usage{
\S4method{extract}{survreg}(
  model,
  include.aic = TRUE,
  include.bic = TRUE,
  include.loglik = TRUE,
  include.deviance = TRUE,
  include.nobs = TRUE,
  ...
)
}
\arguments{
\item{model}{A statistical model object.}

\item{include.aic}{Report Akaike's Information Criterion (AIC) in the GOF
block?}

\item{include.bic}{Report the Bayesian Information Criterion (BIC) in the GOF
block?}

\item{include.loglik}{Report the log likelihood in the GOF block?}

\item{include.deviance}{Report the deviance?}

\item{include.nobs}{Report the number of observations in the GOF block?}

\item{...}{Custom parameters, which are handed over to subroutines, in this
case to the \code{summary} method for the object.}
}
\description{
\code{\link{extract}} method for \code{survreg} objects created by the
\code{\link[survival]{survreg}} function in the \pkg{survival} package.
}
