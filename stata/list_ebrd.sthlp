{smcl}
*! version 1.0.0 2026-06-29

help for list_ebrd

Title
------
    list_ebrd -- Load the list of EBRD economies into memory

Syntax
------
    list_ebrd [, group(string) clear]

Description
------------
    `list_ebrd' replaces the data in memory with the 41 EBRD economies, creating
    three string variables: iso3c (ISO3 code, Kosovo = XKX), name (official EBRD
    name), and coo_group (traditional regional grouping).

    Because it replaces the data in memory, the clear option is required when a
    dataset is already loaded.

Options
-------
    group(string)  keep only the economies in one traditional regional grouping,
                   e.g. group("Central Asia"). See below for the valid values.
    clear          replace the data currently in memory.

    Valid groups: Central Asia; Central Europe and Baltic States; Eastern Europe
    and the Caucasus; South-eastern Europe; Southern and Eastern Mediterranean;
    Sub-Saharan Africa; Türkiye.

Stored results
--------------
    list_ebrd stores the following in r():

        r(N)      number of economies loaded
        r(iso3)   space-separated list of the loaded ISO3 codes

Examples
--------
    list_ebrd, clear
    list_ebrd, clear group("Central Asia")
    display "`r(iso3)'"

Author
------
    Pablo Garcia-Guzman
    Email: garciagp@ebrd.com

Also see
--------
    Online: help for `ebrdify', `canonise'
