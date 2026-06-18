# Canonise country names to official EBRD terminology

Rewrites country identifiers (names, ISO3 or ISO2 codes) to the official
country names used in the EBRD Transition Report. This enforces the TR
house style and the "forbidden names" rules from Annex I of the style
guide — for example:

## Usage

``` r
canonise(x, from = NULL, warn = TRUE)
```

## Arguments

- x:

  A vector of country identifiers (names, ISO3, or ISO2 codes).

- from:

  Format of `x`: `"country.name"`, `"iso3c"`, or `"iso2c"`. If `NULL`
  (default) the format is auto-detected.

- warn:

  If `TRUE` (default), report identifiers that could not be matched via
  [`message()`](https://rdrr.io/r/base/message.html).

## Value

A character vector the same length as `x` of official EBRD/TR names,
with `NA` for identifiers that could not be matched. Designed to drop
into `dplyr::mutate()`, e.g. `mutate(country = canonise(country))`.

## Details

- Czech Republic \\\rightarrow\\ Czechia

- Palestine \\\rightarrow\\ West Bank and Gaza

- Kyrgyzstan \\\rightarrow\\ Kyrgyz Republic

- Slovakia \\\rightarrow\\ Slovak Republic

- Turkey \\\rightarrow\\ Türkiye

- Ivory Coast \\\rightarrow\\ Côte d'Ivoire

- Taiwan \\\rightarrow\\ Taipei China

EBRD economies are named from the official Annex I list; other economies
fall back to `countrycode`'s English short name, with TR-specific
overrides applied on top (Taipei China, Hong Kong SAR, Macao SAR,
Czechia) because `countrycode` returns a non-TR form for those.

## See also

[`ebrdify()`](https://pablogguz.github.io/ebrdify/reference/ebrdify.md)
to classify economies and
[`list_ebrd()`](https://pablogguz.github.io/ebrdify/reference/list_ebrd.md)
for the full list of EBRD economies.

## Examples

``` r
canonise(c("Czech Republic", "Palestine", "Kyrgyzstan", "Taiwan"))
#> [1] "Czechia"            "West Bank and Gaza" "Kyrgyz Republic"   
#> [4] "Taipei China"      
canonise(c("TUR", "SVK", "CIV"), from = "iso3c")
#> [1] "Türkiye"         "Slovak Republic" "Côte d'Ivoire"  
canonise(c("Germany", "Wakanda"))   # non-EBRD pass through; unmatched -> NA
#> The following entries could not be matched: Wakanda
#> [1] "Germany" NA       
```
