#' Plot colored cells
#'
#' @description
#' Pass `plot_color()` R colors, and it will draw each color in a grid of
#' colored rectangles/cells. The background color of each cell will be the
#' specified colors. By default, the color name will be printed in the
#' foreground of the cell (in a color that contrasts with the background).
#'
#' `plot_color()` and [print_color()] are sister functions that both display
#' color cells. The primary difference is where the colors are displayed: in the
#' console or in the graphics device.
#'
#' @details
#' Drawing is handled via the [gtable][gtable::gtable-package] and
#' [grid][grid::grid-package] packages.
#'
#' If `col` is a vector, it's treated as a 1-column matrix. If `col` is a list,
#' then any vector within it is treated as a 1-row matrix.
#'
#' If `col` is a named list, the names are printed in the left margin.
#'
#' The foreground text color of each cell is determined by [bg2fg()].
#'
#' @param col A vector, matrix, or list of vectors/matrices, all containing R
#'   colors. Can be character or numeric.
#' @param label `TRUE`/`FALSE` for whether print the color names.
#' @param index `TRUE`/`FALSE` for whether to print row and column indices (as
#'   applicable).
#' @param border Border color for each cell. Use `NA` for transparent borders,
#'   or `NULL` to make borders match the cell background colors.
#'
#' @returns Invisibly returns a [gtable] (aka grob table) object.
#' @seealso [print_color()] for printing colors in the console.
#' @export
#' @examples
#' plot_color(palette()) # vertical
#' plot_color(list(palette())) # horizontal
#'
#' plot_color(matrix(rainbow(80), ncol = 8))
#'
#' # Plot all the RColorBrewer palettes
#' if (requireNamespace("RColorBrewer")) {
#'   pals <- sapply(rownames(RColorBrewer::brewer.pal.info), function(pal) {
#'     RColorBrewer::brewer.pal(Inf, pal)
#'   }) |> suppressWarnings() |> rev()
#'
#'   plot_color(pals, label = FALSE)
#' }
#'
#' # Convert 'volcano' to a matrix of colors, then plot
#' mat <- volcano
#' n <- 50
#' color_idx <- cut(mat, breaks = n, labels = FALSE)
#' color_mat <- structure(rainbow(n)[color_idx], dim = dim(mat))
#' plot_color(color_mat, label = FALSE, index = FALSE, border = NULL)
plot_color <- function(col, label = TRUE, index = TRUE,
                       border = graphics::par("bg")) {
  rlang::check_bool(label)
  rlang::check_bool(index)
  check_color(border, req_len = 1, allow_null = TRUE)

  if ((is.vector(col) && is.atomic(col)) || is.matrix(col)) {
    check_color(col)

    gt <- gtable_color_matrix(
      col,
      label = label,
      row_index = index,
      col_index = index && is.matrix(col),
      border = border
    )
  } else if (is.list(col)) {
    for (i in seq_along(col)) {
      col_i <- col[[i]]
      if (!((is.vector(col_i) && is.atomic(col_i)) || is.matrix(col_i)))
        cli::cli_abort("Element {i} of {.arg col} is not a vector or matrix.")
      check_color(col_i, arg = "col")
    }

    is_mat <- sapply(col, is.matrix)
    col <- lapply(col, \(x) if (is.matrix(x)) x else matrix(x, nrow = 1))

    ncol_max <- max(sapply(col, ncol))

    names <- names(col)
    names[names == ""] <- paste0('[[', seq_along(col), ']]')[names == ""]

    gts <- lapply(seq_along(col), function(i) {
      gtable_color_matrix(
        col[[i]],
        label = label,
        name = names[i],
        row_index = index && is_mat[i],
        col_index = index && i == 1,
        ncol_pad = ncol_max - ncol(col[[i]]),
        border = border,
        grobID = i
      )
    })

    nrow <- sum(sapply(col, nrow))
    gt <- rbind_with_spacers(
      gts,
      gap = max(grid::unit(0.2 / nrow, "npc"), grid::unit(1, "mm"))
    )
  } else {
    cli::cli_abort("{.arg col} must be a vector, matrix, or list of
                   vectors and matrices.")
  }

  grid::grid.newpage()

  if (!is.null(gt)) {
    gt <- gtable::gtable_add_padding(gt, grid::unit(4, "mm"))
    grid::grid.draw(gt)
  }

  invisible(gt)
}

# Create a gtable to display a "color matrix", i.e., a rectangular grid of
# equally sized color cells. `col` controls the background color of each cell,
# and the color name is printed in the foreground (if `label = TRUE`). The
# number of columns of the color matrix is determined by `col`, but you can pad
# empty columns to the right with `ncol_pad`. This lets you easily `rbind`
# multiple color matrix gtables by giving them all the same number of columns.
# Row and column indices are printed in the right and top margins (if `row_index
# = TRUE` and `col_index = TRUE`). Use `name` to give the matrix a name that
# will be printed on the top-left side.
gtable_color_matrix <- function(col, label = TRUE, name = NULL,
                                row_index = TRUE, col_index = TRUE,
                                ncol_pad = 0,
                                border = graphics::par("bg"), grobID = NULL) {
  col <- as.matrix(col)
  nr <- nrow(col)
  nc <- ncol(col)
  if (nr == 0L || nc == 0L)
    return(invisible(NULL))

  # A little padding for margin text
  pad <- grid::unit(3, "mm")

  index_gp <- grid::gpar(cex = 0.9)

  # Optional index grobs for columns (on top)
  if (col_index) {
    col_idx_grobs <- lapply(seq_len(nc + ncol_pad), function(j) {
      grid::textGrob(j, y = 1, just = c("center", "top"), gp = index_gp)
    })

    # Height of grobs
    h_top <- Reduce(grid::unit.pmax, lapply(col_idx_grobs, grid::grobHeight)) + pad
  } else {
    h_top <- grid::unit(0, "mm")
  }

  # Optional index grobs for rows (on right)
  if (row_index) {
    row_idx_grobs <- lapply(seq_len(nr), function(i) {
      grid::textGrob(i, x = 1, just = "right", gp = index_gp)
    })

    # Width of grobs
    w_right <- Reduce(grid::unit.pmax, lapply(row_idx_grobs, grid::grobWidth)) + pad
  } else {
    w_right <- grid::unit(0, "mm")
  }

  # Build gtable dimensions
  # Column widths: one "null" per color column; optional right index column
  width_list <- replicate(nc + ncol_pad, grid::unit(1, "null"), simplify = FALSE)
  width_list <- c(width_list, list(w_right))
  widths <- do.call(grid::unit.c, width_list)

  # Row heights: optional top header row; then one "null" per color row
  height_list <- replicate(nr, grid::unit(1, "null"), simplify = FALSE)
  height_list <- c(list(h_top), height_list)
  heights <- do.call(grid::unit.c, height_list)

  gt <- gtable::gtable(widths = widths, heights = heights)

  if (label) fg <- bg2fg(col)

  # Add color cells (rectangles, plus optional labels)
  for (i in seq_len(nr)) {
    for (j in seq_len(nc)) {
      # Cell background rectangle with border
      gt <- gtable::gtable_add_grob(
        gt,
        grobs = grid::rectGrob(gp = grid::gpar(
          fill = col[i, j],
          col = border %||% col[i, j]
        )),
        t = 1 + i,
        l = j,
        name = paste2("cell", grobID, i, j, sep = "-")
      )

      # Cell foreground text
      if (label) {
        gt <- gtable::gtable_add_grob(
          gt,
          grobs = grid::textGrob(col[i, j], gp = grid::gpar(col = fg[i, j])),
          t = 1 + i,
          l = j,
          name = paste2("label", grobID, i, j, sep = "-")
        )
      }
    }
  }

  # Row index on the right, column index on top
  if (row_index) {
    gt <- gtable::gtable_add_grob(
      gt,
      grobs = row_idx_grobs,
      t = 1 + seq_len(nr),
      l = nc + 1,
      name = paste2("rowID", grobID, seq_len(nr), sep = "-")
    )
  }
  if (col_index) {
    gt <- gtable::gtable_add_grob(
      gt,
      col_idx_grobs,
      t = 1,
      l = seq_len(nc + ncol_pad),
      name = paste2("colID", grobID, seq_len(nc + ncol_pad), sep = "-")
    )
  }

  if (!is.null(name)) {
    name_grob <- grid::textGrob(
      name,
      x = grid::unit(1, "npc") - pad,
      just = "right"
    )
    w_name <- grid::grobWidth(name_grob) + pad
    gt <- gtable::gtable_add_cols(gt, widths = w_name, pos = 0)
    gt <- gtable::gtable_add_grob(
      gt,
      grobs = name_grob,
      t = 2,
      l = 1,
      name = paste2("name", grobID, sep = "-"),
      clip = "off"
    )
  }

  gt
}

# Row-bind a list of gtables with spacer rows between them
rbind_with_spacers <- function(gts, gap = grid::unit(0.1, "null")) {
  stopifnot(is.list(gts), length(gts) >= 1L)
  stopifnot(all(vapply(gts, inherits, logical(1), what = "gtable")))
  # Assumes all gtables have the same number of columns

  # Align widths across all gtables (safer before rbind)
  w <- gts[[1]]$widths
  if (length(gts) > 1L) {
    w <- Reduce(grid::unit.pmax, lapply(gts, \(gt) gt$widths))
    gts <- lapply(gts, \(gt) { gt$widths <- w; gt })
  }

  # Spacer gtable: same column widths, single row of height = gap
  spacer <- gtable::gtable(widths = w, heights = gap)

  # Interleave: g1, spacer, g2, spacer, ..., gn
  pieces <- list(gts[[1]])
  if (length(gts) > 1L) {
    for (k in 2:length(gts)) {
      pieces <- c(pieces, list(spacer), list(gts[[k]]))
    }
  }

  do.call(rbind, pieces)
}

gtable_plot <- function(gt) {
  grid::grid.newpage()
  grid::grid.draw(gt)
}

# Custom paste that filters out length-0 objects before pasting
paste2 <- function(..., sep = " ", collapse = NULL, recycle0 = FALSE) {
  dots <- list(...)
  dots <- Filter(length, dots)
  do.call(
    paste,
    c(dots, list(sep = sep, collapse = collapse, recycle0 = recycle0))
  )
}
