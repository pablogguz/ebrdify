

// net install github, from("https://haghish.github.io/github/")

cd "C:\Users\pablo\Documents\GitHub\ebrdify\stata"
// db make

make ebrdify, replace toc pkg version(0.0.0.9000)                           ///
     license("MIT")                                                          ///
     author("Pablo Garcia-Guzman")                                           ///
     affiliation("")                                                         ///
     email("garciagp@ebrd.com")                                              ///
     url("")                                                                 ///
     title("Create dummy variable for EBRD countries and categorize regions") ///
     description("")                                                         ///
     install("ebrdify.ado;ebrdify.sthlp")                                        
