# Extracted from test-functions.R:25

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "nycpluto", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
checks <- nyc_pluto() |>
  dplyr::summarise(
    n = dplyr::n(),
    n_bbl = dplyr::n_distinct(bbl),
    bad_landuse = sum(as.integer(nchar(landuse) != 2L), na.rm = TRUE)
  ) |>
  dplyr::collect()
