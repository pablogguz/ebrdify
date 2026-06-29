# ebrdify.R

#' Classify countries into EBRD groupings
#'
#' Tags each country in a dataset with its EBRD status and regional groupings,
#' following the official EBRD / Transition Report classification (Annex I of the
#' OCE TR style guide). Country identifiers may be ISO3 codes, ISO2 codes, or
#' country names, and the format is auto-detected when not supplied.
#'
#' @param data A data frame containing the country variable, or `NULL` when
#'   passing a vector via `var`.
#' @param var Either the name of the column in `data` holding the country
#'   identifiers, or — when `data` is `NULL` — a vector of country identifiers.
#' @param var_format Format of the identifiers: `"country.name"`, `"iso3c"`, or
#'   `"iso2c"`. If `NULL` (default) the format is auto-detected.
#' @return A data frame with five appended columns. When `data` is supplied the
#'   original columns are kept and these are added; otherwise a data frame with
#'   just these columns (one row per input element) is returned.
#'   \describe{
#'     \item{`ebrd`}{`1` if an EBRD country of operation, `0` otherwise, `NA`
#'       if the identifier could not be matched.}
#'     \item{`coo_group`}{Traditional EBRD regional grouping, or `NA`.}
#'     \item{`eu_ebrd`}{`1` if both an EBRD economy and an EU member, else `0`
#'       (`NA` if unmatched).}
#'     \item{`coo_group_alt`}{Alternative EBRD grouping, or `NA`.}
#'     \item{`ebrd_shareholder`}{`1` if an EBRD shareholder, else `0` (`NA` if
#'       unmatched).}
#'     \item{`comparator_imf`}{IMF/WEO comparator bucket, one of `"EBRD regions"`
#'       (any EBRD economy), `"Advanced Economies"` (non-EBRD advanced economy,
#'       e.g. Germany, Czechia, Greece), or `"Other EMDEs"` (every other resolved
#'       economy); `NA` if unmatched.}
#'   }
#'   Unmatched identifiers are reported once via [message()].
#' @seealso [list_ebrd()] for the full list of EBRD economies and [canonise()]
#'   to standardise country names.
#' @importFrom countrycode countrycode
#' @export
#' @examples
#' # Using a data frame
#' df <- data.frame(country_code = c("KAZ", "HRV", "NGA", "ARM", "USA"))
#' ebrdify(df, "country_code", var_format = "iso3c")
#'
#' # Using a vector, with auto-detected format
#' ebrdify(var = c("Kazakhstan", "Croatia", "Narnia", "United States"))
ebrdify <- function(data = NULL, var, var_format = NULL) {
  new_cols <- c("ebrd", "coo_group", "eu_ebrd", "coo_group_alt",
                "ebrd_shareholder", "comparator_imf")

  # Resolve the identifier vector and warn about columns/names we will overwrite.
  if (!is.null(data)) {
    if (nrow(data) == 0L) {
      stop("Input cannot be empty")
    }
    clash <- intersect(names(data), new_cols)
    if (length(clash) > 0L) {
      warning("The following columns will be overwritten: ",
              paste(clash, collapse = ", "))
    }
    var_data <- data[[var]]
  } else {
    if (length(var) == 0L) {
      stop("Input cannot be empty")
    }
    clash <- intersect(names(var), new_cols)
    if (length(clash) > 0L) {
      warning("Some elements in the vector are named: ",
              paste(clash, collapse = ", "), " and will be overwritten.")
    }
    var_data <- var
  }

  var_data <- .clean_input(var_data)
  n <- length(var_data)

  # All-missing input: return the right shape without touching countrycode.
  if (all(is.na(var_data))) {
    result <- data.frame(
      ebrd = rep(NA_integer_, n),
      coo_group = rep(NA_character_, n),
      eu_ebrd = rep(NA_integer_, n),
      coo_group_alt = rep(NA_character_, n),
      ebrd_shareholder = rep(NA_integer_, n),
      comparator_imf = rep(NA_character_, n),
      stringsAsFactors = FALSE,
      row.names = NULL
    )
    if (!is.null(data)) {
      result <- cbind(data, result)
    }
    return(result)
  }

  if (is.null(var_format)) {
    var_format <- .detect_format(var_data)
  }

  iso <- .to_iso3c(var_data, var_format)

  # Report anything that could not be resolved to an ISO3 code, once.
  unmatched <- !is.na(var_data) & is.na(iso)
  if (any(unmatched)) {
    message("The following entries could not be matched: ",
            paste(unique(var_data[unmatched]), collapse = ", "))
  }

  valid <- !is.na(iso)

  # Logical lookups return TRUE / NA; turn into 1/0 and restore NA for unmatched.
  ebrd <- as.integer(!is.na(.ebrd_lookup[iso]))
  ebrd[!valid] <- NA_integer_
  eu <- as.integer(!is.na(.eu_lookup[iso]))
  eu[!valid] <- NA_integer_
  shareholder <- as.integer(!is.na(.shareholder_lookup[iso]))
  shareholder[!valid] <- NA_integer_

  # IMF/WEO comparator bucket, mutually exclusive over every resolved economy:
  # EBRD economies -> "EBRD regions"; non-EBRD advanced -> "Advanced Economies";
  # all other resolved economies -> "Other EMDEs". EBRD is assigned last so it
  # wins for economies (e.g. Croatia) that are also IMF-advanced.
  comparator_imf <- rep(NA_character_, n)
  comparator_imf[valid] <- "Other EMDEs"
  comparator_imf[valid & !is.na(.advanced_lookup[iso])] <- "Advanced Economies"
  comparator_imf[valid & !is.na(.ebrd_lookup[iso])] <- "EBRD regions"

  # row.names = NULL stops data.frame() from adopting the lookups' (NA-bearing)
  # names as row names, so the character columns can stay named — no unname pass.
  result <- data.frame(
    ebrd = ebrd,
    coo_group = .region_lookup[iso],
    eu_ebrd = eu,
    coo_group_alt = .alt_lookup[iso],
    ebrd_shareholder = shareholder,
    comparator_imf = comparator_imf,
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  if (!is.null(data)) {
    result <- cbind(data, result)
  }

  result
}
