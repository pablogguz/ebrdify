# list_ebrd.R

#' List EBRD economies
#'
#' Returns the full list of the 41 EBRD economies — their ISO3 codes, their
#' official EBRD/Transition Report names, or both — optionally restricted to a
#' single traditional regional grouping.
#'
#' @param what What to return: `"both"` (default) a data frame with `iso3c` and
#'   `name` columns; `"iso3c"` a character vector of ISO3 codes; `"name"` a
#'   character vector of official names.
#' @param group Optional. One traditional `coo_group` to filter to, e.g.
#'   `"Central Asia"`. `NULL` (default) returns all economies. See
#'   [list_ebrd_groups()] for the valid values.
#' @return A data frame (`what = "both"`) or character vector, ordered
#'   alphabetically by official name (or by code for `what = "iso3c"`).
#' @seealso [ebrdify()] to classify a dataset and [canonise()] to standardise
#'   country names.
#' @export
#' @examples
#' list_ebrd()                       # data frame of all 41 economies
#' list_ebrd("iso3c")                # just the ISO3 codes
#' list_ebrd("name", group = "Central Asia")
list_ebrd <- function(what = c("both", "iso3c", "name"), group = NULL) {
  what <- match.arg(what)

  tbl <- .ebrd_economies

  if (!is.null(group)) {
    valid_groups <- unique(.ebrd_economies$coo_group)
    if (!group %in% valid_groups) {
      stop("`group` must be one of: ", paste(valid_groups, collapse = ", "))
    }
    tbl <- tbl[tbl$coo_group == group, , drop = FALSE]
  }

  switch(what,
    iso3c = sort(tbl$iso3c),
    name  = sort(tbl$name),
    both  = {
      ord <- order(tbl$name)
      data.frame(
        iso3c = tbl$iso3c[ord],
        name = tbl$name[ord],
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    }
  )
}

#' EBRD regional groupings
#'
#' Returns the names of the traditional EBRD regional groupings (`coo_group`)
#' that can be passed to the `group` argument of [list_ebrd()].
#'
#' @return A character vector of grouping names.
#' @seealso [list_ebrd()]
#' @export
#' @examples
#' list_ebrd_groups()
list_ebrd_groups <- function() {
  sort(unique(.ebrd_economies$coo_group))
}
