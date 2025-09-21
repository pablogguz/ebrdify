# Examples for ebrdify function
library(dplyr)

# 1. Basic examples from documentation
cat("\n1. Basic data frame example:\n")
data <- data.frame(country_code = c("KAZ", "CZE", "GRC", "ARM", "ALB", "EGY", "USA", "CAN"))
ebrdified_data <- ebrdify(data, "country_code", var_format = "iso3c")
print(ebrdified_data)

cat("\n2. Vector example:\n")
country_vector <- c("KAZ", "CZE", "GRC", "ARM", "ALB", "EGY", "USA", "CAN")
ebrdified_vector <- ebrdify(var = country_vector, var_format = "iso3c")
print(ebrdified_vector)

cat("\n3. Country names with fake countries:\n")
data_fake_names <- data.frame(country_name = c("Kazakhstan",
                                             "Czechia",
                                             "Narnia",
                                             "Armenia",
                                             "Albania",
                                             "Wakanda",
                                             "Kosovo",
                                             "United States",
                                             "Canada"))
ebrdified_data_fake_names <- ebrdify(data_fake_names, "country_name")
print(ebrdified_data_fake_names)

# 4. Edge cases and special scenarios
cat("\n4. Edge cases with missing values and empty strings:\n")
edge_cases <- data.frame(
  country_code = c("KAZ", NA, "", "USA", "", "GRC", NA),
  other_col = 1:7
)
ebrdified_edge <- ebrdify(edge_cases, "country_code", var_format = "iso3c")
print(ebrdified_edge)

cat("\n5. Mixed case input:\n")
mixed_case <- data.frame(country_code = c("kaz", "CZE", "grc", "ARM"))
ebrdified_mixed <- ebrdify(mixed_case, "country_code", var_format = "iso3c")
print(ebrdified_mixed)

cat("\n6. Different Kosovo representations:\n")
kosovo_cases <- data.frame(
  country = c("Kosovo", "KOSOVO", "Republic of Kosovo", "XK", "XKX"),
  format = c("country.name", "country.name", "country.name", "iso2c", "iso3c")
)
for(i in 1:nrow(kosovo_cases)) {
  cat("\nTesting Kosovo as:", kosovo_cases$country[i], "with format:", kosovo_cases$format[i], "\n")
  result <- ebrdify(var = kosovo_cases$country[i], var_format = kosovo_cases$format[i])
  print(result)
}

cat("\n7. All NA input:\n")
na_data <- data.frame(country_code = c(NA, NA, NA))
ebrdified_na <- ebrdify(na_data, "country_code", var_format = "iso3c")
print(ebrdified_na)

cat("\n8. Multiple columns with existing column names:\n")
existing_cols <- data.frame(
  country_code = c("KAZ", "USA", "GRC"),
  ebrd = c(0, 0, 0),  # This will be overwritten
  other_data = 1:3
)
ebrdified_existing <- ebrdify(existing_cols, "country_code", var_format = "iso3c")
print(ebrdified_existing)

cat("\n9. ISO2C input:\n")
iso2_data <- data.frame(country_code = c("KZ", "US", "GR", "AM"))
ebrdified_iso2 <- ebrdify(iso2_data, "country_code", var_format = "iso2c")
print(ebrdified_iso2)

cat("\n10. Testing with numerical country codes:\n")
num_data <- data.frame(country_code = c(1, 2, 3))
tryCatch({
  ebrdified_num <- ebrdify(num_data, "country_code", var_format = "iso3c")
  print(ebrdified_num)
}, error = function(e) {
  cat("Error:", e$message, "\n")
})

cat("\n11. Empty input handling:\n")
tryCatch({
  empty_result <- ebrdify(var = character(0))
  print(empty_result)
}, error = function(e) {
  cat("Error:", e$message, "\n")
})
