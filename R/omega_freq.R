#' gives freq omega, and loadings and errors

omegaFreq <- function(data, estimator = "mlr", se = "default",
                       missing = "ml", equal.loading = FALSE, equal.error = FALSE) {
  colnames(data) <- bayesrel:::lavOneFile(data)$names
  varnames <- colnames(data)
  q <- length(varnames)
  N <- nrow(data)
  if (equal.loading) {
    loadingName <- rep("a1", q)
  } else {
    loadingName <- paste("a", 1:q, sep = "")
  }
  if (equal.error) {
    errorName <- rep("b1", q)
  } else {
    errorName <- paste("b", 1:q, sep = "")
  }
  model <- paste0("f1 =~ NA*", varnames[1], " + ")
  loadingLine <- paste(paste(loadingName, "*", varnames, sep = ""),
                       collapse = " + ")
  factorLine <- "f1 ~~ 1*f1\n"
  errorLine <- paste(paste(varnames, " ~~ ", errorName, "*",
                           varnames, sep = ""), collapse = "\n")
  sumLoading <- paste("loading :=", paste(loadingName, collapse = " + "),
                      "\n")
  sumError <- paste("error :=", paste(errorName, collapse = " + "),
                    "\n")
  relia <- "relia := (loading^2) / ((loading^2) + error) \n"
  model <- paste(model, loadingLine, "\n", factorLine, errorLine,
                 "\n", sumLoading, sumError, relia)

  e <- try(fit <- lavaan::cfa(model, data = data, missing = missing,
                              se = se, estimator = estimator), silent = TRUE)
  converged <- FALSE
  if (is(e, "try-error")) {
    converged <- FALSE
  } else {
    converged <- fit@Fit@converged
    errorcheck <- diag(lavaan::inspect(fit, "se")$theta)
    if (se != "none" && any(errorcheck <= 0))
      converged <- FALSE
  }
  if (converged) {
    loading <- unique(as.vector(lavaan::inspect(fit, "coef")$lambda))
    err.var <-  unique(as.vector(diag(lavaan::inspect(fit, "coef")$theta)))
    error <- unique(diag(lavaan::inspect(fit, "se")$theta))
    pe <- lavaan::parameterEstimates(fit)
    fit.tmp <- lavaan::fitMeasures(fit)
    indic <- c(fit.tmp["chisq"], fit.tmp["df"], fit.tmp["pvalue"],
               fit.tmp["rmsea"], fit.tmp["rmsea.ci.lower"], fit.tmp["rmsea.ci.upper"],
               fit.tmp["srmr"])
    r <- which(pe[, "lhs"] == "relia")
    u <- pe[which(pe[, "lhs"] == "loading"), "est"]
    v <- pe[which(pe[, "lhs"] == "error"), "est"]
    est <- pe[r, "est"]
    if (se == "none") {
      paramCov <- NULL
      stderr <- NA
    }
    else {
      paramCov <- lavaan::vcov(fit)
      stderr <- pe[r, "se"]
    }
    if ("fmi" %in% colnames(pe)) {
      fmi <- pe[, "fmi"]
      N <- N * (1 - mean(fmi, na.rm = TRUE))
    }
  }
  else {
    loading <- NA
    error <- NA
    if (se == "none") {
      paramCov <- NULL
    }
    else {
      paramCov <- NA
    }
    u <- NA
    v <- NA
    est <- NA
    stderr <- NA
  }
  result <- list(load = loading, error = error, vcov = paramCov, err.var = err.var,
                 converged = converged, u = u, v = v, relia = est, se = stderr,
                 effn = ceiling(N), indices = indic)
  return(result)
}