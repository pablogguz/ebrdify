cap program drop ebrdify
program define ebrdify
    syntax varlist(string) [if]

    * Ensure we only have one variable in the varlist
    if `:word count `varlist'' != 1 {
        di as error "You must specify exactly one string variable."
        exit 198
    }
    
	* Ensure variables do not exist
        foreach var in ebrd coo_group eu_ebrd coo_group_alt ebrd_shareholder comparator_imf {
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
			replace iso3c = "XKX" if `input_var' == "Kosovo"
			
			if (_rc) {
				di as error "The isocodes package is not installed or encountered an error."
				di as error "Please install the isocodes package using: net install isocodes, from(""https://raw.githubusercontent.com/leojahrens/isocodes/master"") replace"
				exit 198
			}
			drop iso3c_original
		} 
		else {
			capture isocodes `input_var', gen(iso3c)
			replace iso3c = "XKX" if `input_var' == "Kosovo"
			
			if (_rc) {
				di as error "The isocodes package is not installed or encountered an error."
				di as error "Please install the isocodes package using: net install isocodes, from(""https://raw.githubusercontent.com/leojahrens/isocodes/master"") replace"
				exit 198
			}
		}
	}

    * Create the ebrd dummy variable
    generate ebrd = 0 `if'

    * Define the list of EBRD countries in iso3c format
    local ebrd_countries "KAZ KGZ MNG TJK TKM UZB HRV EST HUN LVA LTU POL SVK SVN ARM AZE GEO MDA UKR ALB BIH BGR XKX MNE MKD ROU SRB EGY JOR LBN MAR TUN PSE TUR NGA BEN CIV KEN SEN IRQ GHA"

    * Set ebrd to 1 for EBRD countries
    foreach country in `ebrd_countries' {
        replace ebrd = 1 if iso3c == "`country'" `if'
    }

    * Create the coo_group categorical variable
    generate coo_group = . `if'

    * Define groups of countries
    local central_asia "KAZ KGZ MNG TJK TKM UZB"
    local central_europe_baltic "HRV EST HUN LVA LTU POL SVK SVN"
    local eastern_europe_caucasus "ARM AZE GEO MDA UKR"
    local south_eastern_europe "ALB BIH BGR XKX MNE MKD ROU SRB"
    local southern_eastern_mediterranean "EGY JOR LBN MAR TUN PSE IRQ"
    local turkiye "TUR"
    local ssai "NGA BEN CIV KEN SEN GHA"

    * Assign group codes
    foreach country in `central_asia' {
        replace coo_group = 1 if iso3c == "`country'" `if'
    }
    foreach country in `central_europe_baltic' {
        replace coo_group = 2 if iso3c == "`country'" `if'
    }
    foreach country in `eastern_europe_caucasus' {
        replace coo_group = 3 if iso3c == "`country'" `if'
    }
    foreach country in `south_eastern_europe' {
        replace coo_group = 4 if iso3c == "`country'" `if'
    }
    foreach country in `southern_eastern_mediterranean' {
        replace coo_group = 5 if iso3c == "`country'" `if'
    }
    foreach country in `turkiye' {
        replace coo_group = 6 if iso3c == "`country'" `if'
    }
    foreach country in `ssai' {
        replace coo_group = 7 if iso3c == "`country'" `if'
    }
   
    * Label the coo_group variable
    label define coo_group 1 "Central Asia" 2 "Central Europe and Baltic States" 3 "Eastern Europe and the Caucasus" 4 "South-eastern Europe" 5 "Southern and Eastern Mediterranean" 6 "Türkiye" 7 "Sub-Saharan Africa"
    label values coo_group coo_group

    * Create the eu_ebrd variable
    generate eu_ebrd = 0 `if'
    
    * Define the list of EBRD countries that are also EU members
    local eu_members "HRV EST HUN LVA LTU POL SVK SVN BGR ROU"
    
    * Set eu_ebrd to 1 for EBRD countries that are also EU members
    foreach country in `eu_members' {
        replace eu_ebrd = 1 if iso3c == "`country'" `if'
    }
 
    * Create the coo_group_alt variable
    generate coo_group_alt = . `if'

 * Define broader categories for coo_group_alt
    foreach country in `eu_members' {
        replace coo_group_alt = 1 if iso3c == "`country'" `if'
    }
    
    local former_soviet_union "ARM AZE GEO KAZ KGZ MDA MNG TJK TKM UZB UKR"
    foreach country in `former_soviet_union' {
        replace coo_group_alt = 2 if iso3c == "`country'" `if'
    }
    
    local western_balkans "ALB BIH XKX MNE MKD SRB"
    foreach country in `western_balkans' {
        replace coo_group_alt = 3 if iso3c == "`country'" `if'
    }
    
    local semed "EGY JOR LBN MAR TUN PSE IRQ"
    foreach country in `semed' {
        replace coo_group_alt = 4 if iso3c == "`country'" `if'
    }
    
    foreach country in `turkiye' {
        replace coo_group_alt = 5 if iso3c == "`country'" `if'
    }
    
    foreach country in `ssai' {
        replace coo_group_alt = 6 if iso3c == "`country'" `if'
    }

    * Label the coo_group_alt variable
    label define coo_group_alt 1 "EU-EBRD" 2 "Former Soviet Union + Mongolia" 3 "Western Balkans" 4 "SEMED" 5 "Türkiye" 6 "Sub-Saharan Africa"
    label values coo_group_alt coo_group_alt

    * Create the ebrd_shareholder variable
    generate ebrd_shareholder = 0 `if'

    * Define the list of EBRD shareholders in iso3c format (broader than the COOs:
    * includes non-COO shareholders such as Russia, Belarus, Cyprus, Czechia and
    * Greece, and the institutional members EIB and EUU)
    local shareholders "ALB DZA ARM AUS AUT AZE BLR BEL BIH BGR CAN CHN HRV CYP CZE DNK EGY EST EIB EUU FIN FRA GEO DEU GRC HUN ISL IND IRL ISR ITA JPN JOR KAZ KOR XKX KGZ LVA LBN LBY LIE LTU LUX MLT MEX MDA MNG MNE MAR NLD NZL MKD NOR POL PRT ROU RUS SMR SRB SVK SVN ESP SWE CHE TJK TUN TUR TKM UKR ARE GBR USA UZB NGA BEN CIV KEN SEN IRQ GHA"

    foreach country in `shareholders' {
        replace ebrd_shareholder = 1 if iso3c == "`country'" `if'
    }

    * Create the comparator_imf variable: a mutually exclusive IMF/WEO bucket over
    * every resolved economy. EBRD economies -> "EBRD regions"; non-EBRD advanced
    * economies -> "Advanced Economies"; all other resolved economies -> "Other
    * EMDEs". The advanced list is the IMF WEO Advanced Economies group (TR style
    * guide, groupings/comparators.md).
    generate comparator_imf = . `if'

    local advanced "AND AUS AUT BEL CAN CYP CZE DNK FIN FRA DEU GRC HKG ISL IRL ISR ITA JPN KOR LUX MAC MLT NLD NZL NOR PRT PRI SMR SGP ESP SWE CHE TWN GBR USA"

    * 3 = Other EMDEs for every resolved economy...
    replace comparator_imf = 3 if !missing(iso3c) `if'
    * ...2 = Advanced Economies for the IMF advanced list...
    foreach country in `advanced' {
        replace comparator_imf = 2 if iso3c == "`country'" `if'
    }
    * ...1 = EBRD regions takes precedence for any EBRD economy.
    replace comparator_imf = 1 if ebrd == 1 `if'

    label define comparator_imf 1 "EBRD regions" 2 "Advanced Economies" 3 "Other EMDEs"
    label values comparator_imf comparator_imf

    * Print unmatched entries
    local unmatched = ""
    qui levelsof iso3c if missing(ebrd), local(unmatched)
    if "`unmatched'" != "" {
        di as error "Unmatched entries: `unmatched'"
    }
end
