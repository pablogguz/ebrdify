# tests/testthat/test-comparator.R

library(testthat)

test_that("comparator_imf labels EBRD economies as 'EBRD regions'", {
  res <- ebrdify(var = c("KAZ", "POL", "TUR", "XKX"), var_format = "iso3c")
  expect_equal(res$comparator_imf, rep("EBRD regions", 4))
})

test_that("comparator_imf labels non-EBRD advanced economies", {
  # Germany/Japan/US are advanced; Czechia and Greece are advanced AND non-EBRD
  res <- ebrdify(var = c("DEU", "JPN", "USA", "CZE", "GRC"), var_format = "iso3c")
  expect_equal(res$comparator_imf, rep("Advanced Economies", 5))
})

test_that("comparator_imf labels everything else 'Other EMDEs'", {
  res <- ebrdify(var = c("BRA", "CHN", "IND", "ZAF", "RUS"), var_format = "iso3c")
  expect_equal(res$comparator_imf, rep("Other EMDEs", 5))
})

test_that("EBRD precedence wins for EBRD economies that are also advanced", {
  # Croatia is an IMF advanced economy but an EBRD economy -> "EBRD regions"
  res <- ebrdify(var = c("HRV", "EST", "SVK"), var_format = "iso3c")
  expect_equal(res$comparator_imf, rep("EBRD regions", 3))
})

test_that("comparator_imf is NA for unmatched / missing input", {
  res <- suppressMessages(ebrdify(var = c("Kazakhstan", "Wakanda", NA), var_format = "country.name"))
  expect_equal(res$comparator_imf[1], "EBRD regions")
  expect_true(is.na(res$comparator_imf[2]))
  expect_true(is.na(res$comparator_imf[3]))
})

test_that("comparator_imf partitions every resolved economy (no gaps)", {
  # A non-EBRD economy is always Advanced or Other EMDEs, never NA
  res <- ebrdify(var = c("FRA", "BRA", "USA", "CHN", "ZAF"), var_format = "iso3c")
  expect_false(any(is.na(res$comparator_imf)))
  expect_true(all(res$comparator_imf %in% c("Advanced Economies", "Other EMDEs")))
})

test_that("comparator_imf column is added in the all-NA path too", {
  res <- ebrdify(var = as.character(c(NA, NA)), var_format = "iso3c")
  expect_true("comparator_imf" %in% names(res))
  expect_true(all(is.na(res$comparator_imf)))
})