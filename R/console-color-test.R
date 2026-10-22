#' Visual test for color support in the R console
#'
#' @description
#' Determine, by visual inspection, if the R console supports 256^3 true colors,
#' 256 ANSI colors, or 8 ANSI colors. For each of those color levels,
#' `console_color_test()` prints both a rainbow and a greyscale gradient.
#'
#' * If the gradients for 256^3 true colors appear fairly smooth (without
#'   banding), then the console supports 256^3 colors.
#'
#' * If the gradients for 256 ANSI colors appear fairly smooth (though not as
#'   smooth as the 256^3 true color gradient), then the console supports 256
#'   colors.
#'
#' * If the gradients for 8 ANSI colors show 6 distinct rainbow colors in
#'   addition to black and white, then the console supports 8 colors.
#'
#' \Sexpr[results=rd,stage=render]{
#'   if (requireNamespace("pkgdown", quietly = TRUE) && pkgdown::in_pkgdown()) {
#'     ""
#'   } else {
#'     "\\\\out{<p>
#'     <a href='https://dmuenz.github.io/colorkit/reference/console_color_test.html'>
#'       Visit the online reference page
#'     </a>
#'     to see the output of a successful test for 256^3 colors.</p>}"
#'   }
#' }
#'
#' @seealso [print_color()] for printing colors in the console.
#' @export
#' @examples
#' console_color_test()
console_color_test <- function() {
  gradient_test(256^3)
  cat("\n")
  gradient_test(256)
  cat("\n")
  gradient_test(8)

  invisible(NULL)
}

gradient_test <- function(num_colors) {
  num_colors_label <- deparse(substitute(num_colors))
  color_type <- if (num_colors == 256^3) "true" else "ANSI"
  cli_text_basic(cli::style_underline(
    "{num_colors_label} {color_type} color test"
  ))

  double_rainbow <- rep(rainbow(64), times = 2)
  cat("Rainbow:   ")
  print_color(
    double_rainbow[65 - 6 + 1:64],
    width = 1,
    count = FALSE,
    num_colors = num_colors
  )

  cat("Greyscale: ")
  print_color(
    grey(seq(0, 1, length.out = 64)),
    width = 1,
    count = FALSE,
    num_colors = num_colors
  )
}
