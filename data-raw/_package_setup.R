

username <- Sys.getenv("USERNAME")

path <- paste0("C:/Users/", username, "/Documents/GitHub/ebrdify/")

# Create package
usethis::create_package(path)

# Activate project
usethis::proj_activate(path)

# use_mit_license("My Name")