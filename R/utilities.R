# Report whether `x` is boolean (a single TRUE/FALSE flag)
is_bool <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x)
}

# Report whether `x` is a non-missing scalar number
is_scalar_num <- function(x, min_in, min_ex, max_in, max_ex) {
  is.numeric(x) && length(x) == 1L && !is.na(x) && is.finite(x) &&
    (missing(min_in) || x >= min_in) &&
    (missing(min_ex) || x >  min_ex) &&
    (missing(max_in) || x <= max_in) &&
    (missing(max_ex) || x <  max_ex)
}

# Simple wrapper around farver::decode_colour() for converting a color
# vector/array `col` to an RGB matrix. The only benefit of the wrapper is that
# it makes some error messages more informative.
decode_color <- function(col, ...) {
  # convert col to rgb matrix. Catch and print any error so we can add more
  # context to the message.
  tryCatch(
    farver::decode_colour(col, ...),
    error = function(e) {
      msg <- conditionMessage(e)

      if (msg == "Invalid hexadecimal digit") {
        # figure out which col element has an invalid hex digit
        col <- as.character(c(col))
        col <- col[substr(col, 1, 1) == "#"]
        col <- col[!grepl("^#[0-9a-fA-F]+$", col)]
        if (length(col) > 0) {
          msg <- paste0(msg, " in `", col[1], "`")
        }
      } else if (startsWith(msg, "Unknown colour name:")) {
        # put backticks around the invalid name
        msg <- sub(":\\s*(.*)", " `\\1`", msg, perl = TRUE)
      }

      cli::cli_abort("{msg}", call = NULL)
    }
  )
}

# Simple wrapper around farver::encode_colour() for converting an RGB(A) color
# matrix to hex color strings. The wrapper has two benefits:
# (1) You can pass an RGBA matrix in as one object, rather than as an RGB matrix
#   with a corresponding A vector. This makes piping easier.
# (2) farver::encode_colour() has a slight inconsistency, where it removes the
#   alpha channel from a hex string if it's FF (opaque) but only when multiple
#   colors are passed in. The wrapper also removes an FF alpha if a single color
#   is passed.
encode_color <- function(col) {
  hex <- farver::encode_colour(
    col[, 1:3, drop = FALSE],
    alpha = if (ncol(col) == 4) col[, 4]
  )

  # remove alpha if opaque -- do this only when there's just one color since
  # farver::encode_colour() does it automatically when there are multiple colors
  if (length(hex) == 1 && substr(hex, 8, 9) == "FF")
    hex <- substr(hex, 1, 7)

  hex
}

# Transform `col` to match the shape and class of `original`. The idea is that
# some color object `original` (a vector or array) has gone through some
# transformations to arrive at `col`, and we want to ensure that `col` still has
# the same shape and class as `original`. In particular, if `original` is a
# raster matrix, then this will make `col` a raster matrix too.
inherit_shape_and_class <- function(col, original) {
  dim(col) <- dim(original)
  if (is.array(original))
    class(col) <- class(original)
  col
}

check_color <- function(col, req_len = NULL, allow_null = FALSE,
                        arg = rlang::caller_arg(col),
                        call = rlang::caller_env()) {
  force(arg)

  type <- if (is.null(req_len)) "a vector or array of colors"
  else cli::format_inline("{req_len} color{?s}")

  if (allow_null)
    type <- paste(type, "or `NULL`")

  if (is.null(col)) {
    if (allow_null)
      return(invisible(NULL))
    else
      cli::cli_abort("{.arg {arg}} must be {type}.", call = call)
  }

  if (!is.atomic(col))
    cli::cli_abort("{.arg {arg}} must be {type}.", call = call)

  if (!is.null(req_len) && length(col) != req_len)
    cli::cli_abort("{.arg {arg}} must be {type}.", call = call)

  tryCatch(
    decode_color(col),
    error = function(e) {
      msg <- paste("{.arg {arg}}:", conditionMessage(e))
      cli::cli_abort(msg, call = call)
    }
  )

  invisible(NULL)
}
