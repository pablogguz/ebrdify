// Simple benchmark comparing ebrdify versions

// Create test data
clear
set seed 12345
set obs 100000

// Create random country sample
gen country = ""
local i = 1
foreach c in KAZ CZE GRC ARM ALB EGY USA CAN GBR DEU FRA ITA ESP XXX {
    replace country = "`c'" if mod(_n, 14) == `i'
    local i = `i' + 1
}

// Add some missing and empty values
replace country = "" if mod(_n, 20) == 0
replace country = "XXX" if mod(_n, 25) == 0

// Time original version
preserve
    timer clear 1
    timer on 1
    ebrdify country
    timer off 1
restore

// Time new version
preserve
    timer clear 2
    timer on 2

    ebrdify2 country
    timer off 2
restore

// Show results
timer list