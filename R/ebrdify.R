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
#' - `coo_group`: A variable classifying the country into specific EBRD country groupins.
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


ebrdify <- function(data = NULL, var, var_format = NULL) {

  # Handle data frame input
  if (!is.null(data)) {
    # Check for existing columns that will be overwritten
    existing_columns <- intersect(names(data), c("ebrd", "coo_group", "eu_ebrd", "coo_group_alt"))
    if (length(existing_columns) > 0) {
      warning("The following columns will be overwritten: ", paste(existing_columns, collapse = ", "))
    }
    var <- data[[var]]
  } else {
    # Check if var is named vector and contains the names that will be overwritten
    if (is.null(names(var)) && any(names(var) %in% c("ebrd", "coo_group", "eu_ebrd", "coo_group_alt"))) {
      warning("Some elements in the vector are named 'ebrd', 'coo_group', 'eu_ebrd', or 'coo_group_alt' and will be overwritten.")
    }
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
  if (var_format == "country.name") {
    var_converted <- countrycode::countrycode(var, origin = var_format, destination = "iso3c")

    # Replace iso3c code when country name is Kosovo 
    var_converted <- ifelse(tolower(var) %in% c("kosovo", "republic of kosovo"), "XKX", var_converted)

  } else if (var_format == "iso2c") {
    var_converted <- countrycode::countrycode(var, origin = var_format, destination = "iso3c")

    # Replace iso3c code when iso2c is Kosovo
    var_converted <- ifelse(tolower(var) == "xk", "XKX", var_converted)

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
                                       "XKX", "KOS", "MNE", "MKD", "ROU", "SRB", "EGY",
                                       "JOR", "LBN", "MAR", "TUN", "PSE", "TUR"), 1, 0)

  coo_group <- dplyr::case_when(
    var_converted %in% c("KAZ", "KGZ", "MNG", "TJK", "TKM", "UZB") ~ "Central Asia",
    var_converted %in% c("HRV", "CZE", "EST", "HUN", "LVA", "LTU", "POL", "SVK", "SVN") ~ "Central Europe and Baltic States",
    var_converted == "GRC" ~ "Greece",
    var_converted %in% c("ARM", "AZE", "GEO", "MDA", "UKR") ~ "Eastern Europe and the Caucasus",
    var_converted %in% c("ALB", "BIH", "BGR", "XKX", "MNE", "MKD", "ROU", "SRB") ~ "South-eastern Europe",
    var_converted %in% c("EGY", "JOR", "LBN", "MAR", "TUN", "PSE") ~ "Southern and Eastern Mediterranean",
    var_converted %in% c("TUR") ~ "T\u00FCrkiye",
    TRUE ~ NA_character_
  )

  # List of EU members that are also EBRD countries
  eu_members <- c("HRV", "CZE", "EST", "HUN", "LVA", "LTU", "POL", "SVK", "SVN", "GRC", "BGR", "ROU")

  # Create the eu_ebrd variable
  eu_ebrd <- dplyr::if_else(var_converted %in% eu_members, 1, 0)

  # Alternative grouping 
  coo_group_alt <- dplyr::case_when(
    eu_ebrd == 1 ~ "EU-EBRD",
    var_converted %in% c("ARM", "AZE", "GEO", "KAZ", "KGZ", "MDA", "MNG", "TJK", "TKM", "UZB", "UKR") ~ "Former Soviet Union + Mongolia",
    var_converted %in% c("ALB", "BIH", "XKX", "MNE", "MKD", "SRB") ~ "Western Balkans",
    var_converted %in% c("EGY", "JOR", "LBN", "MAR", "TUN", "PSE") ~ "SEMED",
    var_converted == "TUR" ~ "T\u00FCrkiye",
    TRUE ~ NA_character_
  )

  # List of EBRD Shareholder countries in ISO3 format
  shareholder_countries <- c("ALB", "DZA", "ARM", "AUS", "AUT", "AZE", "BLR", "BEL", 
                             "BIH", "BGR", "CAN", "CHN", "HRV", "CYP", "CZE", "DNK", 
                             "EGY", "EST", "EIB", "EUU", "FIN", "FRA", "GEO", "DEU", 
                             "GRC", "HUN", "ISL", "IND", "IRL", "ISR", "ITA", "JPN", 
                             "JOR", "KAZ", "KOR", "XKX", "KGZ", "LVA", "LBN", "LBY", 
                             "LIE", "LTU", "LUX", "MLT", "MEX", "MDA", "MNG", "MNE", 
                             "MAR", "NLD", "NZL", "MKD", "NOR", "POL", "PRT", "ROU", 
                             "RUS", "SMR", "SRB", "SVK", "SVN", "ESP", "SWE", "CHE", 
                             "TJK", "TUN", "TUR", "TKM", "UKR", "ARE", "GBR", "USA", 
                             "UZB")

  # Create the ebrd_shareholder variable
  ebrd_shareholder <- dplyr::if_else(var_converted %in% shareholder_countries, 1, 0)

  result <- data.frame(ebrd = ebrd, coo_group = coo_group, eu_ebrd = eu_ebrd, coo_group_alt = coo_group_alt, ebrd_shareholder = ebrd_shareholder)

  if (!is.null(data)) {
    result <- cbind(data, result)
  }

  return(result)
}
