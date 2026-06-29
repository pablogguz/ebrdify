# tests/testthat/test-list_ebrd.R

library(testthat)

test_that("list_ebrd() returns all 41 economies in each format", {
  both <- list_ebrd()
  expect_s3_class(both, "data.frame")
  expect_named(both, c("iso3c", "name"))
  expect_equal(nrow(both), 41)

  expect_length(list_ebrd("iso3c"), 41)
  expect_length(list_ebrd("name"), 41)
})

test_that("list_ebrd() output is sorted and de-duplicated", {
  expect_equal(list_ebrd("iso3c"), sort(list_ebrd("iso3c")))
  expect_equal(list_ebrd("name"), sort(list_ebrd("name")))
  expect_false(any(duplicated(list_ebrd("iso3c"))))
  expect_false(any(duplicated(list_ebrd("name"))))
})

test_that("list_ebrd() uses official EBRD names", {
  names <- list_ebrd("name")
  # official forms must be present...
  expect_true(all(c("Kyrgyz Republic", "Slovak Republic", "Türkiye",
                     "West Bank and Gaza", "Côte d'Ivoire", "Kosovo") %in% names))
  # ...and non-standard / non-EBRD forms absent
  expect_false(any(c("Kyrgyzstan", "Slovakia", "Turkey", "Palestine",
                     "Czechia", "Greece") %in% names))
})

test_that("list_ebrd() codes and names line up", {
  both <- list_ebrd("both")
  # codes match the standalone code list, names match the standalone name list
  expect_setequal(both$iso3c, list_ebrd("iso3c"))
  expect_setequal(both$name, list_ebrd("name"))
  # XKX is the Kosovo code (not KOS)
  expect_true("XKX" %in% both$iso3c)
  expect_false("KOS" %in% both$iso3c)
})

test_that("list_ebrd() filters by group", {
  ca <- list_ebrd("iso3c", group = "Central Asia")
  expect_setequal(ca, c("KAZ", "KGZ", "MNG", "TJK", "TKM", "UZB"))

  turkiye <- list_ebrd("name", group = "Türkiye")
  expect_equal(turkiye, "Türkiye")

  expect_error(list_ebrd(group = "Narnia"), "must be one of")
})

test_that("list_ebrd() rejects bad `what`", {
  expect_error(list_ebrd("codes"))
})

test_that("list_ebrd_groups() returns the seven traditional groupings", {
  groups <- list_ebrd_groups()
  expect_length(groups, 7)
  expect_true("Central Asia" %in% groups)
  expect_true("Türkiye" %in% groups)
  # every group is usable as a filter and covers the 41 economies
  expect_equal(sum(vapply(groups, function(g) length(list_ebrd("iso3c", g)), integer(1))), 41)
})
