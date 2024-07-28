
cap program drop ebrdify
program define ebrdify
    syntax varlist(string) [if]

    * Ensure we only have one variable in the varlist
    if `:word count `varlist'' != 1 {
        di as error "You must specify exactly one string variable."
        exit 198
    }
    
	* Ensure variables do not exist
	capture confirm variable ebrd 
	if (!_rc) {
		di as error "Column 'ebrd' already in the dataset. Replacing..."
		cap drop ebrd
	}
	
	capture confirm variable coo_group 
	if (!_rc) {
		di as error "Column 'coo_group' already in the dataset. Replacing..."
		cap drop coo_group
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
    local ebrd_countries "KAZ KGZ MNG TJK TKM UZB HRV CZE EST HUN LVA LTU POL SVK SVN GRC ARM AZE GEO MDA UKR ALB BIH BGR XKX MNE MKD ROU SRB EGY JOR LBN MAR TUN PSE TUR"

    * Set ebrd to 1 for EBRD countries
    foreach country in `ebrd_countries' {
        replace ebrd = 1 if iso3c == "`country'" `if'
    }

    * Create the coo_group categorical variable
    generate coo_group = . `if'

    * Define groups of countries
    local central_asia "KAZ KGZ MNG TJK TKM UZB"
    local central_europe_baltic "HRV CZE EST HUN LVA LTU POL SVK SVN"
    local greece "GRC"
    local eastern_europe_caucasus "ARM AZE GEO MDA UKR"
    local south_eastern_europe "ALB BIH BGR XKX MNE MKD ROU SRB"
    local southern_eastern_mediterranean "EGY JOR LBN MAR TUN PSE TUR"

    * Assign group codes
    foreach country in `central_asia' {
        replace coo_group = 1 if iso3c == "`country'" `if'
    }
    foreach country in `central_europe_baltic' {
        replace coo_group = 2 if iso3c == "`country'" `if'
    }
    foreach country in `greece' {
        replace coo_group = 3 if iso3c == "`country'" `if'
    }
    foreach country in `eastern_europe_caucasus' {
        replace coo_group = 4 if iso3c == "`country'" `if'
    }
    foreach country in `south_eastern_europe' {
        replace coo_group = 5 if iso3c == "`country'" `if'
    }
    foreach country in `southern_eastern_mediterranean' {
        replace coo_group = 6 if iso3c == "`country'" `if'
    }

    * Label the coo_group variable
    label define coo_group 1 "Central Asia" 2 "Central Europe and Baltic States" 3 "Greece" 4 "Eastern Europe and the Caucasus" 5 "South-eastern Europe" 6 "Southern and Eastern Mediterranean"
    label values coo_group coo_group

    * Print unmatched entries
    local unmatched = ""
    qui levelsof iso3c if missing(ebrd), local(unmatched)
    if "`unmatched'" != "" {
        di as error "Unmatched entries: `unmatched'"
    }
end
