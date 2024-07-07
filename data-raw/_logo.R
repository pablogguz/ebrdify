
#*******************************************************************************
#* This script: generates logo for package website
#*
#* Code by Pablo Garcia Guzman
#*******************************************************************************

packages_to_load <- c("ggplot2",
                      "dplyr",
                      "hexSticker",
                      "usethis",
                      "magick")

package.check <- lapply(
  packages_to_load,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
    }
  }
)

lapply(packages_to_load, require, character=T)

# Script starts ----------------------------------------------------------------

# Create the hex sticker
sticker("inst/figures/babushka_nobackground.png",
        #white_around_sticker = T,
        package = "ebrdify",
        p_size = 22,
        p_color = "#00448D",
        p_y = 1.55,
        s_x = 1,
        s_y = 0.9,
        s_width = 0.6,
        s_height = 0.6,
        h_fill = "#A7BBC9",
        h_color = "#00448D",
        url = "pablogguz.github.io/ebrdify",
        u_size = 5,
        u_color = "#00448D",
        filename = "inst/figures/logo.png") %>% plot()

# fuzz <- 50
# p <- image_read("inst/figures/logo.png")
# pp <- p %>%
#   image_fill(color = "transparent", refcolor = "white", fuzz = fuzz, point = "+1+1") %>%
#   image_fill(color = "transparent", refcolor = "white", fuzz = fuzz, point = paste0("+", image_info(p)$width-1, "+1")) %>%
#   image_fill(color = "transparent", refcolor = "white", fuzz = fuzz, point = paste0("+1", "+", image_info(p)$height-1)) %>%
#   image_fill(color = "transparent", refcolor = "white", fuzz = fuzz, point = paste0("+", image_info(p)$width-1, "+", image_info(p)$height-1))
# image_write(image = pp, path = "inst/figures/logo.png")

# Generate string to copy-paste into README
use_logo("inst/figures/logo.png", geometry = "480x556", retina = TRUE)
