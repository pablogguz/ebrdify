{smcl}
*! version 1.1.0 2026-06-29

help for ebrdify

Title
------
    ebrdify -- Classify countries into EBRD groupings

Syntax
------
    ebrdify varname [if]

Description
------------
    `ebrdify' takes a string variable of country identifiers (ISO3C, ISO2C, or
    country name) and adds six classification variables, following the official
    EBRD / Transition Report classification:

        ebrd              1 if an EBRD country of operation, 0 otherwise
        coo_group         traditional EBRD regional grouping
        eu_ebrd           1 if an EBRD economy that is also an EU member
        coo_group_alt     alternative EBRD grouping
        ebrd_shareholder  1 if an EBRD shareholder, 0 otherwise
        comparator_imf    IMF/WEO comparator bucket: "EBRD regions" (any EBRD
                          economy), "Advanced Economies" (non-EBRD advanced
                          economy), or "Other EMDEs" (every other resolved
                          economy)

    Naming and groupings follow Annex I of the EBRD OCE Transition Report style
    guide. As of 2026, Czechia and Greece are no longer EBRD economies; in
    comparator_imf they fall under "Advanced Economies".

Options
-------
    There are no additional options for `ebrdify'.

Remarks
-------
    The input variable can be in ISO3C, ISO2C, or country name format. The 
    program uses the `isocodes` package (https://github.com/leojahrens/isocodes) to handle conversions.

Examples
--------
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

Author
------
    Pablo Garcia-Guzman
    Email: garciagp@ebrd.com

Also see
--------
    Manual: [D] functions
    Online: help for `isocodes`
