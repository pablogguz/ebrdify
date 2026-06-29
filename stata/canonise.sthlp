{smcl}
*! version 1.0.0 2026-06-29

help for canonise

Title
------
    canonise -- Standardise country names to official EBRD terminology

Syntax
------
    canonise varname [, generate(newvar)]

Description
------------
    `canonise' takes a string variable of country identifiers (ISO3C, ISO2C, or
    country name) and creates a new variable holding the official country name
    used in the EBRD Transition Report. It enforces the TR "forbidden names"
    rules from Annex I of the style guide, for example:

        Czech Republic  -> Czechia
        Palestine       -> West Bank and Gaza
        Kyrgyzstan      -> Kyrgyz Republic
        Slovakia        -> Slovak Republic
        Turkey          -> Türkiye
        Ivory Coast     -> Côte d'Ivoire
        Taiwan          -> Taipei China
        Hong Kong       -> Hong Kong SAR
        Macao           -> Macao SAR

    Names that are not special-cased fall through to the standard English name
    from the isocodes package. Identifiers that cannot be matched are left blank.

Options
-------
    generate(newvar)  name of the variable to create. Default: ebrd_name.

Remarks
-------
    Requires the isocodes package (https://github.com/leojahrens/isocodes).
    Kosovo is recognised from "Kosovo", "KOS", "XKX", "XK", or
    "Republic of Kosovo".

Examples
--------
    input str30 country
        "Czech Republic"
        "Palestine"
        "Kyrgyzstan"
        "Taiwan"
        "Germany"
    end

    canonise country
    list country ebrd_name

Author
------
    Pablo Garcia-Guzman
    Email: garciagp@ebrd.com

Also see
--------
    Online: help for `ebrdify', `list_ebrd', `isocodes'
