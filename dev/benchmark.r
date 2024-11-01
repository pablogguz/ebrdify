

source("dev/ebrdify_2.R")
library(microbenchmark)
library(ggplot2)
devtools::load_all()

set.seed(123)
n_rows <- 100000
country_codes <- c("KAZ", "CZE", "GRC", "ARM", "ALB", "EGY", "USA", "CAN")
test_data <- data.frame(
  country_code = sample(country_codes, n_rows, replace = TRUE)
)

# Run benchmark
benchmark_results <- microbenchmark(
  original = ebrdify(test_data, "country_code", "iso3c"),
  optimized = ebrdify_2(test_data, "country_code", "iso3c"),
  times = 100
)

# Print results
print(benchmark_results)

# Create visualization
autoplot(benchmark_results) + 
  labs(title = "Performance Comparison: Original vs Optimized ebrdify",
       x = "Implementation", 
       y = "Time (microseconds)") +
  theme_minimal()
