# ebrdify.R

#' EBRD Country Classification
#'
#' This function classifies countries based on their EBRD status and region.
#'
#' @param data A data frame containing the variable to classify, or NULL if using a vector input.
#' @param var A string specifying the name of the variable in `data` that contains the country codes, or a vector of country codes.
#' @param var_format A string specifying the format of the country codes in `var`. It can be "country.name", "iso3c", or "iso2c". If NULL, the function will attempt to detect the format.
#' @return A data frame with two new variables: `ebrd` and `coo_group`, and prints out any unmatched entries.
#' @importFrom countrycode countrycode
#' @importFrom dplyr mutate if_else recode case_when select
#' @importFrom tidyr replace_na
#' @importFrom stats na.omit
#' @export
#' @examples
#' # Using a data frame
#' data <- data.frame(country_code = c("KAZ", "CZE", "GRC", "ARM", "ALB", "EGY", "USA", "CAN"))
#' ebrdified_data <- ebrdify(data, "country_code", var_format = "iso3c")
#' print(ebrdified_data)
#'
#' # Using a vector
#' country_vector <- c("KAZ", "CZE", "GRC", "ARM", "ALB", "EGY", "USA", "CAN")
#' ebrdified_vector <- ebrdify(var = country_vector, var_format = "iso3c")
#' print(ebrdified_vector)
#'
#' # Using a data frame with fake country names
#' data_fake_names <- data.frame(country_name = c("Kazakhstan",
#'                                                "Czechia",
#'                                                "Narnia",
#'                                                "Armenia",
#'                                                "Albania",
#'                                                "Wakanda",
#'                                                "United States",
#'                                                "Canada"))
#' ebrdified_data_fake_names <- ebrdify(data_fake_names, "country_name")
#' print(ebrdified_data_fake_names)

ebrdify <- function(data = NULL, var, var_format = NULL) {
  # Handle data frame input
  if (!is.null(data)) {
    var <- data[[var]]
  }

  # Detect the format if not specified
  if (is.null(var_format)) {
    if (all(nchar(na.omit(var)) == 3)) {
      var_format <- "iso3c"
    } else if (all(nchar(na.omit(var)) == 2)) {
      var_format <- "iso2c"
    } else if (any(na.omit(var) %in% countrycode::codelist$country.name.en)) {
      var_format <- "country.name"
    } else {
      stop("Could not detect the format of the country codes. Please specify the var_format.")
    }
  }

  # Convert to ISO3 if necessary
  if (var_format != "iso3c") {
    var_converted <- countrycode::countrycode(var, origin = var_format, destination = "iso3c")
  } else {
    var_converted <- var
  }

  # Unmatched entries
  unmatched <- var[is.na(var_converted)]
  if (length(unmatched) > 0) {
    message("The following entries could not be matched: ", paste(unmatched, collapse = ", "))
  }

  # Create the ebrd and coo_group variables
  ebrd <- if_else(var_converted %in% c("KAZ", "KGZ", "MNG", "TJK", "TKM", "UZB",
                                       "HRV", "CZE", "EST", "HUN", "LVA", "LTU",
                                       "POL", "SVK", "SVN", "GRC", "ARM", "AZE",
                                       "GEO", "MDA", "UKR", "ALB", "BIH", "BGR",
                                       "XKX", "MNE", "MKD", "ROU", "SRB", "EGY",
                                       "JOR", "LBN", "MAR", "TUN", "PSE", "TUR"), 1, 0)

  coo_group <- dplyr::case_when(
    var_converted %in% c("KAZ", "KGZ", "MNG", "TJK", "TKM", "UZB") ~ "Central Asia",
    var_converted %in% c("HRV", "CZE", "EST", "HUN", "LVA", "LTU", "POL", "SVK", "SVN") ~ "Central Europe and Baltic States",
    var_converted == "GRC" ~ "Greece",
    var_converted %in% c("ARM", "AZE", "GEO", "MDA", "UKR") ~ "Eastern Europe and the Caucasus",
    var_converted %in% c("ALB", "BIH", "BGR", "XKX", "MNE", "MKD", "ROU", "SRB") ~ "South-eastern Europe",
    var_converted %in% c("EGY", "JOR", "LBN", "MAR", "TUN", "PSE", "TUR") ~ "Southern and Eastern Mediterranean",
    TRUE ~ NA_character_
  )

  result <- data.frame(ebrd = ebrd, coo_group = coo_group)

  if (!is.null(data)) {
    result <- cbind(data, result)
  }

  return(result)
}
