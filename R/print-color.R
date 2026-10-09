#' Print colored cells in the console
#'
#' @description
#' Pass `print_color()` R colors, and it will print each color as a colored
#' rectangle/cell. The background color of the cell will be the specified color
#' (or a close approximation, depending on how many colors your console
#' supports). By default, the color string text will be printed in the
#' foreground of the cell (in a color that contrasts with the background).
#'
#' `print_color()` and [plot_color()] are sister functions that both display
#' color cells. The primary difference is where the colors are displayed: in the
#' console or in the graphics device.
#'
#' @details
#' `print_color()` works best if your console supports 24-bit colors. If it
#' does, then your console can display all 2^24 colors (equivalently, 256^3 or
#' ~16.7 million colors) that can be specified using the `"#rrggbb"` hex RGB
#' syntax. If your console does not support that many colors, then it may
#' (depending on your platform) map each specified color to the closest
#' printable color.
#'
#' To visually check whether your console supports 24-bit colors, run the
#' following code. If the result is a fairly smooth gradient within each row,
#' then you have 24-bit colors. If you instead see color banding (wide, distinct
#' steps between colors within a row) or worse (e.g., monochrome), then you have
#' fewer colors.
#'
#' ```
#' # test: can the console print in 24-bit color?
#' print_color(matrix(rainbow(240), nrow = 6, byrow = TRUE), width = 1)
#' ```
#'
#' The foreground text color of each cell is determined by [bg2fg()].
#'
#' @param col A vector, matrix, or list of vectors/matrices, all containing R
#'   colors. Can be character or numeric. The alpha (transparency) channel will
#'   be ignored.
#' @param quote `TRUE`/`FALSE` for whether to print quotation marks around color
#'   strings.
#' @param width Determines the width of each color cell and also whether the
#'   color string text is printed in the blcellock's foreground. There are 3
#'   options:
#'   * If `NULL` (the default), the color string text is printed, and all color
#'     cells will be the same size. The size will be set based on the width of
#'     the longest color string.
#'   * If `NA`, the color string text is printed, and each color cell will be
#'     only as wide as needed to fit its text.
#'   * If a number >= 1, the color string text is *not* printed, and each cell
#'     will be exactly `floor(width)` characters wide.
#' @param gap Determines the horizontal gap between cells There are 2 options:
#'   * If `NULL` (the default): If `width` is a number (so cells have no
#'     foreground text), there will be no gap. Otherwise (when there is
#'     foreground text), the gap will be 1 space.
#'   * If a number >= 0, the gap will be `floor(gap)` spaces.
#' @param max Determines the maximum number of colors to print. Either `NULL`
#'   (the default, meaning use `getOption("max.print")`) or a number >= 0. The
#'   number will be truncated (`floor(max)`) and then will be honored exactly
#'   when printing a vector or approximately when printing a matrix.
#'
#' @returns Invisibly returns `col`.
#' @seealso [plot_color()] for plotting colors in the graphics device.
#' @export
#' @examples
#' print_color(c("red", "steelblue", "#40E0D0"))
#' print_color(c("red", "steelblue", "#40E0D0"), width = 5)
#'
#' print_color(rainbow(10))
#' print_color(rainbow(80), width = 1)
#'
#' # Print all the RColorBrewer palettes
#' if (requireNamespace("RColorBrewer")) {
#'   pals <- sapply(rownames(RColorBrewer::brewer.pal.info), function(pal) {
#'     RColorBrewer::brewer.pal(Inf, pal)
#'   }) |> suppressWarnings() |> rev()
#'
#'   print_color(pals, width = 3)
#' }
#'
#' # Convert 'volcano' to a matrix of colors, then print
#' mat <- volcano[1:20, 1:20]
#' n <- 50
#' color_idx <- cut(mat, breaks = n, labels = FALSE)
#' color_mat <- structure(rainbow(n)[color_idx], dim = dim(mat))
#' print_color(color_mat, width = 3)
print_color <- function(col, quote = FALSE, width = NULL, gap = NULL,
                        max = NULL) {
  rlang::check_bool(quote)

  if (!is.null(width) && !isTRUE(is.na(width)) &&
      !is_scalar_num(width, min_in = 1)) {
    rlang::stop_input_type(width, "`NULL`, `NA`, or a number >= 1")
  }
  if (is_scalar_num(width)) width <- floor(width)

  if (!is.null(gap) && !is_scalar_num(gap, min_in = 0)) {
    rlang::stop_input_type(gap, "`NULL` or a non-negative number")
  }
  if (is_scalar_num(gap)) gap <- floor(gap)

  if (is.null(max)) max <- getOption("max.print")
  if (!is_scalar_num(max, min_in = 0)) {
    rlang::stop_input_type(max, "`NULL` or a non-negative number")
  }
  max <- floor(max)

  num_colors <-
    if (!is.null(getOption("colorkit.num_colors"))) {
      as.integer(getOption("colorkit.num_colors"))
    } else if (Sys.getenv("POSITRON") == "1") {
      2^24
    } else {
      cli::num_ansi_colors()
    }

  old_op <- options(cli.num_colors = num_colors)
  on.exit(options(old_op))

  if ((is.vector(col) && is.atomic(col)) || is.matrix(col)) {
    check_color(col)

    do.call(
      paste0("print_color_", if (is.vector(col)) "vector" else "matrix"),
      list(col = col, quote = quote, width = width, gap = gap, max = max)
    )
  } else if (is.list(col)) {
    for (i in seq_along(col)) {
      if (i > 1) cat("\n")

      col_i <- col[[i]]
      if (!((is.vector(col_i) && is.atomic(col_i)) || is.matrix(col_i)))
        cli::cli_abort("Element {i} of {.arg col} is not a vector or matrix.")
      check_color(col_i, arg = "col")

      list_name <- names(col[i])
      nm <-
        if (is.null(list_name) || isTRUE(nchar(list_name) == 0)) "[[{i}]]"
        else if (grepl("\\s", list_name)) "$`{list_name}`"
        else "${list_name}"

      cli_text_basic(nm)
      do.call(
        paste0("print_color_", if (is.vector(col_i)) "vector" else "matrix"),
        list(col = col_i, quote = quote, width = width, gap = gap, max = max)
      )
    }
  } else {
    cli::cli_abort("{.arg col} must be an atomic vector, matrix, or list of
                   atomic vectors and matrices.")
  }

  invisible(col)
}

print_color_vector <- function(col, quote = FALSE, width = NULL, gap = NULL,
                               max = NULL) {
  len_orig <- length(col)
  if (len_orig == 0)
    return(invisible(NULL))

  cli_text_basic("({len_orig} color{?s})")

  if (is.null(max)) max <- getOption("max.print")
  col <- col[seq_len(min(len_orig, max))]
  len_new <- length(col)

  on.exit(omission_note(n = len_orig - len_new))

  if (len_new == 0)
    return(invisible(NULL))

  has_fg <- is.null(width) || is.na(width)
  cli::cli_div(theme = cli_theme(col, has_fg))

  gap <- if (has_fg && is.null(gap)) 1 else gap %||% 0

  standardize_text(col = col, width = width, quote = quote) |>
    style_with_cli() |>
    paste(collapse = nbsp(gap)) |>
    cli_text_basic()

  invisible(NULL)
}

print_color_matrix <- function(col, quote = FALSE, width = NULL, gap = NULL,
                               max = NULL) {
  col <- as.matrix(col)

  nrow_orig <- nrow(col)
  ncol_orig <- ncol(col)
  if (nrow_orig == 0 || ncol_orig == 0)
    return(invisible(NULL))

  cli_text_basic("({nrow_orig} x {ncol_orig} =
                 {nrow_orig * ncol_orig} color{?s})")

  if (is.null(max)) max <- getOption("max.print")

  if (max == 0) {
    omission_note(nrow = nrow_orig, ncol = ncol_orig)
    return(invisible(NULL))
  }

  console_width <- max(cli::console_width(),
                       nchar(grDevices::colors()) + 2 * quote)
  has_fg <- is.null(width) || is.na(width)
  gap <- if (has_fg && is.null(gap)) 1 else gap %||% 0
  min_el_width <- if (has_fg) 2 else width

  max_cols <- floor((console_width + gap) / (min_el_width + gap))
  col <- col[, seq_len(min(ncol_orig, max_cols)), drop = FALSE]

  max_rows <- floor(max / ncol(col))
  col <- col[seq_len(min(nrow_orig, max_rows)), , drop = FALSE]

  if (nrow(col) == 0 || ncol(col) == 0) {
    omission_note(nrow = nrow_orig, ncol = ncol_orig)
    return(invisible(NULL))
  }

  col_std <- standardize_text(col = col, width = width, quote = quote)

  column_widths <- apply(col_std, 2, \(x) max(nchar(x)))
  ncol_new <- max(1, which(cumsum(column_widths + gap) - gap <= console_width))

  col <- col[, 1:ncol_new, drop = FALSE]
  col_std <- col_std[, 1:ncol_new, drop = FALSE]

  nrow_omit <- nrow_orig - nrow(col)
  ncol_omit <- ncol_orig - ncol(col)

  cli::cli_div(theme = cli_theme(col, has_fg))

  col_fmt <- style_with_cli(col_std)

  if (isTRUE(is.na(width))) {
    for (i in 1:ncol(col)) {
      widths <- nchar(col_std[,i])
      max_width <- max(widths)
      col_fmt[,i] <- paste0(col_fmt[,i], nbsp(max_width - widths))
    }
  }

  col_fmt <- apply(col_fmt, 1, \(x) paste0(x, collapse = nbsp(gap)))

  for (i in seq_along(col_fmt)) {
    cli_text_basic(col_fmt[i])
  }

  omission_note(nrow = nrow_omit, ncol = ncol_omit)
  invisible(NULL)
}

standardize_text <- function(col, width = NULL, quote = FALSE) {
  if (is.null(width) || is.na(width)) {
    text <- col
    is_na <- is.na(c(col))
    text[is_na] <- "NA"

    if (is.character(col))
      text <- gsub(" ", "", text, fixed = TRUE)

    if (isTRUE(quote) && is.character(col))
      text[!is_na] <- sprintf('"%s"', text[!is_na])

    if (is.null(width)) {
      len <- nchar(text)
      pad_len <- max(len) - len
      text <- paste0(text, nbsp(pad_len))
    }
  } else {
    text <- nbsp(width) |> rep(length(c(col)))
  }

  structure(text, dim = dim(col))
}

cli_theme <- function(col, has_fg) {
  bg <- col2hex(col)
  if (has_fg) fg <- bg2fg(bg)

  theme_list <- lapply(seq_along(col), \(i) {
    if (has_fg)
      list("background-color" = bg[i], "color" = fg[i])
    else
      list("background-color" = bg[i])
  })
  names(theme_list) <- paste0("span.item", seq_along(col))
  theme_list
}

style_with_cli <- function(text) {
  structure(
    paste0("{.item", seq_along(text), " ", text, "}"),
    dim = dim(text)
  )
}

omission_note <- function(n = NULL, nrow = NULL, ncol = NULL) {
  count <- character()
  if (isTRUE(n > 0)) {
    count <- cli::format_inline("{n} entr{?y/ies}")
  } else if (isTRUE(nrow > 0) || isTRUE(ncol > 0)) {
    nrow_msg <- if (isTRUE(nrow > 0)) cli::format_inline("{nrow} row{?s}")
    ncol_msg <- if (isTRUE(ncol > 0)) cli::format_inline("{ncol} column{?s}")
    count <- paste(c(nrow_msg, ncol_msg), collapse = " and ")
  }

  # note: the following string is split into 3 parts because R does not allow
  # mixing Unicode escapes (\uXXXX) and octal/hex escapes (\033, \x1b) in the
  # same string literal
  if (length(count) == 1)
    cli_text_basic("\033[38;5;246m", "# \u2139 omitted {count}", "\033[039m")
}

# non-breaking space
nbsp <- function(length) strrep("\u00A0", length)

cli_text_basic <- function(..., .envir = parent.frame()) {
  cat(
    cli::format_inline(..., .envir = .envir, keep_whitespace = FALSE),
    "\n",
    sep = ""
  )
}
