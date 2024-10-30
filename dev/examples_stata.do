    
**# iso3c codes
	clear all
	
	input str20 country_code
        "KAZ"
        "KGZ"
        "USA"
        "TJK"
        "FRA"
        "UZB"
    end

    ebrdify country_code

    list
	
**# country names
	clear all

	input str20 country_code str20 country_name
		"KAZ" "Kazakhstan"
		"KGZ" "Kyrgyzstan"
		"USA" "United States"
		"TJK" "Tajikistan"
		"FRA" "France"
		"UZB" "Uzbekistan"
		"KOS" "Kosovo"
		"BGR" "Bulgaria"
		"SRB" "Serbia"
		"MKD" "North Macedonia"
		"ROU" "Romania"
	end
	
	g ebrd = ""
	g coo_group = ""
	
	ebrdify country_name
	
	list