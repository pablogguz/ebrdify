

// Set up GitHub installation source if not already installed
cap which github
if _rc {
    net install github, from("https://haghish.github.io/github/")
}

// Navigate to the package directory
cd "C:\Users\pablo\Documents\GitHub\ebrdify\stata"

make ebrdify, replace toc pkg version(0.1.0)                                  ///
     license("MIT")                                                           ///
     author("Pablo Garcia-Guzman")                                            ///
     affiliation("EBRD")                                                      ///
     email("garciagp@ebrd.com")                                               ///
     url("")                                                                  ///
     title("Create dummy variable for EBRD countries and categorize regions") ///
     description("")                                                          ///
     install("ebrdify.ado;ebrdify.sthlp")                                        
