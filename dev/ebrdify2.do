cap program drop list_to_regex
program list_to_regex
    args list
    mata: st_local("regex", "^(" + invtokens(tokens(st_local("list")), "|") + ")$")
    c_local regex "`regex'"
end

cap program drop ebrdify2
program define ebrdify2
    syntax varlist(string) [if]

    * Ensure we only have one variable in the varlist
    if `:word count `varlist'' != 1 {
        di as error "You must specify exactly one string variable."
        exit 198
    }
    
    * Ensure variables do not exist
    foreach var in ebrd coo_group eu_ebrd coo_group_alt {
        capture confirm variable `var'
        if (!_rc) {
            di as error "Column '`var'' already in the dataset. Replacing..."
            cap drop `var'
        }
    }
        
    * Capture the input variable name
    local input_var `varlist'
    
    * Convert to ISO3C
    if "`input_var'" != "iso3c" {
        capture confirm variable iso3c
        if (!_rc) {
            rename iso3c iso3c_original
            capture isocodes `input_var', gen(iso3c)
            qui replace iso3c = "XKX" if `input_var' == "Kosovo"
            
            if (_rc) {
                di as error "The isocodes package is not installed or encountered an error."
                di as error "Please install the isocodes package using: net install isocodes, from(""https://raw.githubusercontent.com/leojahrens/isocodes/master"") replace"
                exit 198
            }
            drop iso3c_original
        } 
        else {
            capture isocodes `input_var', gen(iso3c)
            qui replace iso3c = "XKX" if `input_var' == "Kosovo"
            
            if (_rc) {
                di as error "The isocodes package is not installed or encountered an error."
                di as error "Please install the isocodes package using: net install isocodes, from(""https://raw.githubusercontent.com/leojahrens/isocodes/master"") replace"
                exit 198
            }
        }
    }

    qui {
        * Create all variables at once
        gen ebrd = 0 `if'
        gen coo_group = . `if'
        gen eu_ebrd = 0 `if'
        gen coo_group_alt = . `if'
        
        * EBRD countries
        list_to_regex "KAZ KGZ MNG TJK TKM UZB HRV CZE EST HUN LVA LTU POL SVK SVN GRC ARM AZE GEO MDA UKR ALB BIH BGR XKX MNE MKD ROU SRB EGY JOR LBN MAR TUN PSE TUR"
        replace ebrd = 1 if ustrregexm(iso3c, "`regex'") `if'
        
        * Regional groupings
        * Central Asia
        list_to_regex "KAZ KGZ MNG TJK TKM UZB"
        replace coo_group = 1 if ustrregexm(iso3c, "`regex'") `if'
        
        * Central Europe and Baltic States
        list_to_regex "HRV CZE EST HUN LVA LTU POL SVK SVN"
        replace coo_group = 2 if ustrregexm(iso3c, "`regex'") `if'
        
        * Greece
        replace coo_group = 3 if iso3c == "GRC" `if'
        
        * Eastern Europe and the Caucasus
        list_to_regex "ARM AZE GEO MDA UKR"
        replace coo_group = 4 if ustrregexm(iso3c, "`regex'") `if'
        
        * South-eastern Europe
        list_to_regex "ALB BIH BGR XKX MNE MKD ROU SRB"
        replace coo_group = 5 if ustrregexm(iso3c, "`regex'") `if'
        
        * Southern and Eastern Mediterranean
        list_to_regex "EGY JOR LBN MAR TUN PSE"
        replace coo_group = 6 if ustrregexm(iso3c, "`regex'") `if'
        
        * Türkiye
        replace coo_group = 7 if iso3c == "TUR" `if'
        
        * EU members
        list_to_regex "HRV CZE EST HUN LVA LTU POL SVK SVN GRC BGR ROU"
        replace eu_ebrd = 1 if ustrregexm(iso3c, "`regex'") `if'
        
        * Alternative groupings
        * EU-EBRD (use existing eu_ebrd variable)
        replace coo_group_alt = 1 if eu_ebrd == 1 `if'
        
        * Former Soviet Union + Mongolia
        list_to_regex "ARM AZE GEO KAZ KGZ MDA MNG TJK TKM UZB UKR"
        replace coo_group_alt = 2 if ustrregexm(iso3c, "`regex'") `if'
        
        * Western Balkans
        list_to_regex "ALB BIH XKX MNE MKD SRB"
        replace coo_group_alt = 3 if ustrregexm(iso3c, "`regex'") `if'
        
        * SEMED
        list_to_regex "EGY JOR LBN MAR TUN PSE"
        replace coo_group_alt = 4 if ustrregexm(iso3c, "`regex'") `if'
        
        * Türkiye
        replace coo_group_alt = 5 if iso3c == "TUR" `if'
    }
    
    * Labels
    label define coo_group 1 "Central Asia" 2 "Central Europe and Baltic States" 3 "Greece" ///
                          4 "Eastern Europe and the Caucasus" 5 "South-eastern Europe" ///
                          6 "Southern and Eastern Mediterranean" 7 "Türkiye"
    label values coo_group coo_group

    label define coo_group_alt 1 "EBRD EU" 2 "Former Soviet Union + Mongolia" ///
                              3 "Western Balkans" 4 "Southern and Eastern Mediterranean" ///
                              5 "Turkiye"
    label values coo_group_alt coo_group_alt

    * Print unmatched entries
    qui levelsof iso3c if missing(ebrd), local(unmatched)
    if "`unmatched'" != "" {
        di as error "Unmatched entries: `unmatched'"
    }
end