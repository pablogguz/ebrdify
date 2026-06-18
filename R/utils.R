# utils.R
#
# Internal helpers shared by ebrdify() and canonise(). Not exported.

# Coerce to character and treat empty strings as missing.
.clean_input <- function(x) {
  x <- as.character(x)
  x[x == ""] <- NA_character_
  x
}

# Guess the identifier format from the (cleaned) input. A vector whose non-empty
# values are all 3 characters is treated as iso3c, all 2 characters as iso2c,
# anything else as country names. Mirrors the original auto-detection.
.detect_format <- function(x) {
  non_empty <- x[!is.na(x) & nzchar(x)]
  if (length(non_empty) == 0L) {
    return("country.name")
  }
  widths <- unique(nchar(non_empty))
  if (length(widths) == 1L) {
    if (widths == 3L) {
      return("iso3c")
    }
    if (widths == 2L) {
      return("iso2c")
    }
  }
  "country.name"
}

# Convert a (cleaned) identifier vector to ISO3 codes, aligned element-for-element
# with the input. `from` must be one of "iso3c", "iso2c", "country.name".
#
# Performance: countrycode() (the expensive step) runs only on the *unique*
# non-ISO3 values; results are mapped back with a single named-vector index.
# Kosovo's EBRD code "KOS" is normalised to the canonical ISO3 "XKX" so both
# input codes classify identically. Code inputs are upper-cased here, so callers
# need not pre-case them.
.to_iso3c <- function(x, from) {
  if (from == "iso3c") {
    iso <- toupper(x)
  } else if (from == "iso2c") {
    x <- toupper(x)
    unique_values <- unique(x[!is.na(x)])
    iso <- unname(stats::setNames(.convert_iso(unique_values, "iso2c"), unique_values)[x])
  } else {
    unique_values <- unique(x[!is.na(x)])
    iso <- unname(stats::setNames(.convert_iso(unique_values, from), unique_values)[x])
  }

  # Normalise Kosovo's EBRD code to the canonical ISO3 (%in% never yields NA).
  iso[iso %in% "KOS"] <- "XKX"
  iso
}

# Thin wrapper around countrycode() with the Kosovo custom matches.
.convert_iso <- function(unique_values, from) {
  countrycode::countrycode(
    unique_values,
    origin = from,
    destination = "iso3c",
    custom_match = .kosovo_match,
    warn = FALSE
  )
}
