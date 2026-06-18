# tests/testthat/test-canonise.R

library(testthat)

test_that("canonise() applies the headline forbidden-name fixes", {
  expect_equal(canonise("Czech Republic"), "Czechia")
  expect_equal(canonise("Palestine"), "West Bank and Gaza")
  expect_equal(canonise("Kyrgyzstan"), "Kyrgyz Republic")
  expect_equal(canonise("Slovakia"), "Slovak Republic")
  expect_equal(canonise("Turkey"), "Türkiye")
  expect_equal(canonise("Taiwan"), "Taipei China")
  expect_equal(canonise("Ivory Coast"), "Côte d'Ivoire")
})

test_that("canonise() works from ISO3 codes", {
  expect_equal(
    canonise(c("TUR", "SVK", "KGZ", "PSE", "CIV", "TWN", "HKG", "MAC"),
             from = "iso3c"),
    c("Türkiye", "Slovak Republic", "Kyrgyz Republic", "West Bank and Gaza",
      "Côte d'Ivoire", "Taipei China", "Hong Kong SAR", "Macao SAR")
  )
})

test_that("canonise() works from ISO2 codes", {
  expect_equal(canonise(c("TR", "KG"), from = "iso2c"),
               c("Türkiye", "Kyrgyz Republic"))
})

test_that("canonise() normalises Kosovo from any code", {
  expect_equal(canonise("KOS", from = "iso3c"), "Kosovo")
  expect_equal(canonise("XKX", from = "iso3c"), "Kosovo")
  expect_equal(canonise("Kosovo"), "Kosovo")
})

test_that("canonise() passes non-EBRD economies through unchanged", {
  expect_equal(canonise(c("Germany", "Japan")), c("Germany", "Japan"))
  expect_equal(canonise("DEU", from = "iso3c"), "Germany")
})

test_that("canonise() is vectorised and length/order preserving", {
  x <- c("Kyrgyzstan", "Germany", "Turkey", "Kazakhstan")
  out <- canonise(x)
  expect_length(out, length(x))
  expect_equal(out, c("Kyrgyz Republic", "Germany", "Türkiye", "Kazakhstan"))
})

test_that("canonise() returns NA for unmatched and reports them", {
  expect_message(
    out <- canonise(c("Kazakhstan", "Wakanda")),
    "could not be matched: Wakanda"
  )
  expect_equal(out, c("Kazakhstan", NA))
})

test_that("canonise() can stay silent", {
  expect_silent(out <- canonise("Wakanda", warn = FALSE))
  expect_true(is.na(out))
})

test_that("canonise() handles NA, empty strings and empty input", {
  expect_equal(canonise(c("Turkey", NA, "")), c("Türkiye", NA, NA))
  expect_equal(canonise(character(0)), character(0))
})

test_that("canonise() output is idempotent on EBRD names", {
  names <- list_ebrd("name")
  expect_equal(canonise(names), names)
})
