# ebrdify 0.5.2

* Removed the `ebrd_shareholder` column from `ebrdify()`. The shareholder
  classification added little value, so `ebrdify()` now returns five
  classification columns: `ebrd`, `coo_group`, `eu_ebrd`, `coo_group_alt`, and
  `comparator_imf`.

# ebrdify 0.5.1

* `ebrdify()` now adds a `comparator_imf` column classifying every economy into
  one of three mutually exclusive IMF/WEO comparator buckets: `"EBRD regions"`
  (any EBRD economy), `"Advanced Economies"` (non-EBRD advanced economies, e.g.
  Germany, Czechia, Greece), or `"Other EMDEs"` (every other resolved economy).
  Based on the IMF WEO Advanced Economies list in the TR style guide
  (`groupings/comparators.md`).

# ebrdify 0.5.0

* New `list_ebrd()` returns the full list of EBRD economies as ISO3 codes,
  official names, or both, optionally filtered to one regional grouping;
  `list_ebrd_groups()` lists the available groupings.
* New `canonise()` rewrites country identifiers to official EBRD / Transition
  Report names (e.g. Czech Republic → Czechia, Palestine → West Bank and Gaza,
  Kyrgyzstan → Kyrgyz Republic, Taiwan → Taipei China).
* Fixed a crash in `ebrdify()` ("row names contain missing values") that
  occurred for common inputs mixing EBRD and non-EBRD countries (e.g. a vector
  like `c("KAZ", "USA")`).
* `ebrdify()` now correctly classifies Kosovo whether passed as `XKX` or `KOS`.
* Performance: classification lookup tables are now built once when the package
  loads instead of on every call, and the hot path avoids redundant work.
* Dropped the `dplyr` and `tidyr` dependencies (unused), for a lighter, faster
  install and load.
* Added a real test suite (`tests/testthat.R` was previously empty, so
  `R CMD check` ran no tests).

# ebrdify 0.4.4

* Removed Czechia from EBRD countries of operation and all regional groupings

# ebrdify 0.4.3

* Removed Greece from EBRD countries of operation and all regional groupings

# ebrdify 0.4.2

* Faster `ebrdify()` function

# ebrdify 0.4.1

* Correct GHA bug

# ebrdify 0.4.0

* Added GHA to SSA 

# ebrdify 0.3.0

* Moved IRQ to SEMED 

# ebrdify 0.2.0

* Included 5 new countries of operation 

# ebrdify 0.1.1

* Faster `ebrdify()` function, with improved handling of edge cases

# ebrdify 0.1.0

* Fix bug in `ebrdify()` that caused it to fail to recognize Kosovo as an EBRD country
* Fix error in `ebrdify()` that classified Turkiye within the SEMED region
* The `ebrdify()` function now returns two new variables:
  * `coo_group_alt` to generate an alternative classification of countries of operation
  * `ebrd_shareholder` to identify countries that are EBRD shareholders
  
# ebrdify v0.0.0.9000 

* Initial release
