*! version 1.0.0 2026-06-29
cap program drop list_ebrd
program define list_ebrd, rclass
    syntax [, GROUP(string) CLEAR]

    * Loading the list replaces the data in memory, so require an explicit clear.
    if _N > 0 & "`clear'" == "" {
        di as error "no; data in memory would be lost"
        di as text "    specify the {bf:clear} option to load the EBRD economies"
        exit 4
    }

    * ISO3 codes of the 41 EBRD economies (Kosovo = XKX).
    local codes "ALB ARM AZE BEN BIH BGR CIV HRV EGY EST GEO GHA HUN IRQ JOR KAZ KEN XKX KGZ LVA LBN LTU MKD MAR MDA MNG MNE NGA POL ROU SEN SRB SVK SVN TJK TUN TUR TKM UKR UZB PSE"

    clear
    local n : word count `codes'
    quietly set obs `n'
    gen str4 iso3c = ""
    local i = 1
    foreach c of local codes {
        quietly replace iso3c = "`c'" in `i'
        local ++i
    }

    * Official EBRD names.
    gen str30 name = ""
    quietly replace name = "Albania"                if iso3c == "ALB"
    quietly replace name = "Armenia"                if iso3c == "ARM"
    quietly replace name = "Azerbaijan"             if iso3c == "AZE"
    quietly replace name = "Benin"                  if iso3c == "BEN"
    quietly replace name = "Bosnia and Herzegovina" if iso3c == "BIH"
    quietly replace name = "Bulgaria"               if iso3c == "BGR"
    quietly replace name = "Côte d'Ivoire"          if iso3c == "CIV"
    quietly replace name = "Croatia"                if iso3c == "HRV"
    quietly replace name = "Egypt"                  if iso3c == "EGY"
    quietly replace name = "Estonia"                if iso3c == "EST"
    quietly replace name = "Georgia"                if iso3c == "GEO"
    quietly replace name = "Ghana"                  if iso3c == "GHA"
    quietly replace name = "Hungary"                if iso3c == "HUN"
    quietly replace name = "Iraq"                   if iso3c == "IRQ"
    quietly replace name = "Jordan"                 if iso3c == "JOR"
    quietly replace name = "Kazakhstan"             if iso3c == "KAZ"
    quietly replace name = "Kenya"                  if iso3c == "KEN"
    quietly replace name = "Kosovo"                 if iso3c == "XKX"
    quietly replace name = "Kyrgyz Republic"        if iso3c == "KGZ"
    quietly replace name = "Latvia"                 if iso3c == "LVA"
    quietly replace name = "Lebanon"                if iso3c == "LBN"
    quietly replace name = "Lithuania"              if iso3c == "LTU"
    quietly replace name = "North Macedonia"        if iso3c == "MKD"
    quietly replace name = "Morocco"                if iso3c == "MAR"
    quietly replace name = "Moldova"                if iso3c == "MDA"
    quietly replace name = "Mongolia"               if iso3c == "MNG"
    quietly replace name = "Montenegro"             if iso3c == "MNE"
    quietly replace name = "Nigeria"                if iso3c == "NGA"
    quietly replace name = "Poland"                 if iso3c == "POL"
    quietly replace name = "Romania"                if iso3c == "ROU"
    quietly replace name = "Senegal"                if iso3c == "SEN"
    quietly replace name = "Serbia"                 if iso3c == "SRB"
    quietly replace name = "Slovak Republic"        if iso3c == "SVK"
    quietly replace name = "Slovenia"               if iso3c == "SVN"
    quietly replace name = "Tajikistan"             if iso3c == "TJK"
    quietly replace name = "Tunisia"                if iso3c == "TUN"
    quietly replace name = "Türkiye"                if iso3c == "TUR"
    quietly replace name = "Turkmenistan"           if iso3c == "TKM"
    quietly replace name = "Ukraine"                if iso3c == "UKR"
    quietly replace name = "Uzbekistan"             if iso3c == "UZB"
    quietly replace name = "West Bank and Gaza"     if iso3c == "PSE"

    * Traditional EBRD regional groupings.
    gen str40 coo_group = ""
    quietly replace coo_group = "Central Asia" if inlist(iso3c, "KAZ", "KGZ", "MNG", "TJK", "TKM", "UZB")
    quietly replace coo_group = "Central Europe and Baltic States" if inlist(iso3c, "HRV", "EST", "HUN", "LVA", "LTU", "POL", "SVK", "SVN")
    quietly replace coo_group = "Eastern Europe and the Caucasus" if inlist(iso3c, "ARM", "AZE", "GEO", "MDA", "UKR")
    quietly replace coo_group = "South-eastern Europe" if inlist(iso3c, "ALB", "BIH", "BGR", "XKX", "MNE", "MKD", "ROU", "SRB")
    quietly replace coo_group = "Southern and Eastern Mediterranean" if inlist(iso3c, "EGY", "IRQ", "JOR", "LBN", "MAR", "TUN", "PSE")
    quietly replace coo_group = "Sub-Saharan Africa" if inlist(iso3c, "BEN", "CIV", "GHA", "KEN", "NGA", "SEN")
    quietly replace coo_group = "Türkiye" if iso3c == "TUR"

    * Optional filter to one traditional regional grouping.
    if "`group'" != "" {
        quietly levelsof coo_group, local(valid_groups)
        local ok 0
        foreach g of local valid_groups {
            if "`g'" == "`group'" local ok 1
        }
        if !`ok' {
            di as error "group() must be one of the traditional EBRD groupings:"
            foreach g of local valid_groups {
                di as text "    `g'"
            }
            exit 198
        }
        quietly keep if coo_group == "`group'"
    }

    sort iso3c
    quietly levelsof iso3c, local(loaded) clean
    return local iso3 "`loaded'"
    return scalar N = _N

    di as text _n "`=_N' EBRD economies loaded (variables: iso3c, name, coo_group)"
end
