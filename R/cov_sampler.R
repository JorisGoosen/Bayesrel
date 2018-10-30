
covSamp <- function(data, n.iter, n.burnin){
  n <- nrow(data)
  p <- ncol(data)
  # posterior covariance matrix ---------------------------------------------------
  k0 <- 1e-10
  v0 <- p
  t <- diag(p)
  T0 <- solve(t/k0) # inverse scale matrix, prior
  mu0 <- rep(0, p) # prior means
  ym <- apply(data, 2, mean)
  # https://en.wikipedia.org/wiki/Normal-inverse-Wishart_distribution, murphy 2007
  mun <- (k0 * mu0 + n * ym) / (k0 + n)
  kn <- k0 + n
  vn <- v0 + n
  S <- 0
  for (i in 1:n){
    M <- (data[i, ] - ym) %*% t(data[i, ] - ym)
    S <- S + M
  }
  Tn <- T0 + S + (k0 * n / (k0 + n)) * (ym - mu0) %*% t(ym - mu0)
  # drawing samples from posterior:
  c.post <- array(0, c(n.iter, p, p))
  for ( i in 1:n.iter){
    c.post[i, , ] <- LaplacesDemon::rinvwishart(vn, Tn) # sample from inverse wishart
  }
  c.post <- c.post[(n.burnin + 1):n.iter, , ]

  return(c.post)
}

# ------- customized covariance matrix sampling with cholesky decomposition -----------
rinvwishart <- function(nu, S, k = nrow(S), dfChisq = nu:(nu-k+1), utz = upper.tri(matrix(0, k, k))) {

  # LaplacesDemon::rwishartc
  Z <- matrix(0, k, k)
  x <- rchisq(k, dfChisq)
  x[x == 0] <- 1e-100
  diag(Z) <- sqrt(x)
  if (k > 1) {
    # kseq <- 1:(k - 1)
    # Z[rep(k * kseq, kseq) + unlist(lapply(kseq, seq))] <- rnorm(k * {k - 1} / 2)
    # --end of copied code
    Z[utz] <- rnorm(k * {k - 1} / 2)
  }
  # LaplacesDemon::rinvwishart
  return(chol2inv(Z %*% S))
}

#' this function uses gibbs sampling to estimate the posterior distribution
#' of a sample's covariance matrix
covSamp2 <- function(data, n.iter, n.burnin){
  n <- nrow(data)
  p <- ncol(data)
  # posterior covariance matrix ---------------------------------------------------
  k0 <- 1e-10
  v0 <- p
  t <- diag(p)
  T0 <- diag(k0, nrow = p, ncol = p) # matrix inversion of diagonal matrix
  mu0 <- rep(0, p) # prior means
  ym <- .colMeans(data, n, p)
  # https://en.wikipedia.org/wiki/Normal-inverse-Wishart_distribution, murphy 2007, gelman 2013
  mun <- (k0 * mu0 + n * ym) / (k0 + n)
  kn <- k0 + n
  vn <- v0 + n
  S <- 0
  for (i in 1:n){
    S <- S + tcrossprod(data[i, ] - ym)
  }
  Tn <- T0 + S + (k0 * n / (k0 + n)) * (ym - mu0) %*% t(ym - mu0)
  # drawing samples from posterior:
  c.post <- array(0, c(n.iter, p, p))
  Tn <- chol(chol2inv(chol(Tn)))
  dfChisq <- vn:(vn-p+1)
  utz <- upper.tri(matrix(0, p, p))
  for ( i in 1:n.iter){
    c.post[i, , ] <- rinvwishart(vn, Tn, p, dfChisq, utz) # sample from inverse wishart
  }
  c.post <- c.post[(n.burnin + 1):n.iter, , ]

  return(c.post)
}

# covSampMat <- function(mat, n.iter, n.burnin){
#   p <- ncol(mat)
#   n <- ??????????????????
#   v <- p + n
#   t <- cf*(vn-p-1)
#   c.post <- array(0, c(2e3, p, p))
#   for ( i in 1:2e3){
#     c.post[i, , ] <- LaplacesDemon::rinvwishart(v, t) # sample from inverse wishart
#   }
#   c.post <- c.post[(50 + 1):2e3, , ]
#   return(c.post)
# }