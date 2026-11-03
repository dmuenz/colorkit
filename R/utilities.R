# Report whether `x` is boolean (a single TRUE/FALSE flag)
is_bool <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x)
}

# Report whether `x` is a number, optionally with bounds
is_number <- function(x,
                      min_in = NULL, min_ex = NULL,
                      max_in = NULL, max_ex = NULL) {

  if (!is.null(min_in) && !is.null(min_ex))
    cli::cli_abort("Cannot use both {.arg min_in} and {.arg min_ex}.")
  if (!is.null(max_in) && !is.null(max_ex))
    cli::cli_abort("Cannot use both {.arg max_in} and {.arg max_ex}.")

  is.numeric(x) && length(x) == 1L && !is.na(x) && is.finite(x) &&
    (is.null(min_in) || x >= min_in) &&
    (is.null(min_ex) || x >  min_ex) &&
    (is.null(max_in) || x <= max_in) &&
    (is.null(max_ex) || x <  max_ex)
}

# Check that an argument is a number, optionally with bounds, and produce
# friendly error messages otherwise
check_number <- function(x,
                         min_in = NULL, min_ex = NULL,
                         max_in = NULL, max_ex = NULL,
                         allow_na = FALSE, allow_null = FALSE,
                         arg = rlang::caller_arg(x),
                         call = rlang::caller_env()) {
  force(arg)

  if (is_number(x, min_in = min_in, min_ex = min_ex,
                   max_in = max_in, max_ex = max_ex) ||
      allow_null && is.null(x) ||
      allow_na && length(x) == 1L && is.na(x)) {
    return(invisible(NULL))
  }

  rng <- character(0)
  if (!is.null(min_in)) rng <- paste(">=", min_in)
  if (!is.null(min_ex)) rng <- c(rng, paste(">",  min_ex))
  if (!is.null(max_in)) rng <- c(rng, paste("<=", max_in))
  if (!is.null(max_ex)) rng <- c(rng, paste("<",  max_ex))
  rng <- paste(rng, collapse = " and ")

  rlang::stop_input_type(
    x,
    paste("a number", rng),
    allow_na = allow_na,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
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

# Check that an argument is a color (or colors), and produce friendly error
# messages otherwise
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
