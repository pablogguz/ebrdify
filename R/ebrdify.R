# ebrdify.R

#' EBRD Country Classification
#'
#' This function classifies countries based on their EBRD status, region, and EU membership.
#'
#' @param data A data frame containing the variable to classify, or NULL if using a vector input.
#' @param var A string specifying the name of the variable in `data` that contains the country codes, or a vector of country codes.
#' @param var_format A string specifying the format of the country codes in `var`. It can be "country.name", "iso3c", or "iso2c". If NULL, the function will attempt to detect the format.
#' @return A data frame with four new variables: `ebrd`, `coo_group`, `eu_ebrd`, and `coo_group_alt`, and prints out any unmatched entries.
#' - `ebrd`: A binary variable indicating whether the country is an EBRD country of operation (1 = EBRD COO, 0 = Non-COO).
#' - `coo_group`: A variable classifying the country into specific EBRD country groupings.
#' - `eu_ebrd`: A binary variable indicating whether the country is both an EBRD country of operation and an EU member (1 = EU & EBRD, 0 = otherwise).
#' - `coo_group_alt`: An alternative classification of countries into broader categories
#' - `ebrd_shareholder`: A binary variable indicating whether the country is an EBRD shareholder (1 = Shareholder, 0 = Non-Shareholder).
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
#'                                                "Kosovo",
#'                                                "United States",
#'                                                "Canada"))
#' ebrdified_data_fake_names <- ebrdify(data_fake_names, "country_name")
#' print(ebrdified_data_fake_names)
#' 
ebrdify <- function(data = NULL, var, var_format = NULL) {
  # Pre-compute all lookup tables for performance
  EBRD_COUNTRIES <- c("KAZ", "KGZ", "MNG", "TJK", "TKM", "UZB",
                      "HRV", "CZE", "EST", "HUN", "LVA", "LTU",
                      "POL", "SVK", "SVN", "GRC", "ARM", "AZE",
                      "GEO", "MDA", "UKR", "ALB", "BIH", "BGR",
                      "XKX", "KOS", "MNE", "MKD", "ROU", "SRB", "EGY",
                      "JOR", "LBN", "MAR", "TUN", "PSE", "TUR")

  REGION_MAP <- list(
    "Central Asia" = c("KAZ", "KGZ", "MNG", "TJK", "TKM", "UZB"),
    "Central Europe and Baltic States" = c("HRV", "CZE", "EST", "HUN", "LVA", "LTU", "POL", "SVK", "SVN"),
    "Greece" = "GRC",
    "Eastern Europe and the Caucasus" = c("ARM", "AZE", "GEO", "MDA", "UKR"),
    "South-eastern Europe" = c("ALB", "BIH", "BGR", "XKX", "MNE", "MKD", "ROU", "SRB"),
    "Southern and Eastern Mediterranean" = c("EGY", "JOR", "LBN", "MAR", "TUN", "PSE"),
    "T\u00FCrkiye" = "TUR"
  )

  EU_MEMBERS <- c("HRV", "CZE", "EST", "HUN", "LVA", "LTU", "POL", "SVK", "SVN", "GRC", "BGR", "ROU")

  ALT_GROUP_MAP <- list(
    "EU-EBRD" = EU_MEMBERS,
    "Former Soviet Union + Mongolia" = c("ARM", "AZE", "GEO", "KAZ", "KGZ", "MDA", "MNG", "TJK", "TKM", "UZB", "UKR"),
    "Western Balkans" = c("ALB", "BIH", "XKX", "MNE", "MKD", "SRB"),
    "SEMED" = c("EGY", "JOR", "LBN", "MAR", "TUN", "PSE"),
    "T\u00FCrkiye" = "TUR"
  )

  SHAREHOLDERS <- c("ALB", "DZA", "ARM", "AUS", "AUT", "AZE", "BLR", "BEL", 
                    "BIH", "BGR", "CAN", "CHN", "HRV", "CYP", "CZE", "DNK", 
                    "EGY", "EST", "EIB", "EUU", "FIN", "FRA", "GEO", "DEU", 
                    "GRC", "HUN", "ISL", "IND", "IRL", "ISR", "ITA", "JPN", 
                    "JOR", "KAZ", "KOR", "XKX", "KGZ", "LVA", "LBN", "LBY", 
                    "LIE", "LTU", "LUX", "MLT", "MEX", "MDA", "MNG", "MNE", 
                    "MAR", "NLD", "NZL", "MKD", "NOR", "POL", "PRT", "ROU", 
                    "RUS", "SMR", "SRB", "SVK", "SVN", "ESP", "SWE", "CHE", 
                    "TJK", "TUN", "TUR", "TKM", "UKR", "ARE", "GBR", "USA", 
                    "UZB")


  # Check for empty input
  if ((!is.null(data) && nrow(data) == 0) || (is.null(data) && length(var) == 0)) {
    stop("Input cannot be empty")
  }

  # Check for column overwriting
  new_cols <- c("ebrd", "coo_group", "eu_ebrd", "coo_group_alt", "ebrd_shareholder")
  
  if (!is.null(data)) {
    existing_columns <- intersect(names(data), new_cols)
    if (length(existing_columns) > 0) {
      warning("The following columns will be overwritten: ", 
              paste(existing_columns, collapse = ", "))
    }
    var_data <- data[[var]]
  } else {
    if (!is.null(names(var))) {
      overlapping_names <- intersect(names(var), new_cols)
      if (length(overlapping_names) > 0) {
        warning("Some elements in the vector are named: ", 
                paste(overlapping_names, collapse = ", "), 
                " and will be overwritten.")
      }
    }
    var_data <- var
  }
  
  # Convert to character and handle empty strings
  var_data <- as.character(var_data)
  var_data[var_data == ""] <- NA_character_
  
  # Handle all-NA case
  if (all(is.na(var_data))) {
    return(data.frame(
      ebrd = rep(NA_integer_, length(var_data)),
      coo_group = rep(NA_character_, length(var_data)),
      eu_ebrd = rep(NA_integer_, length(var_data)),
      coo_group_alt = rep(NA_character_, length(var_data)),
      ebrd_shareholder = rep(NA_integer_, length(var_data))
    ))
  }
  
  # Fast format detection
  if (is.null(var_format)) {
    non_empty <- var_data[!is.na(var_data) & nchar(var_data) > 0]
    char_lengths <- unique(nchar(non_empty))
    var_format <- if (length(char_lengths) == 1) {
      if (char_lengths == 3) "iso3c"
      else if (char_lengths == 2) "iso2c"
      else "country.name"
    } else "country.name"
  }
  
  # Convert to uppercase for iso codes
  if (var_format %in% c("iso3c", "iso2c")) {
    var_data <- toupper(var_data)
  }
  
  # Vectorized conversion
  if (var_format != "iso3c") {
    var_converted <- countrycode::countrycode(var_data, origin = var_format, destination = "iso3c", 
                                            custom_match = c(Kosovo = "XKX", "KOSOVO" = "XKX", 
                                                           "Republic of Kosovo" = "XKX", "XK" = "XKX"))
  } else {
    var_converted <- var_data
  }
  
  # Report unmatched entries once
  unmatched <- unique(var_data[!is.na(var_data) & is.na(var_converted)])
  if (length(unmatched) > 0) {
    message("The following entries could not be matched: ", 
            paste(unmatched, collapse = ", "))
  }
  
  # Initialize result with NAs
  result <- data.frame(
    ebrd = rep(NA_integer_, length(var_converted)),
    coo_group = rep(NA_character_, length(var_converted)),
    eu_ebrd = rep(NA_integer_, length(var_converted)),
    coo_group_alt = rep(NA_character_, length(var_converted)),
    ebrd_shareholder = rep(NA_integer_, length(var_converted))
  )
  
  # Set values only for valid entries (non-NA and non-empty)
  valid_entries <- !is.na(var_converted)
  result$ebrd[valid_entries] <- as.integer(var_converted[valid_entries] %in% EBRD_COUNTRIES)
  result$eu_ebrd[valid_entries] <- as.integer(var_converted[valid_entries] %in% EU_MEMBERS)
  result$ebrd_shareholder[valid_entries] <- as.integer(var_converted[valid_entries] %in% SHAREHOLDERS)
  
  # Set region groupings only for valid entries
  for (region in names(REGION_MAP)) {
    matches <- var_converted %in% REGION_MAP[[region]]
    result$coo_group[matches] <- region
  }
  
  for (group in names(ALT_GROUP_MAP)) {
    matches <- var_converted %in% ALT_GROUP_MAP[[group]]
    result$coo_group_alt[matches] <- group
  }
  
  if (!is.null(data)) {
    result <- cbind(data, result)
  }
  
  return(result)
}