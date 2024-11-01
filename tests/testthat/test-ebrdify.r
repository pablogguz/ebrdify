# tests/testthat/test-ebrdify.R

library(testthat)

# Test data setup
test_that("setup test data works", {
  # Basic test data
  expect_no_error({
    test_data <- data.frame(
      country_code = c("KAZ", "CZE", "GRC", "ARM", "ALB", "EGY", "USA", "CAN"),
      stringsAsFactors = FALSE
    )
    test_vector <- c("KAZ", "CZE", "GRC", "ARM", "ALB", "EGY", "USA", "CAN")
  })
})

# Input format tests
test_that("function accepts different input formats", {
  # Test ISO3C
  expect_no_error(ebrdify(var = c("KAZ", "USA"), var_format = "iso3c"))
  
  # Test ISO2C
  expect_no_error(ebrdify(var = c("KZ", "US"), var_format = "iso2c"))
  
  # Test country names
  expect_no_error(ebrdify(var = c("Kazakhstan", "United States"), var_format = "country.name"))
  
  # Test auto-detection
  expect_no_error(ebrdify(var = c("KAZ", "USA")))
  expect_no_error(ebrdify(var = c("Kazakhstan", "United States")))
})

# Test EBRD country classification
test_that("EBRD country classification is correct", {
  test_data <- data.frame(
    country_code = c("KAZ", "USA", "GRC", "TUR"),
    stringsAsFactors = FALSE
  )
  result <- ebrdify(test_data, "country_code", "iso3c")
  
  # Test EBRD countries are correctly identified
  expect_equal(result$ebrd[result$country_code == "KAZ"], 1)
  expect_equal(result$ebrd[result$country_code == "USA"], 0)
  expect_equal(result$ebrd[result$country_code == "GRC"], 1)
  expect_equal(result$ebrd[result$country_code == "TUR"], 1)
})

# Test EU membership
test_that("EU membership is correctly identified", {
  test_data <- data.frame(
    country_code = c("GRC", "TUR", "POL", "USA"),
    stringsAsFactors = FALSE
  )
  result <- ebrdify(test_data, "country_code", "iso3c")
  
  expect_equal(result$eu_ebrd[result$country_code == "GRC"], 1)
  expect_equal(result$eu_ebrd[result$country_code == "TUR"], 0)
  expect_equal(result$eu_ebrd[result$country_code == "POL"], 1)
  expect_equal(result$eu_ebrd[result$country_code == "USA"], 0)
})

# Test regional groupings
test_that("regional groupings are correct", {
  test_data <- data.frame(
    country_code = c("KAZ", "HUN", "GRC", "ARM", "ALB", "EGY", "TUR"),
    stringsAsFactors = FALSE
  )
  result <- ebrdify(test_data, "country_code", "iso3c")
  
  # Test specific regional assignments
  expect_equal(result$coo_group[result$country_code == "KAZ"], "Central Asia")
  expect_equal(result$coo_group[result$country_code == "HUN"], "Central Europe and Baltic States")
  expect_equal(result$coo_group[result$country_code == "GRC"], "Greece")
  expect_equal(result$coo_group[result$country_code == "ARM"], "Eastern Europe and the Caucasus")
  expect_equal(result$coo_group[result$country_code == "ALB"], "South-eastern Europe")
  expect_equal(result$coo_group[result$country_code == "EGY"], "Southern and Eastern Mediterranean")
  expect_equal(result$coo_group[result$country_code == "TUR"], "Türkiye")
})

# Test alternative groupings
test_that("alternative groupings are correct", {
  test_data <- data.frame(
    country_code = c("POL", "KAZ", "ALB", "EGY", "TUR"),
    stringsAsFactors = FALSE
  )
  result <- ebrdify(test_data, "country_code", "iso3c")
  
  expect_equal(result$coo_group_alt[result$country_code == "POL"], "EU-EBRD")
  expect_equal(result$coo_group_alt[result$country_code == "KAZ"], "Former Soviet Union + Mongolia")
  expect_equal(result$coo_group_alt[result$country_code == "ALB"], "Western Balkans")
  expect_equal(result$coo_group_alt[result$country_code == "EGY"], "SEMED")
  expect_equal(result$coo_group_alt[result$country_code == "TUR"], "Türkiye")
})

# Test Kosovo handling
test_that("Kosovo is handled correctly", {
  # Test different Kosovo representations
  kosovo_data <- data.frame(
    country_name = c("Kosovo", "Republic of Kosovo", "XK", "XKX"),
    format = c("country.name", "country.name", "iso2c", "iso3c")
  )
  
  for(i in 1:nrow(kosovo_data)) {
    result <- ebrdify(var = kosovo_data$country_name[i], var_format = kosovo_data$format[i])
    expect_equal(result$ebrd, 1)
    expect_equal(result$coo_group, "South-eastern Europe")
  }
})


# Test warning messages
test_that("warnings are generated appropriately", {
  # Test unmatched entries message
  expect_message(
    ebrdify(var = c("Narnia"), var_format = "country.name"),
    "The following entries could not be matched: Narnia"
  )
})

# Test handling of missing values
test_that("missing values are handled correctly", {
  test_data <- data.frame(
    country_code = c("KAZ", NA, "USA", ""),
    stringsAsFactors = FALSE
  )
  result <- ebrdify(test_data, "country_code", "iso3c")
  
  # Check NA handling
  expect_true(is.na(result$ebrd[is.na(test_data$country_code)]))
  expect_true(is.na(result$coo_group[is.na(test_data$country_code)]))
  expect_true(is.na(result$eu_ebrd[is.na(test_data$country_code)]))
  expect_true(is.na(result$ebrd_shareholder[is.na(test_data$country_code)]))
  
  # Check empty string handling - use all() to handle multiple empty strings
  expect_true(all(is.na(result$ebrd[test_data$country_code == ""])))
})

# Test shareholder classification
test_that("shareholder classification is correct", {
  test_data <- data.frame(
    country_code = c("GBR", "USA", "CHN", "BRA", "AUS"),
    stringsAsFactors = FALSE
  )
  result <- ebrdify(test_data, "country_code", "iso3c")
  
  expect_equal(result$ebrd_shareholder[result$country_code == "GBR"], 1)
  expect_equal(result$ebrd_shareholder[result$country_code == "USA"], 1)
  expect_equal(result$ebrd_shareholder[result$country_code == "CHN"], 1)
  expect_equal(result$ebrd_shareholder[result$country_code == "BRA"], 0)
  expect_equal(result$ebrd_shareholder[result$country_code == "AUS"], 1)
})

# Test data structure preservation
test_that("input data structure is preserved", {
  # Test with data frame input
  test_df <- data.frame(
    country_code = c("KAZ", "USA"),
    other_col = c(1, 2),
    stringsAsFactors = FALSE
  )
  result_df <- ebrdify(test_df, "country_code", "iso3c")
  
  expect_true(all(names(test_df) %in% names(result_df)))
  expect_equal(nrow(test_df), nrow(result_df))
  
  # Test with vector input
  test_vector <- c("KAZ", "USA")
  result_vector <- ebrdify(var = test_vector, var_format = "iso3c")
  
  expect_equal(nrow(result_vector), length(test_vector))
})

# Test edge cases
test_that("edge cases are handled correctly", {
  # Empty input
  expect_error(ebrdify(var = character(0)))
  
  # Single value
  expect_no_error(ebrdify(var = "KAZ"))
  
  # All NAs
  all_na_result <- ebrdify(var = as.character(c(NA, NA)))
  expect_true(all(is.na(all_na_result$ebrd)))
  
  # Mixed case
  case_result <- ebrdify(var = c("kaz", "KAZ"), var_format = "iso3c")
  expect_equal(case_result$ebrd, c(1, 1))
  
  # Empty strings
  empty_result <- ebrdify(var = c("", "KAZ"), var_format = "iso3c")
  expect_true(is.na(empty_result$ebrd[1]))
  expect_equal(empty_result$ebrd[2], 1)
})