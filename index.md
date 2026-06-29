# ebrdify

A handy function to classify EBRD countries of operation

# R

``` r

# install.packages("pak")
pak::pak("pablogguz/ebrdify")
```

## Usage

``` r

library(ebrdify)

# Classify the countries in your data into EBRD groupings.
# Accepts ISO3, ISO2 or country names (format auto-detected if not given).
# Adds: ebrd, coo_group, eu_ebrd, coo_group_alt, comparator_imf
# (comparator_imf = "EBRD regions" / "Advanced Economies" / "Other EMDEs").
df <- data.frame(country = c("Kazakhstan", "Poland", "Germany", "Nigeria"))
ebrdify(df, "country")
#>      country ebrd                        coo_group eu_ebrd ...

# Get the full list of EBRD economies (ISO3 codes, official names, or both).
list_ebrd()                            # data frame of all 41 economies
list_ebrd("iso3c")                     # just the ISO3 codes
list_ebrd("name", group = "Central Asia")

# Rewrite country names to their official EBRD spelling.
canonise(c("Czech Republic", "Palestine", "Kyrgyzstan", "Taiwan"))
#> "Czechia" "West Bank and Gaza" "Kyrgyz Republic" "Taipei China"
```

Country names and groupings follow the official EBRD classification.

# Stata

    net install ebrdify, from(https://raw.githubusercontent.com/pablogguz/ebrdify/master/stata) replace

> ⚠️ **Warning:** The changelog and version history in this repository
> only track changes to the R implementation. For Stata version updates,
> please check the Stata folder directly.
