#' Random sampling of colors
#'
#' When `hex` is `TRUE` or `1`, `rand_color()` generates a random sample
#' uniformly distributed over the RGB(A) color space. When `hex` is `FALSE` or
#' `0`, `rand_color()` generates a random sample uniformly distributed over
#' distinct R color names. When `hex` is between 0 and 1, the sampling
#' distribution is a mixture of those two uniform distributions.
#'
#' @param n The number of colors to sample.
#' @param hex Either `TRUE` (meaning sample only hex strings), `FALSE` (meaning
#'   sample only color names), or a real number from 0 to 1 indicating the
#'   proportion of colors that should be hex strings (rather than color names).
#' @param alpha `TRUE`/`FALSE` for whether hex strings should have a random
#'   alpha value.
#'
#' @returns A character vector of length `n`.
#' @seealso [plot_color()] and [print_color()] for visualizing the colors.
#' @export
#' @examples
#' # random color vector
#' v <- rand_color(5)
#' v
#' print_color(v)
#'
#' # random color matrix
#' m <- rand_color(6) |> matrix(ncol = 3)
#' m
#' print_color(m)
#'
#' # sample hex strings, color names, or a mixture
#' rand_color(8, hex = TRUE)
#' rand_color(8, hex = FALSE)
#' rand_color(8, hex = 0.5)
rand_color <- function(n = 1, hex = 0.5, alpha = FALSE) {
  if (!is_scalar_num(n, min_in = 0)) {
    cli::cli_abort("{.arg n} must be a number >= 0")
  }

  n <- floor(n)

  if (n == 0)
    return(character(0))

  if (!is_bool(hex) && !is_scalar_num(hex, min_in = 0, max_in = 1)) {
    cli::cli_abort("{.arg hex} must be either TRUE, FALSE, or a number between
                   0 and 1.")
  }

  rlang::check_bool(alpha)

  n_hex <- round(hex * n)
  n_names <- n - n_hex

  col_hex <- if (n_hex > 0) {
    rgb_mat <- matrix(sample(0:255, size = 3 * n_hex, replace = TRUE), ncol = 3)
    alpha_vec <- if (alpha) sample(0:255, size = n_hex, replace = TRUE) / 255
    encode_color(cbind(rgb_mat, alpha_vec))
  }

  col_names <- if (n_names > 0) {
    sample(grDevices::colors(distinct = TRUE), size = n_names, replace = TRUE)
  }

  sample(c(col_names, col_hex))
}
