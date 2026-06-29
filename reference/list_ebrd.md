# List EBRD economies

Returns the full list of the 41 EBRD economies — their ISO3 codes, their
official EBRD names, or both — optionally restricted to a single
traditional regional grouping.

## Usage

``` r
list_ebrd(what = c("both", "iso3c", "name"), group = NULL)
```

## Arguments

- what:

  What to return: `"both"` (default) a data frame with `iso3c` and
  `name` columns; `"iso3c"` a character vector of ISO3 codes; `"name"` a
  character vector of official names.

- group:

  Optional. One traditional `coo_group` to filter to, e.g.
  `"Central Asia"`. `NULL` (default) returns all economies. See
  [`list_ebrd_groups()`](https://pablogguz.github.io/ebrdify/reference/list_ebrd_groups.md)
  for the valid values.

## Value

A data frame (`what = "both"`) or character vector, ordered
alphabetically by official name (or by code for `what = "iso3c"`).

## See also

[`ebrdify()`](https://pablogguz.github.io/ebrdify/reference/ebrdify.md)
to classify a dataset and
[`canonise()`](https://pablogguz.github.io/ebrdify/reference/canonise.md)
to standardise country names.

## Examples

``` r
list_ebrd()                       # data frame of all 41 economies
#>    iso3c                   name
#> 1    ALB                Albania
#> 2    ARM                Armenia
#> 3    AZE             Azerbaijan
#> 4    BEN                  Benin
#> 5    BIH Bosnia and Herzegovina
#> 6    BGR               Bulgaria
#> 7    HRV                Croatia
#> 8    CIV          Côte d'Ivoire
#> 9    EGY                  Egypt
#> 10   EST                Estonia
#> 11   GEO                Georgia
#> 12   GHA                  Ghana
#> 13   HUN                Hungary
#> 14   IRQ                   Iraq
#> 15   JOR                 Jordan
#> 16   KAZ             Kazakhstan
#> 17   KEN                  Kenya
#> 18   XKX                 Kosovo
#> 19   KGZ        Kyrgyz Republic
#> 20   LVA                 Latvia
#> 21   LBN                Lebanon
#> 22   LTU              Lithuania
#> 23   MDA                Moldova
#> 24   MNG               Mongolia
#> 25   MNE             Montenegro
#> 26   MAR                Morocco
#> 27   NGA                Nigeria
#> 28   MKD        North Macedonia
#> 29   POL                 Poland
#> 30   ROU                Romania
#> 31   SEN                Senegal
#> 32   SRB                 Serbia
#> 33   SVK        Slovak Republic
#> 34   SVN               Slovenia
#> 35   TJK             Tajikistan
#> 36   TUN                Tunisia
#> 37   TKM           Turkmenistan
#> 38   TUR                Türkiye
#> 39   UKR                Ukraine
#> 40   UZB             Uzbekistan
#> 41   PSE     West Bank and Gaza
list_ebrd("iso3c")                # just the ISO3 codes
#>  [1] "ALB" "ARM" "AZE" "BEN" "BGR" "BIH" "CIV" "EGY" "EST" "GEO" "GHA" "HRV"
#> [13] "HUN" "IRQ" "JOR" "KAZ" "KEN" "KGZ" "LBN" "LTU" "LVA" "MAR" "MDA" "MKD"
#> [25] "MNE" "MNG" "NGA" "POL" "PSE" "ROU" "SEN" "SRB" "SVK" "SVN" "TJK" "TKM"
#> [37] "TUN" "TUR" "UKR" "UZB" "XKX"
list_ebrd("name", group = "Central Asia")
#> [1] "Kazakhstan"      "Kyrgyz Republic" "Mongolia"        "Tajikistan"     
#> [5] "Turkmenistan"    "Uzbekistan"     
```
