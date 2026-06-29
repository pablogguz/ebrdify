*! version 1.0.0 2026-06-29
cap program drop canonise
program define canonise
    syntax varname(string) [, GENerate(name)]

    * Name of the variable to create (default: ebrd_name)
    local invar `varlist'
    if "`generate'" == "" local generate ebrd_name

    capture confirm new variable `generate'
    if _rc {
        di as text "Variable '`generate'' already exists. Replacing..."
        drop `generate'
    }

    * Work off a copy of the input so its column name can never collide with the
    * iso3c / cntryname variables that isocodes is forced to create.
    tempvar src
    quietly gen `src' = `invar'

    * Protect any user columns literally named iso3c / cntryname.
    tempvar hold_iso hold_name
    local have_iso 0
    local have_name 0
    capture confirm variable iso3c
    if !_rc {
        rename iso3c `hold_iso'
        local have_iso 1
    }
    capture confirm variable cntryname
    if !_rc {
        rename cntryname `hold_name'
        local have_name 1
    }

    * Resolve the input to ISO3 and to a standard English country name.
    capture isocodes `src', gen(iso3c)
    if _rc {
        di as error "The isocodes package is required. Install it with:"
        di as error `"  net install isocodes, from("https://raw.githubusercontent.com/leojahrens/isocodes/master") replace"'
        capture drop iso3c
        if `have_iso'  rename `hold_iso' iso3c
        if `have_name' rename `hold_name' cntryname
        exit 198
    }
    quietly isocodes `src', gen(cntryname)

    * Kosovo has no ISO3 in isocodes; map its common aliases to canonical XKX.
    quietly replace iso3c = "XKX" if inlist(`src', "Kosovo", "KOS", "XKX", "XK", "Republic of Kosovo")

    * Base name = isocodes standard name, then overlay the official EBRD / TR
    * spellings (the only cases where isocodes differs from house style).
    quietly gen `generate' = cntryname
    quietly replace `generate' = "Czechia"            if iso3c == "CZE"
    quietly replace `generate' = "Hong Kong SAR"      if iso3c == "HKG"
    quietly replace `generate' = "Kyrgyz Republic"    if iso3c == "KGZ"
    quietly replace `generate' = "Macao SAR"          if iso3c == "MAC"
    quietly replace `generate' = "West Bank and Gaza" if iso3c == "PSE"
    quietly replace `generate' = "Slovak Republic"    if iso3c == "SVK"
    quietly replace `generate' = "Türkiye"            if iso3c == "TUR"
    quietly replace `generate' = "Taipei China"       if iso3c == "TWN"
    quietly replace `generate' = "Kosovo"             if iso3c == "XKX"

    quietly count if `generate' == "" & !missing(`src')
    if r(N) > 0 {
        di as text "Note: `r(N)' value(s) could not be matched and are left blank."
    }

    * Restore protected variables.
    drop iso3c cntryname
    if `have_iso'  rename `hold_iso' iso3c
    if `have_name' rename `hold_name' cntryname
end
