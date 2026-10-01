#' Random sampling of colors
#'
#' @param n The number of colors to sample
#' @param hex Either `TRUE` (meaning sample only hex strings), `FALSE` (meaning
#'   sample only color names), or a real number from 0 to 1 indicating the
#'   proportion of colors that should be hex strings (rather than color names)
#' @param alpha `TRUE`/`FALSE` for whether hex strings should have a random
#'   alpha value
#'
#' @returns A character vector of length `n`
#'
#' @export
rand_color <- function(n = 1, hex = 0.5, alpha = FALSE) {
  if (!is_scalar_num(n) || n < 0) {
    cli::cli_abort("{.arg n} must be a number >= 0")
  }

  n <- floor(n)

  if (n == 0)
    return(character(0))

  if (!is_bool(hex) && !(is_scalar_num(hex) && hex >= 0 && hex <= 1)) {
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
