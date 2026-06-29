# CLAUDE.md

`ebrdify` — an R (and Stata) package that classifies countries in a
dataset into **EBRD groupings** and standardises country names to
**official EBRD / Transition Report (TR) terminology**.

## What the package does

Given a column or vector of country identifiers (ISO3, ISO2, or country
names), the package tags each economy with its EBRD classification and
can rewrite its name to the official form used in the EBRD Transition
Report.

Public API:

- `ebrdify(data, var, var_format)` — appends classification columns:
  `ebrd` (is an EBRD country of operation), `coo_group` (traditional
  regional grouping), `eu_ebrd` (EBRD economy that is also an EU
  member), `coo_group_alt` (alternative grouping), `ebrd_shareholder`,
  and `comparator_imf` (a 3-way IMF/WEO bucket: `"EBRD regions"` /
  `"Advanced Economies"` / `"Other EMDEs"`, mutually exclusive over
  every resolved economy; built from the IMF WEO Advanced Economies list
  in `comparators.md`, `.advanced_economies_iso3`).
- `list_ebrd(what, group)` — returns the full list of EBRD economies as
  ISO3 codes, official names, or both; optionally filtered to one
  `coo_group`.
- `canonise(x, from)` — rewrites country identifiers to their official
  EBRD/TR names (e.g. Czech Republic → Czechia, Palestine → West Bank
  and Gaza, Kyrgyzstan → Kyrgyz Republic, Taiwan → Taipei China).

## Source of truth

All classification and naming data come from **Annex I of the OCE TR
style guide** (`~/Documents/GitHub/tr-style-guide`, section
`#sec-annex-i` of `oce_style_guide_v1.qmd`, plus
`groupings/comparators.md`). When that guide changes, update
[R/lookups.R](https://pablogguz.github.io/ebrdify/R/lookups.R) — it is
the single in-package source of truth from which every lookup table is
derived. Keep the Stata implementation in sync manually:
[stata/ebrdify.ado](https://pablogguz.github.io/ebrdify/stata/ebrdify.ado),
[stata/canonise.ado](https://pablogguz.github.io/ebrdify/stata/canonise.ado)
(mirrors
[`canonise()`](https://pablogguz.github.io/ebrdify/reference/canonise.md)),
and
[stata/list_ebrd.ado](https://pablogguz.github.io/ebrdify/stata/list_ebrd.ado)
(mirrors
[`list_ebrd()`](https://pablogguz.github.io/ebrdify/reference/list_ebrd.md)).
The Stata ports use the `isocodes` package for identifier→ISO3
conversion and inline `replace` lookups (no bundled `.dta`); a
cross-port parity check (R vs Stata, value-for-value) confirms
`ebrdify`/`canonise` agree on matched economies. Stata is versioned
separately (`stata/ebrdify.pkg`), not in `NEWS.md`.

### Naming rules (TR house style)

- EBRD economies use the official names in `.ebrd_economies` (Annex I,
  `tbl-ebrd-coo`). “Forbidden names” are never used: Türkiye (not
  Turkey), Kyrgyz Republic (not Kyrgyzstan), Slovak Republic (not
  Slovakia), Côte d’Ivoire (not Ivory Coast), West Bank and Gaza (not
  Palestine), Czechia (not Czech Republic).
- Some non-EBRD comparators also have required names: Taipei China (not
  Taiwan), Hong Kong SAR, Macao SAR. These live in `.tr_name_override`.
- [`canonise()`](https://pablogguz.github.io/ebrdify/reference/canonise.md)
  applies these overrides on top of `countrycode`’s English short names,
  because `countrycode` returns the *wrong* form for several of them
  (e.g. it gives “Turkey”, “Kyrgyzstan”, “Slovakia”, “Palestinian
  Territories”, “Taiwan”).

### Gotchas / must-not-break facts

- **Russia, Belarus and Cyprus are NOT EBRD economies** and must never
  appear in EBRD groupings (Russia/Belarus/Cyprus do appear in the
  shareholder list).
- **Czechia and Greece were removed as EBRD countries of operation in
  2026** (NEWS 0.4.3–0.4.4). They are no longer in any grouping, but
  Czechia/Greece remain valid comparator names and remain EBRD
  *shareholders*.
- **Kosovo**: the ISO 3166-1 alpha-3 code is `XKX`, but EBRD also uses
  `KOS`. Internally everything is normalised to `XKX` (see
  `.to_iso3c()`), so either input code classifies correctly.
- There are **41 EBRD economies**. Türkiye is its own region — not part
  of any traditional grouping.
- The shareholder list intentionally includes non-country entities
  (`EIB`, `EUU`) and non-COO shareholders; it is broader than the 41
  economies.

## Architecture

- [R/lookups.R](https://pablogguz.github.io/ebrdify/R/lookups.R) —
  internal data. The master `.ebrd_economies` data frame and the
  named-vector lookups derived from it. **Built once when the namespace
  loads, not per call** — this is the main performance lever.
- [R/utils.R](https://pablogguz.github.io/ebrdify/R/utils.R) — internal
  helpers: `.clean_input()`, `.detect_format()`, `.to_iso3c()` (shared
  format detection + ISO3 conversion).
- [R/ebrdify.R](https://pablogguz.github.io/ebrdify/R/ebrdify.R) —
  [`ebrdify()`](https://pablogguz.github.io/ebrdify/reference/ebrdify.md).
- [R/list_ebrd.R](https://pablogguz.github.io/ebrdify/R/list_ebrd.R) —
  [`list_ebrd()`](https://pablogguz.github.io/ebrdify/reference/list_ebrd.md).
- [R/canonise.R](https://pablogguz.github.io/ebrdify/R/canonise.R) —
  [`canonise()`](https://pablogguz.github.io/ebrdify/reference/canonise.md).

[`ebrdify()`](https://pablogguz.github.io/ebrdify/reference/ebrdify.md)
and
[`canonise()`](https://pablogguz.github.io/ebrdify/reference/canonise.md)
both route identifier → ISO3 through `.to_iso3c()`, which only calls
`countrycode` on the *unique* non-ISO3 values (the expensive step) and
uses O(1) named-vector lookups for everything else.

## Workflow

``` r
devtools::load_all()        # load during development
devtools::document()        # regenerate NAMESPACE + man/ after changing roxygen
devtools::test()            # run testthat suite (tests/testthat/)
devtools::check()           # full R CMD check
Rscript dev/benchmark.r     # compare against dev/ebrdify_old.R
```

- Tests live in `tests/testthat/`; `tests/testthat.R` runs
  `test_check("ebrdify")`.
- Bump `Version` in `DESCRIPTION` and add a `NEWS.md` entry for any
  classification/naming change. NEWS tracks the **R** implementation
  only.
- Non-ASCII names are written with `\u` escapes (e.g. `"Türkiye"`,
  `"Côte d'Ivoire"`) so the package stays portable and
  `R CMD check`-clean.
- `dev/`, `stata/`, `data-raw/`, `pkgdown/` are build-ignored
  (`.Rbuildignore`).
