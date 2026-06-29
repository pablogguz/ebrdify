# tests/testthat/test-internals.R

library(testthat)

test_that(".clean_input() coerces and blanks empty strings", {
  expect_equal(ebrdify:::.clean_input(c("a", "", NA)), c("a", NA, NA))
  expect_equal(ebrdify:::.clean_input(1:2), c("1", "2"))
})

test_that(".detect_format() distinguishes the three formats", {
  expect_equal(ebrdify:::.detect_format(c("KAZ", "POL")), "iso3c")
  expect_equal(ebrdify:::.detect_format(c("KZ", "PL")), "iso2c")
  expect_equal(ebrdify:::.detect_format(c("Kazakhstan", "Poland")), "country.name")
  # mixed widths fall back to country.name
  expect_equal(ebrdify:::.detect_format(c("KAZ", "KZ")), "country.name")
  # all-missing falls back to country.name
  expect_equal(ebrdify:::.detect_format(c(NA, NA)), "country.name")
})

test_that(".to_iso3c() converts and normalises Kosovo", {
  expect_equal(ebrdify:::.to_iso3c(c("kaz", "pol"), "iso3c"), c("KAZ", "POL"))
  expect_equal(ebrdify:::.to_iso3c("KOS", "iso3c"), "XKX")
  expect_equal(ebrdify:::.to_iso3c(c("Kazakhstan", "Kosovo"), "country.name"),
               c("KAZ", "XKX"))
  expect_equal(ebrdify:::.to_iso3c(c("KZ", "XK"), "iso2c"), c("KAZ", "XKX"))
  # unmatched -> NA, preserving position
  expect_equal(ebrdify:::.to_iso3c(c("Kazakhstan", "Wakanda"), "country.name"),
               c("KAZ", NA))
})

test_that("internal lookups are mutually consistent", {
  tbl <- ebrdify:::.ebrd_economies
  expect_equal(nrow(tbl), 41)
  expect_false(any(duplicated(tbl$iso3c)))
  expect_false(any(duplicated(tbl$name)))
  # name override covers every economy
  expect_true(all(tbl$iso3c %in% names(ebrdify:::.tr_name_override)))
})
