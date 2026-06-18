# lookups.R
#
# Internal data: the single in-package source of truth for EBRD classification
# and naming. Everything here is derived from Annex I of the OCE TR style guide
# (oce_style_guide_v1.qmd, #sec-annex-i) and groupings/comparators.md.
#
# These objects are created ONCE when the package namespace is loaded, not on
# every ebrdify()/canonise() call. That is the main performance lever: the hot
# functions just index into pre-built named vectors.
#
# Non-ASCII names use \u escapes so the package stays portable and R CMD
# check-clean (T\u00FCrkiye -> "T\u00FCrkiye", C\u00F4te d'Ivoire -> "C\u00F4te d'Ivoire").

# Master table of the 41 EBRD economies (Annex I, tbl-ebrd-coo). Kosovo uses the
# ISO 3166-1 alpha-3 code XKX (EBRD's "KOS" is normalised to XKX in .to_iso3c()).
# Columns:
#   iso3c          ISO3 code (canonical key for every lookup)
#   name           official EBRD/TR country name
#   coo_group      traditional EBRD regional grouping (tbl-ebrd-regions)
#   coo_group_alt  alternative grouping (tbl-ebrd-unofficial)
#   eu_ebrd        TRUE if also an EU member state
.ebrd_economies <- data.frame(
  iso3c = c(
    "ALB", "ARM", "AZE", "BEN", "BIH", "BGR", "CIV", "HRV", "EGY", "EST",
    "GEO", "GHA", "HUN", "IRQ", "JOR", "KAZ", "KEN", "XKX", "KGZ", "LVA",
    "LBN", "LTU", "MKD", "MAR", "MDA", "MNG", "MNE", "NGA", "POL", "ROU",
    "SEN", "SRB", "SVK", "SVN", "TJK", "TUN", "TUR", "TKM", "UKR", "UZB",
    "PSE"
  ),
  name = c(
    "Albania", "Armenia", "Azerbaijan", "Benin", "Bosnia and Herzegovina",
    "Bulgaria", "C\u00F4te d'Ivoire", "Croatia", "Egypt", "Estonia",
    "Georgia", "Ghana", "Hungary", "Iraq", "Jordan", "Kazakhstan", "Kenya",
    "Kosovo", "Kyrgyz Republic", "Latvia", "Lebanon", "Lithuania",
    "North Macedonia", "Morocco", "Moldova", "Mongolia", "Montenegro",
    "Nigeria", "Poland", "Romania", "Senegal", "Serbia", "Slovak Republic",
    "Slovenia", "Tajikistan", "Tunisia", "T\u00FCrkiye", "Turkmenistan",
    "Ukraine", "Uzbekistan", "West Bank and Gaza"
  ),
  coo_group = c(
    "South-eastern Europe", "Eastern Europe and the Caucasus",
    "Eastern Europe and the Caucasus", "Sub-Saharan Africa",
    "South-eastern Europe", "South-eastern Europe", "Sub-Saharan Africa",
    "Central Europe and Baltic States", "Southern and Eastern Mediterranean",
    "Central Europe and Baltic States", "Eastern Europe and the Caucasus",
    "Sub-Saharan Africa", "Central Europe and Baltic States",
    "Southern and Eastern Mediterranean", "Southern and Eastern Mediterranean",
    "Central Asia", "Sub-Saharan Africa", "South-eastern Europe",
    "Central Asia", "Central Europe and Baltic States",
    "Southern and Eastern Mediterranean", "Central Europe and Baltic States",
    "South-eastern Europe", "Southern and Eastern Mediterranean",
    "Eastern Europe and the Caucasus", "Central Asia", "South-eastern Europe",
    "Sub-Saharan Africa", "Central Europe and Baltic States",
    "South-eastern Europe", "Sub-Saharan Africa", "South-eastern Europe",
    "Central Europe and Baltic States", "Central Europe and Baltic States",
    "Central Asia", "Southern and Eastern Mediterranean", "T\u00FCrkiye",
    "Central Asia", "Eastern Europe and the Caucasus", "Central Asia",
    "Southern and Eastern Mediterranean"
  ),
  coo_group_alt = c(
    "Western Balkans", "Former Soviet Union + Mongolia",
    "Former Soviet Union + Mongolia", "Sub-Saharan Africa", "Western Balkans",
    "EU-EBRD", "Sub-Saharan Africa", "EU-EBRD", "SEMED", "EU-EBRD",
    "Former Soviet Union + Mongolia", "Sub-Saharan Africa", "EU-EBRD", "SEMED",
    "SEMED", "Former Soviet Union + Mongolia", "Sub-Saharan Africa",
    "Western Balkans", "Former Soviet Union + Mongolia", "EU-EBRD", "SEMED",
    "EU-EBRD", "Western Balkans", "SEMED", "Former Soviet Union + Mongolia",
    "Former Soviet Union + Mongolia", "Western Balkans", "Sub-Saharan Africa",
    "EU-EBRD", "EU-EBRD", "Sub-Saharan Africa", "Western Balkans", "EU-EBRD",
    "EU-EBRD", "Former Soviet Union + Mongolia", "SEMED", "T\u00FCrkiye",
    "Former Soviet Union + Mongolia", "Former Soviet Union + Mongolia",
    "Former Soviet Union + Mongolia", "SEMED"
  ),
  eu_ebrd = c(
    FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE,
    FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,
    FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE,
    FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
    FALSE
  ),
  stringsAsFactors = FALSE
)

# Named-vector lookups derived once from the master table. Keyed by ISO3 for
# O(1) indexing in the hot path. Logical lookups return TRUE / NA (used as
# !is.na(.)); character lookups return the grouping/name or NA for non-members.
.ebrd_lookup   <- stats::setNames(rep(TRUE, nrow(.ebrd_economies)), .ebrd_economies$iso3c)
.region_lookup <- stats::setNames(.ebrd_economies$coo_group, .ebrd_economies$iso3c)
.alt_lookup    <- stats::setNames(.ebrd_economies$coo_group_alt, .ebrd_economies$iso3c)
.name_lookup   <- stats::setNames(.ebrd_economies$name, .ebrd_economies$iso3c)
.eu_lookup     <- stats::setNames(
  rep(TRUE, sum(.ebrd_economies$eu_ebrd)),
  .ebrd_economies$iso3c[.ebrd_economies$eu_ebrd]
)

# EBRD shareholders (ISO3). Broader than the 41 economies: includes non-COO
# shareholders (e.g. Russia, Belarus, Cyprus, Czechia, Greece) and non-country
# institutional members (EIB = European Investment Bank, EUU = European Union).
.shareholder_iso3c <- c(
  "ALB", "DZA", "ARM", "AUS", "AUT", "AZE", "BLR", "BEL", "BIH", "BGR",
  "CAN", "CHN", "HRV", "CYP", "CZE", "DNK", "EGY", "EST", "EIB", "EUU",
  "FIN", "FRA", "GEO", "DEU", "GRC", "HUN", "ISL", "IND", "IRL", "ISR",
  "ITA", "JPN", "JOR", "KAZ", "KOR", "XKX", "KGZ", "LVA", "LBN", "LBY",
  "LIE", "LTU", "LUX", "MLT", "MEX", "MDA", "MNG", "MNE", "MAR", "NLD",
  "NZL", "MKD", "NOR", "POL", "PRT", "ROU", "RUS", "SMR", "SRB", "SVK",
  "SVN", "ESP", "SWE", "CHE", "TJK", "TUN", "TUR", "TKM", "UKR", "ARE",
  "GBR", "USA", "UZB", "NGA", "BEN", "CIV", "KEN", "SEN", "IRQ", "GHA"
)
.shareholder_lookup <- stats::setNames(
  rep(TRUE, length(.shareholder_iso3c)), .shareholder_iso3c
)

# Name overrides for canonise(): the 41 EBRD official names, plus non-EBRD
# comparators whose TR-required name differs from countrycode's English short
# name (countrycode gives "Taiwan", "Hong Kong SAR China", "Macao SAR China").
# CZE is listed explicitly even though countrycode already returns "Czechia".
.tr_name_override <- c(
  .name_lookup,
  TWN = "Taipei China",
  HKG = "Hong Kong SAR",
  MAC = "Macao SAR",
  CZE = "Czechia"
)

# Custom country -> XKX matches passed to countrycode() (origin values that its
# built-in dictionaries miss). "KOS" is also normalised to XKX directly in
# .to_iso3c() for ISO3 input, which never reaches countrycode().
.kosovo_match <- c(
  "Kosovo" = "XKX", "KOSOVO" = "XKX", "Republic of Kosovo" = "XKX",
  "XK" = "XKX", "KOS" = "XKX"
)
