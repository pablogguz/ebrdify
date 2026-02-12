# EBRD Country Classification

This function classifies countries based on their EBRD status, region,
and EU membership.

## Usage

``` r
ebrdify(data = NULL, var, var_format = NULL)
```

## Arguments

- data:

  A data frame containing the variable to classify, or NULL if using a
  vector input.

- var:

  A string specifying the name of the variable in `data` that contains
  the country codes, or a vector of country codes.

- var_format:

  A string specifying the format of the country codes in `var`. It can
  be "country.name", "iso3c", or "iso2c". If NULL, the function will
  attempt to detect the format.

## Value

A data frame with four new variables: `ebrd`, `coo_group`, `eu_ebrd`,
and `coo_group_alt`, and prints out any unmatched entries.

- `ebrd`: A binary variable indicating whether the country is an EBRD
  country of operation (1 = EBRD COO, 0 = Non-COO).

- `coo_group`: A variable classifying the country into specific EBRD
  country groupings.

- `eu_ebrd`: A binary variable indicating whether the country is both an
  EBRD country of operation and an EU member (1 = EU & EBRD, 0 =
  otherwise).

- `coo_group_alt`: An alternative classification of countries into
  broader categories

- `ebrd_shareholder`: A binary variable indicating whether the country
  is an EBRD shareholder (1 = Shareholder, 0 = Non-Shareholder).

## Examples

``` r
# Using a data frame
data <- data.frame(country_code = c("KAZ", "CZE", "NGA", "ARM", "ALB", "EGY", "USA", "CAN"))
ebrdified_data <- ebrdify(data, "country_code", var_format = "iso3c")
print(ebrdified_data)
#>   country_code ebrd                          coo_group eu_ebrd
#> 1          KAZ    1                       Central Asia       0
#> 2          CZE    1   Central Europe and Baltic States       1
#> 3          NGA    1                 Sub-Saharan Africa       0
#> 4          ARM    1    Eastern Europe and the Caucasus       0
#> 5          ALB    1               South-eastern Europe       0
#> 6          EGY    1 Southern and Eastern Mediterranean       0
#> 7          USA    0                               <NA>       0
#> 8          CAN    0                               <NA>       0
#>                    coo_group_alt ebrd_shareholder
#> 1 Former Soviet Union + Mongolia                1
#> 2                        EU-EBRD                1
#> 3             Sub-Saharan Africa                1
#> 4 Former Soviet Union + Mongolia                1
#> 5                Western Balkans                1
#> 6                          SEMED                1
#> 7                           <NA>                1
#> 8                           <NA>                1

# Using a vector
country_vector <- c("KAZ", "CZE", "NGA", "ARM", "ALB", "EGY", "USA", "CAN")
ebrdified_vector <- ebrdify(var = country_vector, var_format = "iso3c")
print(ebrdified_vector)
#>   ebrd                          coo_group eu_ebrd
#> 1    1                       Central Asia       0
#> 2    1   Central Europe and Baltic States       1
#> 3    1                 Sub-Saharan Africa       0
#> 4    1    Eastern Europe and the Caucasus       0
#> 5    1               South-eastern Europe       0
#> 6    1 Southern and Eastern Mediterranean       0
#> 7    0                               <NA>       0
#> 8    0                               <NA>       0
#>                    coo_group_alt ebrd_shareholder
#> 1 Former Soviet Union + Mongolia                1
#> 2                        EU-EBRD                1
#> 3             Sub-Saharan Africa                1
#> 4 Former Soviet Union + Mongolia                1
#> 5                Western Balkans                1
#> 6                          SEMED                1
#> 7                           <NA>                1
#> 8                           <NA>                1

# Using a data frame with fake country names
data_fake_names <- data.frame(country_name = c("Kazakhstan",
                                               "Czechia",
                                               "Narnia",
                                               "Armenia",
                                               "Albania",
                                               "Wakanda",
                                               "Kosovo",
                                               "United States",
                                               "Canada"))
ebrdified_data_fake_names <- ebrdify(data_fake_names, "country_name")
#> Warning: Some values were not matched unambiguously: Narnia, Wakanda
#> The following entries could not be matched: Narnia, Wakanda
print(ebrdified_data_fake_names)
#>                country_name ebrd                        coo_group eu_ebrd
#> Kazakhstan       Kazakhstan    1                     Central Asia       0
#> Czechia             Czechia    1 Central Europe and Baltic States       1
#> Narnia               Narnia   NA                             <NA>      NA
#> Armenia             Armenia    1  Eastern Europe and the Caucasus       0
#> Albania             Albania    1             South-eastern Europe       0
#> Wakanda             Wakanda   NA                             <NA>      NA
#> Kosovo               Kosovo    1             South-eastern Europe       0
#> United States United States    0                             <NA>       0
#> Canada               Canada    0                             <NA>       0
#>                                coo_group_alt ebrd_shareholder
#> Kazakhstan    Former Soviet Union + Mongolia                1
#> Czechia                              EU-EBRD                1
#> Narnia                                  <NA>               NA
#> Armenia       Former Soviet Union + Mongolia                1
#> Albania                      Western Balkans                1
#> Wakanda                                 <NA>               NA
#> Kosovo                       Western Balkans                1
#> United States                           <NA>                1
#> Canada                                  <NA>                1
```
