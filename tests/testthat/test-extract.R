context("extract methods")
suppressPackageStartupMessages(library("texreg"))

# brmsfit (brms) ----
test_that("extract brmsfit objects from the brms package", {
  testthat::skip_on_cran()
  skip_if_not_installed("brms", minimum_version = "2.8.8")
  skip_if_not_installed("coda", minimum_version = "0.19.2")
  require("brms")
  require("coda")

  # example 2 from brm help page; see ?brm
  sink("/dev/null")
  suppressMessages(fit2 <- brm(rating ~ period + carry + cs(treat),
                               data = inhaler, family = sratio("logit"),
                               prior = set_prior("normal(0,5)"), chains = 1))
  sink()

  suppressWarnings(tr <- extract(fit2))
  expect_length(tr@gof.names, 4)
  expect_length(tr@coef, 8)
  expect_length(tr@se, 8)
  expect_length(tr@pvalues, 0)
  expect_length(tr@ci.low, 8)
  expect_length(tr@ci.up, 8)
  expect_equivalent(which(tr@gof.decimal), c(1, 3, 4))

  # example 1 from brm help page; see ?brm
  bprior1 <- prior(student_t(5,0,10), class = b) + prior(cauchy(0,2), class = sd)
  sink("/dev/null")
  fit1 <- suppressMessages(brm(count ~ zAge + zBase * Trt + (1|patient),
                               data = epilepsy,
                               family = poisson(),
                               prior = bprior1))
  sink()

  suppressMessages(tr <- extract(fit1, use.HDI = TRUE, reloo = TRUE))
  expect_length(tr@gof.names, 5)
  expect_length(tr@coef, 5)
  expect_length(tr@se, 5)
  expect_length(tr@pvalues, 0)
  expect_length(tr@ci.low, 5)
  expect_length(tr@ci.up, 5)
  expect_equivalent(which(tr@gof.decimal), c(1:2, 4:5))
})

# dynlm (dynlm) ----
test_that("extract dynlm objects from the dynlm package", {
  skip_if_not_installed("dynlm")
  skip_if_not_installed("datasets")
  require("dynlm")
  set.seed(12345)
  data("UKDriverDeaths", package = "datasets")
  uk <- log10(UKDriverDeaths)
  dfm <- dynlm(uk ~ L(uk, 1) + L(uk, 12))
  tr <- extract(dfm, include.rmse = TRUE)
  expect_equivalent(tr@coef, c(0.18, 0.43, 0.51), tolerance = 1e-2)
  expect_equivalent(tr@se, c(0.158, 0.053, 0.056), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0.25, 0.00, 0.00), tolerance = 1e-2)
  expect_equivalent(tr@gof, c(0.68, 0.68, 180, 0.04), tolerance = 1e-2)
  expect_length(tr@gof.names, 4)
  expect_length(tr@coef, 3)
  expect_equivalent(which(tr@pvalues < 0.05), 2:3)
  expect_equivalent(which(tr@gof.decimal), c(1, 2, 4))
})

# feglm (alpaca) ----
test_that("extract feglm objects from the alpaca package", {
  testthat::skip_on_cran()
  skip_if_not_installed("alpaca", minimum_version = "0.3.2")
  require("alpaca")

  set.seed(12345)
  data <- simGLM(1000L, 20L, 1805L, model = "logit")
  mod <- feglm(y ~ x1 + x2 + x3 | i + t, data)

  tr <- extract(mod)

  expect_equivalent(tr@coef, c(1.091, -1.106, 1.123), tolerance = 1e-2)
  expect_equivalent(tr@se, c(0.024, 0.024, 0.024), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0, 0, 0), tolerance = 1e-2)
  expect_equivalent(tr@gof, c(15970.75, 19940.00, 997.00, 20.00), tolerance = 1e-2)
  expect_length(tr@gof.names, 4)
  expect_length(tr@coef, 3)
  expect_equivalent(which(tr@pvalues < 0.05), 1:3)
  expect_equivalent(which(tr@gof.decimal), 1)
})

# feis (feisr) ----
test_that("extract feis objects from the feisr package", {
  skip_if_not_installed("feisr", minimum_version = "1.0.1")
  require("feisr")
  set.seed(12345)
  data("mwp", package = "feisr")
  feis1.mod <- feis(lnw ~ marry | exp, data = mwp, id = "id")
  feis2.mod <- feis(lnw ~ marry + enrol + as.factor(yeargr) | exp,
                    data = mwp,
                    id = "id")
  tr <- extract(feis1.mod)
  expect_equivalent(tr@coef, 0.056, tolerance = 1e-3)
  expect_equivalent(tr@se, 0.0234, tolerance = 1e-3)
  expect_equivalent(tr@pvalues, 0.0165, tolerance = 1e-3)
  expect_equivalent(tr@gof, c(0.002, 0.002, 3100, 268, 0.312), tolerance = 1e-3)
  expect_length(tr@gof.names, 5)
  tr2 <- extract(feis2.mod)
  expect_length(tr2@coef, 6)
  expect_length(which(tr2@pvalues < 0.05), 2)
  expect_length(which(tr2@gof.decimal), 3)
})

# felm (lfe) ----
test_that("extract felm objects from the lfe package", {
  testthat::skip_on_cran()
  skip_if_not_installed("lfe", minimum_version = "2.8-5")
  require("lfe")

  set.seed(12345)
  x <- rnorm(1000)
  x2 <- rnorm(length(x))
  id <- factor(sample(20, length(x), replace = TRUE))
  firm <- factor(sample(13, length(x),replace = TRUE))
  id.eff <- rnorm(nlevels(id))
  firm.eff <- rnorm(nlevels(firm))
  u <- rnorm(length(x))
  y <- x + 0.5 * x2 + id.eff[id] + firm.eff[firm] + u
  est <- felm(y ~ x + x2 | id + firm)

  tr <- extract(est)

  expect_equivalent(tr@coef, c(1.0188, 0.5182), tolerance = 1e-2)
  expect_equivalent(tr@se, c(0.032, 0.032), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0.00, 0.00), tolerance = 1e-2)
  expect_equivalent(tr@gof, c(1000, 0.7985, 0.575, 0.792, 0.560), tolerance = 1e-2)
  expect_length(tr@gof.names, 5)
  expect_length(tr@coef, 2)
  expect_equivalent(which(tr@pvalues < 0.05), 1:2)
  expect_equivalent(which(tr@gof.decimal), 2:5)
})

# glm.cluster (miceadds) ----
test_that("extract glm.cluster objects from the miceadds package", {
  testthat::skip_on_cran()
  skip_if_not_installed("miceadds", minimum_version = "3.8.9")
  require("miceadds")

  data(data.ma01)
  dat <- data.ma01

  dat$highmath <- 1 * (dat$math > 600)
  mod2 <- miceadds::glm.cluster(data = dat,
                                formula = highmath ~ hisei + female,
                                cluster = "idschool",
                                family = "binomial")
  tr <- extract(mod2)

  expect_equivalent(tr@coef, c(-2.76, 0.03, -0.15), tolerance = 1e-2)
  expect_equivalent(tr@se, c(0.25, 0.00, 0.10), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0.00, 0.00, 0.13), tolerance = 1e-2)
  expect_equivalent(tr@gof, c(3108.095, 3126.432, -1551.047, 3102.095, 3336.000), tolerance = 1e-2)
  expect_length(tr@gof.names, 5)
  expect_length(tr@coef, 3)
  expect_equivalent(which(tr@pvalues < 0.05), 1:2)
  expect_equivalent(which(tr@gof.decimal), 1:4)
})

# glmerMod (lme4) ----
test_that("extract glmerMod objects from the lme4 package", {
  testthat::skip_on_cran()
  skip_if_not_installed("lme4")
  require("lme4")
  set.seed(12345)
  gm1 <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
               data = cbpp,
               family = binomial)
  expect_equivalent(class(gm1)[1], "glmerMod")
  tr <- extract(gm1, include.dic = TRUE, include.deviance = TRUE)
  expect_equivalent(tr@coef, c(-1.40, -0.99, -1.13, -1.58), tolerance = 1e-2)
  expect_equivalent(tr@se, c(0.23, 0.30, 0.32, 0.42), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0, 0, 0, 0), tolerance = 1e-2)
  expect_length(tr@gof.names, 8)
  expect_equivalent(which(tr@gof.decimal), c(1:5, 8))
  expect_length(which(grepl("Var", tr@gof.names)), 1)
  expect_length(which(grepl("Cov", tr@gof.names)), 0)
  tr_profile <- extract(gm1, method = "profile", nsim = 5)
  tr_boot <- suppressWarnings(extract(gm1, method = "boot", nsim = 5))
  tr_wald <- extract(gm1, method = "Wald")
  expect_length(tr_profile@se, 0)
  expect_length(tr_profile@ci.low, 4)
  expect_length(tr_profile@ci.up, 4)
  expect_length(tr_boot@se, 0)
  expect_length(tr_boot@ci.low, 4)
  expect_length(tr_boot@ci.up, 4)
  expect_length(tr_wald@se, 0)
  expect_length(tr_wald@ci.low, 4)
  expect_length(tr_wald@ci.up, 4)
})

# ivreg (AER) ----
test_that("extract ivreg objects from the AER package", {
  skip_if_not_installed("AER")
  require("AER")
  set.seed(12345)
  data("CigarettesSW", package = "AER")
  CigarettesSW$rprice <- with(CigarettesSW, price / cpi)
  CigarettesSW$rincome <- with(CigarettesSW, income/population / cpi)
  CigarettesSW$tdiff <- with(CigarettesSW, (taxs - tax) / cpi)
  fm <- ivreg(log(packs) ~ log(rprice) + log(rincome) | log(rincome) + tdiff + I(tax/cpi),
              data = CigarettesSW,
              subset = year == "1995")
  tr1 <- extract(fm, vcov = sandwich, df = Inf, diagnostics = TRUE, include.rmse = TRUE)
  fm2 <- ivreg(log(packs) ~ log(rprice) | tdiff, data = CigarettesSW,
               subset = year == "1995")
  tr2 <- extract(fm2)
  expect_equivalent(tr1@coef, c(9.89, -1.28, 0.28), tolerance = 1e-2)
  expect_equivalent(tr1@se, c(0.93, 0.24, 0.25), tolerance = 1e-2)
  expect_equivalent(tr1@pvalues, c(0.00, 0.00, 0.25), tolerance = 1e-2)
  expect_equivalent(tr1@gof, c(0.43, 0.40, 48, 0.19), tolerance = 1e-2)
  expect_length(tr1@gof.names, 4)
  expect_length(tr2@coef, 2)
  expect_length(which(tr2@pvalues < 0.05), 2)
  expect_equivalent(which(tr2@gof.decimal), 1:2)
})

# lm (stats) ----
test_that("extract lm objects from the stats package", {
  set.seed(12345)
  ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
  trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
  group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
  weight <- c(ctl, trt)
  lm.D9 <- lm(weight ~ group)
  lm.D90 <- lm(weight ~ group - 1)
  tr <- extract(lm.D9)
  expect_equivalent(tr@coef, c(5.032, -0.371), tolerance = 1e-3)
  expect_equivalent(tr@se, c(0.22, 0.31), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0.00, 0.25), tolerance = 1e-2)
  expect_equivalent(tr@gof, c(0.07, 0.02, 20), tolerance = 1e-2)
  expect_length(tr@gof.names, 3)
  tr2 <- extract(lm.D90, include.rmse = TRUE)
  expect_length(tr2@coef, 2)
  expect_length(which(tr2@pvalues < 0.05), 2)
  expect_length(which(tr2@gof.decimal), 3)
})

# lm.cluster (miceadds) ----
test_that("extract lm.cluster objects from the miceadds package", {
  testthat::skip_on_cran()
  skip_if_not_installed("miceadds", minimum_version = "3.8.9")
  require("miceadds")

  data(data.ma01)
  dat <- data.ma01

  mod1 <- miceadds::lm.cluster(data = dat,
                               formula = read ~ hisei + female,
                               cluster = "idschool")
  tr <- extract(mod1)

  expect_equivalent(tr@coef, c(418.80, 1.54, 35.70), tolerance = 1e-2)
  expect_equivalent(tr@se, c(6.45, 0.11, 3.81), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0.00, 0.00, 0.00), tolerance = 1e-2)
  expect_equivalent(tr@gof, c(0.15, 0.15, 3180), tolerance = 1e-2)
  expect_length(tr@gof.names, 3)
  expect_length(tr@coef, 3)
  expect_equivalent(which(tr@pvalues < 0.05), 1:3)
  expect_equivalent(which(tr@gof.decimal), 1:2)
})

# lmerMod (lme4) ----
test_that("extract lmerMod objects from the lme4 package", {
  testthat::skip_on_cran()
  skip_if_not_installed("lme4")
  require("lme4")
  set.seed(12345)
  fm1 <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
  fm1_ML <- update(fm1, REML = FALSE)
  fm2 <- lmer(Reaction ~ Days + (Days || Subject), sleepstudy)
  tr1 <- extract(fm1, include.dic = TRUE, include.deviance = TRUE)
  tr1_ML <- extract(fm1_ML, include.dic = TRUE, include.deviance = TRUE)
  tr2_profile <- extract(fm2, method = "profile", nsim = 5)
  tr2_boot <- suppressWarnings(extract(fm2, method = "boot", nsim = 5))
  tr2_wald <- extract(fm2, method = "Wald")
  expect_equivalent(class(fm1)[1], "lmerMod")
  expect_equivalent(tr1@coef, c(251.41, 10.47), tolerance = 1e-2)
  expect_equivalent(tr1@coef, tr1_ML@coef, tolerance = 1e-2)
  expect_equivalent(tr1@se, c(6.82, 1.55), tolerance = 1e-2)
  expect_equivalent(tr1@pvalues, c(0, 0), tolerance = 1e-2)
  expect_equivalent(tr1@gof, c(1755.63, 1774.79, 1760.25, 1751.94, -871.81, 180, 18, 611.90, 35.08, 9.61, 654.94), tolerance = 1e-2)
  expect_length(tr1@gof.names, 11)
  expect_equivalent(which(tr1@gof.decimal), c(1:5, 8:11))
  expect_equivalent(tr1@coef, tr1_ML@coef)
  expect_length(tr1_ML@gof, 11)
  expect_length(tr2_profile@gof, 8)
  expect_equivalent(tr1@coef, tr2_profile@coef, tolerance = 1e-2)
  expect_equivalent(tr1@coef, tr2_boot@coef, tolerance = 1e-2)
  expect_equivalent(tr1@coef, tr2_wald@coef, tolerance = 1e-2)
  expect_length(which(grepl("Var", tr1@gof.names)), 3)
  expect_length(which(grepl("Var", tr2_wald@gof.names)), 3)
  expect_length(which(grepl("Cov", tr1@gof.names)), 1)
  expect_length(which(grepl("Cov", tr2_wald@gof.names)), 0)
})

# nlmerMod (lme4) ----
test_that("extract nlmerMod objects from the lme4 package", {
  skip_if_not_installed("lme4")
  require("lme4")
  set.seed(12345)
  startvec <- c(Asym = 200, xmid = 725, scal = 350)
  nm1 <- nlmer(circumference ~ SSlogis(age, Asym, xmid, scal) ~ Asym|Tree,
               Orange,
               start = startvec)
  expect_equivalent(class(nm1)[1], "nlmerMod")
  expect_warning(extract(nm1, include.dic = TRUE, include.deviance = TRUE),
                 "falling back to var-cov estimated from RX")
  tr <- suppressWarnings(extract(nm1, include.dic = TRUE, include.deviance = TRUE))
  expect_equivalent(tr@coef, c(192.05, 727.90, 348.07), tolerance = 1e-2)
  expect_equivalent(tr@se, c(15.58, 34.44, 26.31), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0, 0, 0), tolerance = 1e-2)
  expect_length(tr@gof.names, 9)
  expect_equivalent(which(tr@gof.decimal), c(1:5, 8, 9))
  expect_length(which(grepl("Var", tr@gof.names)), 2)
  expect_length(which(grepl("Cov", tr@gof.names)), 0)
  tr_wald <- suppressWarnings(extract(nm1, method = "Wald"))
  expect_length(tr_wald@se, 0)
  expect_length(tr_wald@ci.low, 3)
  expect_length(tr_wald@ci.up, 3)
})

# speedglm (speedglm) ----
test_that("extract speedglm objects from the speedglm package", {
  skip_if_not_installed("speedglm")
  require("speedglm")
  set.seed(12345)
  n <- 50000
  k <- 80
  y <- rgamma(n, 1.5, 1)
  x <-round( matrix(rnorm(n * k), n, k), digits = 3)
  colnames(x) <-paste("s", 1:k, sep = "")
  da <- data.frame(y, x)
  fo <- as.formula(paste("y ~", paste(paste("s", 1:k, sep = ""), collapse = " + ")))
  m3 <- speedglm(fo, data = da, family = Gamma(log))
  tr <- extract(m3)
  expect_length(tr@gof.names, 5)
  expect_length(tr@coef, 81)
  expect_equivalent(tr@gof.names, c("AIC", "BIC", "Log Likelihood", "Deviance", "Num. obs."))
  expect_equivalent(which(tr@pvalues < 0.05), integer())
  expect_equivalent(which(tr@gof.decimal), c(1, 2, 3, 4))
})

# speedlm (speedglm) ----
test_that("extract speedlm objects from the speedglm package", {
  skip_if_not_installed("speedglm")
  require("speedglm")
  set.seed(12345)
  n <- 1000
  k <- 3
  y <- rnorm(n)
  x <- round(matrix(rnorm(n * k), n, k), digits = 3)
  colnames(x) <- c("s1", "s2", "s3")
  da <- data.frame(y, x)
  do1 <- da[1:300, ]
  do2 <- da[301:700, ]
  do3 <- da[701:1000, ]
  m1 <- speedlm(y ~ s1 + s2 + s3, data = do1)
  m1 <- update(m1, data = do2)
  m1 <- update(m1, data = do3)
  tr <- extract(m1, include.fstatistic = TRUE)
  expect_equivalent(tr@coef, c(0.05, 0.04, -0.01, -0.03), tolerance = 1e-2)
  expect_equivalent(tr@se, c(0.03, 0.03, 0.03, 0.03), tolerance = 1e-2)
  expect_equivalent(tr@pvalues, c(0.13, 0.22, 0.69, 0.39), tolerance = 1e-2)
  expect_equivalent(tr@gof, c(0, 0, 1000, 0.80), tolerance = 1e-2)
  expect_length(tr@gof.names, 4)
  expect_length(tr@coef, 4)
  expect_equivalent(which(tr@pvalues < 0.05), integer())
  expect_equivalent(which(tr@gof.decimal), c(1, 2, 4))
})