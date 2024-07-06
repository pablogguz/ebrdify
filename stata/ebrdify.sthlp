{smcl}
*! version 1.0.0 2024-07-05

help for ebrdify

Title
------
    ebrdify -- Create dummy variable for EBRD countries and categorize regions

Syntax
------
    ebrdify varname [if]

Description
------------
    `ebrdify' creates a dummy variable indicating whether the input variable 
    (country code or country name) corresponds to an EBRD country. Additionally,
    it creates a categorical variable indicating the region of the country.

Options
-------
    There are no additional options for `ebrdify'.

Remarks
-------
    The input variable can be in ISO3C, ISO2C, or country name format. The 
    program uses the `isocodes` package to handle conversions.

Examples
--------
    . input str20 country_code
    . "KAZ"
    . "KGZ"
    . "USA"
    . "TJK"
    . "FRA"
    . "UZB"
    . end

    . list

    . ebrdify country_code

    . list

Author
------
    Pablo Garcia-Guzman
    Email: garciagp@ebrd.com

Also see
--------
    Manual: [D] functions
    Online: help for `isocodes`
