
#' graphical posterior predictive check for the 1-factor omega model, based on covariance matrix eigenvalues
#'
#' @description
#' gives posterior predictive check for the 1-factor model:
#' comparison between model implied covariance matrix and sample covariance matrix
#' also displays frequentist fit indices
#'
#' @param x A strel output object (list)
#'
#' @examples omega_fit(strel(asrm, "omega"))
#'
#' @export
#'
omega_fit <- function(x){
  if (!("omega" %in% x$estimates)) {return("please run the analysis with omega as an estimate")}

  if (!is.null(x$freq$omega_fit)){
    print(x$freq$omega_fit)}

  sigma <- cov(x$data)
  lambda <- x$bay$loadings
  psi <- x$bay$resid_var
  cimpl <- lambda %*% t(lambda) + diag(psi)
  ymax <- max(eigen(cimpl)$values, eigen(sigma)$values) * 1.3
  ee_impl <- matrix(0, 1e3, ncol(x$data))
  for (i in 1:1e3) {
    dtmp <- MASS::mvrnorm(nrow(x$data), rep(0, ncol(sigma)), cimpl)
    ee_impl[i, ] <- eigen(cov(dtmp))$values
  }
  qq_ee_low <- apply(ee_impl, 2, quantile, prob = .025)
  qq_ee_up <- apply(ee_impl, 2, quantile, prob = .975)

  plot(eigen(sigma)$values, axes = F, ylim = c(0, ymax), ylab = "Eigenvalue - Size", xlab = "Eigenvalue - No.")
  lines(qq_ee_low, col = "gray50", lty = 2)
  lines(qq_ee_up, col = "gray50", lty = 2)
  graphics::polygon(x = c(1:ncol(sigma), rev(1:ncol(sigma))), y = c(qq_ee_up, rev(qq_ee_low)),
          col = adjustcolor("gray", alpha.f = .7), border = NA)
  lines(eigen(sigma)$values, type = "l", lwd = 2)
  lines(eigen(sigma)$values, type = "p")
  axis(side = 1, at = seq(1:ncol(sigma)))
  axis(side = 2)
  title(main = "Posterior Predictive Check for Omega 1-Factor-Model")

  legend(ncol(sigma)/3*1.1, ymax*(2/3),
         legend = c("Dataset Covariance Matrix", "Model Implied Covariance Matrix"),
         col=c("black", "gray"), lwd = c(2, 2), box.lwd = 0, lty = c(1, 2), cex = .8)

}
