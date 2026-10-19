#' Convert colors to hex color strings
#'
#' `col2hex()` takes a vector/array of R colors (e.g., `c("red", "#fac")`) and
#' standardizes them as hex strings (e.g., `c("#FF0000", "#FFAACC")`). The
#' standardized hex strings will always be uppercase and will have either 6 or 8
#' hex digits, depending for each color on whether it's opaque.
#'
#' This function may be useful for programmatically creating code in a different
#' language, like HTML/CSS. For example, "violetred" is a valid R color but is
#' not a valid HTML/CSS color. So you could generate valid code like so:
#'
#' ```
#' sprintf("<div style='background:%s;'></div>", col2hex("violetred"))
#' ```
#'
#' Another use case is when drawing [raster objects][grid::rasterGrob()] with
#' the `grid` package. If a raster object is specified with R color names, it
#' can usually be drawn much faster if first converted to hex strings. Compare,
#' for example, the rendering time for the following two calls to
#' `grid::grid.raster()`. The latter is noticeably faster in the author's
#' testing.
#'
#' ```
#' # big matrix of color names
#' cols <- rand_color(1e6, hex = FALSE) |> matrix(ncol = 1e3)
#'
#' # draw the matrix as a raster object
#' grid::grid.newpage()
#' grid::grid.raster(cols)
#'
#' # draw it again, but first convert color names to hex strings
#' grid::grid.newpage()
#' grid::grid.raster(col2hex(cols))
#' ```
#'
#' @param col A vector/array of R colors. Can be character or numeric.
#'
#' @returns A vector/array with the same dimensions as `col`, where every
#'   element of `col` has been converted to a hex string. If the input is a
#'   raster matrix, then the output will be a raster matrix too.
#'
#' @seealso [bg2fg()] for choosing a foreground color to contrast with a
#'   background color.
#' @export
#' @examples
#' col2hex(1:8)
#' col2hex(c("red", "#fac", "1", NA))
col2hex <- function(col) {
  if (!is.vector(col) && !is.array(col) ||
      !is.character(col) && !is.numeric(col) && !is.logical(col)) {
    stop("Colors must be a vector or array of strings or numbers.",
         call. = FALSE)
  }

  # Coerce to character so the C++ side has a uniform type
  mode(col) <- "character"
  col_vec <- structure(col, dim = NULL)

  # Convert to hex
  hex <- .Call(col2hex_c, col, palette_lookup_table())

  # Restore input shape and class
  inherit_shape_and_class(hex, original = col)
}

# Colors lookup table is built once per session in .onLoad
colors_lookup_table <- function() {
  col <- colors()
  rgb_mat <- farver::decode_colour(col)
  hex <- farver::encode_colour(rgb_mat)
  c(setNames(hex, col), transparent = "#FFFFFF00")
}

# Palette lookup table is built once per col2hex() call
palette_lookup_table <- function() {
  col <- palette()
  rgba_mat <- farver::decode_colour(col, alpha = TRUE)
  hex <- farver::encode_colour(rgba_mat, alpha = rgba_mat[, 4])
  hex
}
