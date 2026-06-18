# canonise.R

#' Canonise country names to official EBRD terminology
#'
#' Rewrites country identifiers (names, ISO3 or ISO2 codes) to the official
#' country names used in the EBRD Transition Report. This enforces the TR house
#' style and the "forbidden names" rules from Annex I of the style guide — for
#' example:
#'
#' \itemize{
#'   \item Czech Republic \eqn{\rightarrow} Czechia
#'   \item Palestine \eqn{\rightarrow} West Bank and Gaza
#'   \item Kyrgyzstan \eqn{\rightarrow} Kyrgyz Republic
#'   \item Slovakia \eqn{\rightarrow} Slovak Republic
#'   \item Turkey \eqn{\rightarrow} Türkiye
#'   \item Ivory Coast \eqn{\rightarrow} Côte d'Ivoire
#'   \item Taiwan \eqn{\rightarrow} Taipei China
#' }
#'
#' EBRD economies are named from the official Annex I list; other economies fall
#' back to `countrycode`'s English short name, with TR-specific overrides applied
#' on top (Taipei China, Hong Kong SAR, Macao SAR, Czechia) because `countrycode`
#' returns a non-TR form for those.
#'
#' @param x A vector of country identifiers (names, ISO3, or ISO2 codes).
#' @param from Format of `x`: `"country.name"`, `"iso3c"`, or `"iso2c"`. If
#'   `NULL` (default) the format is auto-detected.
#' @param warn If `TRUE` (default), report identifiers that could not be matched
#'   via [message()].
#' @return A character vector the same length as `x` of official EBRD/TR names,
#'   with `NA` for identifiers that could not be matched. Designed to drop into
#'   `dplyr::mutate()`, e.g. `mutate(country = canonise(country))`.
#' @seealso [ebrdify()] to classify economies and [list_ebrd()] for the full
#'   list of EBRD economies.
#' @importFrom countrycode countrycode
#' @export
#' @examples
#' canonise(c("Czech Republic", "Palestine", "Kyrgyzstan", "Taiwan"))
#' canonise(c("TUR", "SVK", "CIV"), from = "iso3c")
#' canonise(c("Germany", "Wakanda"))   # non-EBRD pass through; unmatched -> NA
canonise <- function(x, from = NULL, warn = TRUE) {
  x <- .clean_input(x)

  if (length(x) == 0L) {
    return(character(0))
  }

  if (is.null(from)) {
    from <- .detect_format(x)
  }

  iso <- .to_iso3c(x, from)
  out <- unname(.tr_name_override[iso])

  # Anything resolved to an ISO3 code but not covered by the TR overrides gets
  # countrycode's English short name (computed once per unique code).
  needs_fallback <- !is.na(iso) & is.na(out)
  if (any(needs_fallback)) {
    unique_iso <- unique(iso[needs_fallback])
    fallback <- countrycode::countrycode(
      unique_iso, origin = "iso3c", destination = "country.name.en",
      warn = FALSE
    )
    out[needs_fallback] <- stats::setNames(fallback, unique_iso)[iso[needs_fallback]]
  }

  unmatched <- !is.na(x) & is.na(out)
  if (warn && any(unmatched)) {
    message("The following entries could not be matched: ",
            paste(unique(x[unmatched]), collapse = ", "))
  }

  out
}
