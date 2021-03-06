% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prob_strel.R
\name{p_strel}
\alias{p_strel}
\title{prior and posterior probability of estimate being bigger than threshold}
\usage{
p_strel(x, estimate, low.bound)
}
\arguments{
\item{x}{A strel output object (list)}

\item{estimate}{A character string indicating what estimate to plot from the strel output object}

\item{low.bound}{A number for the threshold to be tested against}
}
\description{
takes a mcmc posterior sample of any of the single test reliability estimates
and calculates the prior and posterior probability of the estimate being bigger
or smaller than an arbitrary value (priors are stored in the package)
}
\examples{
p_strel(strel(asrm, "lambda2", n.chains = 2, n.iter = 100, freq = FALSE), "lambda2", .80)
}
