#' Choose a foreground color (dark or light) to contrast with a background color
#'
#' Given a background color, `bg2fg()` tells you whether to use a `dark` or
#' `light` color in the foreground (i.e., for text), so as to maximize contrast
#' ratio and thus legibility.
#'
#' Contrast ratio is a function of the luminance of two colors. `bg2fg()`
#' calculates contrast ratio and luminance according to WCAG 2.x definitions:
#'
#' * <https://www.w3.org/WAI/GL/wiki/Contrast_ratio>
#' * <https://www.w3.org/WAI/GL/wiki/Relative_luminance>
#'
#' [plot_color()] and [print_color()] both use `bg2fg()` to choose the
#' foreground text color for their displays.
#'
#' @param bg A vector/array of R colors
#' @param dark A single R color; should be a dark color
#' @param light A single R color; should be a light color
#'
#' @returns A vector/array with the same dimensions as `bg`, where every element
#'   is either `dark` or `light`.
#'
#' @seealso [col2hex()] for converting colors to hex strings.
#' @export
#' @examples
#' bg2fg(c("red", "black", "white", "purple"))
#'
#' # note that bg2fg() is used behind-the-scenes in the following two calls
#' plot_color(c("red", "black", "white", "purple"))
#' print_color(c("red", "black", "white", "purple"))
bg2fg <- function(bg, dark = "#000000", light = "#F8F8F8") {
  bg_lum <- luminance(bg)
  dark_lum <- luminance(dark)
  light_lum <- luminance(light)

  test <- contrast_ratio(bg_lum, dark_lum) > contrast_ratio(bg_lum, light_lum)
  ifelse(test, dark, light)
}

# relative luminance of a color as defined by WCAG 2.x
# https://www.w3.org/WAI/GL/wiki/Relative_luminance
luminance <- function(col) {
  rgb <- decode_color(col) / 255

  is_low <- rgb <= 0.03928
  which_is_low <- which(is_low)
  which_isnt_low <- which(!is_low)

  rgb[which_is_low] <- rgb[which_is_low] / 12.92
  rgb[which_isnt_low] <- ((rgb[which_isnt_low] + 0.055) / 1.055)^2.4

  lum <- (rgb %*% c(0.2126, 0.7152, 0.0722))[, 1]

  # restore original dimenions
  if (is.array(col)) dim(lum) <- dim(col)

  lum
}

# contrast ratio of the luminances of two colors, as defined by WCAG
# https://www.w3.org/WAI/GL/wiki/Contrast_ratio
contrast_ratio <- function(lum1, lum2) {
  (pmax(lum1, lum2) + 0.05) / (pmin(lum1, lum2) + 0.05)
}
