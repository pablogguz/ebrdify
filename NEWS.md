# ebrdify 0.5.2

* Dropped the `ebrd_shareholder` column. `ebrdify()` now returns `ebrd`,
  `coo_group`, `eu_ebrd`, `coo_group_alt` and `comparator_imf`.

# ebrdify 0.5.1

* `ebrdify()` gained a `comparator_imf` column. It tags each economy as an
  `"EBRD regions"`, an `"Advanced Economies"`, or an `"Other EMDEs"`, using the
  IMF World Economic Outlook split between advanced and emerging economies.

# ebrdify 0.5.0

* New `list_ebrd()` returns the full list of EBRD economies — ISO3 codes,
  official names, or both — and can be filtered to one regional grouping.
* New `canonise()` rewrites country names to their official EBRD spelling
  (Czech Republic → Czechia, Palestine → West Bank and Gaza, Kyrgyzstan →
  Kyrgyz Republic, Taiwan → Taipei China).
* Fixed a crash when classifying a mix of EBRD and non-EBRD countries.
* Kosovo is now recognised whether passed as `XKX` or `KOS`.
* Faster, with `dplyr` and `tidyr` no longer required.

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
