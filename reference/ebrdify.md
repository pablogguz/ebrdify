# Classify countries into EBRD groupings

Tags each country in a dataset with its EBRD status and regional
groupings, following the official EBRD / Transition Report
classification (Annex I of the OCE TR style guide). Country identifiers
may be ISO3 codes, ISO2 codes, or country names, and the format is
auto-detected when not supplied.

## Usage

``` r
ebrdify(data = NULL, var, var_format = NULL)
```

## Arguments

- data:

  A data frame containing the country variable, or `NULL` when passing a
  vector via `var`.

- var:

  Either the name of the column in `data` holding the country
  identifiers, or — when `data` is `NULL` — a vector of country
  identifiers.

- var_format:

  Format of the identifiers: `"country.name"`, `"iso3c"`, or `"iso2c"`.
  If `NULL` (default) the format is auto-detected.

## Value

A data frame with five appended columns. When `data` is supplied the
original columns are kept and these are added; otherwise a data frame
with just these columns (one row per input element) is returned.

- `ebrd`:

  `1` if an EBRD country of operation, `0` otherwise, `NA` if the
  identifier could not be matched.

- `coo_group`:

  Traditional EBRD regional grouping, or `NA`.

- `eu_ebrd`:

  `1` if both an EBRD economy and an EU member, else `0` (`NA` if
  unmatched).

- `coo_group_alt`:

  Alternative EBRD grouping, or `NA`.

- `comparator_imf`:

  IMF/WEO comparator bucket, one of `"EBRD regions"` (any EBRD economy),
  `"Advanced Economies"` (non-EBRD advanced economy, e.g. Germany,
  Czechia, Greece), or `"Other EMDEs"` (every other resolved economy);
  `NA` if unmatched.

Unmatched identifiers are reported once via
[`message()`](https://rdrr.io/r/base/message.html).

## See also

[`list_ebrd()`](https://pablogguz.github.io/ebrdify/reference/list_ebrd.md)
for the full list of EBRD economies and
[`canonise()`](https://pablogguz.github.io/ebrdify/reference/canonise.md)
to standardise country names.

## Examples

``` r
# Using a data frame
df <- data.frame(country_code = c("KAZ", "HRV", "NGA", "ARM", "USA"))
ebrdify(df, "country_code", var_format = "iso3c")
#>   country_code ebrd                        coo_group eu_ebrd
#> 1          KAZ    1                     Central Asia       0
#> 2          HRV    1 Central Europe and Baltic States       1
#> 3          NGA    1               Sub-Saharan Africa       0
#> 4          ARM    1  Eastern Europe and the Caucasus       0
#> 5          USA    0                             <NA>       0
#>                    coo_group_alt     comparator_imf
#> 1 Former Soviet Union + Mongolia       EBRD regions
#> 2                        EU-EBRD       EBRD regions
#> 3             Sub-Saharan Africa       EBRD regions
#> 4 Former Soviet Union + Mongolia       EBRD regions
#> 5                           <NA> Advanced Economies

# Using a vector, with auto-detected format
ebrdify(var = c("Kazakhstan", "Croatia", "Narnia", "United States"))
#> The following entries could not be matched: Narnia
#>   ebrd                        coo_group eu_ebrd                  coo_group_alt
#> 1    1                     Central Asia       0 Former Soviet Union + Mongolia
#> 2    1 Central Europe and Baltic States       1                        EU-EBRD
#> 3   NA                             <NA>      NA                           <NA>
#> 4    0                             <NA>       0                           <NA>
#>       comparator_imf
#> 1       EBRD regions
#> 2       EBRD regions
#> 3               <NA>
#> 4 Advanced Economies
```
