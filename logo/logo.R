hex_logo <- function(
  w = 700,
  h = 700,
  margin = 0.02,
  hex_w = 1,
  hex_h = 1,
  hex_border = "black",
  hex_border_w = 0.05,
  text_x = 0.5,
  text_y = 0.5,
  text_cex = 3,
  text_border = gray(150 / 255),
  warp_lx = NULL,
  warp_ly = NULL,
  warp_rx = NULL,
  warp_ry = NULL
) {
  raster <- image_warp(
    draw_expr = {
      mat <- matrix(rainbow(6 * 6), nrow = 6, byrow = TRUE)
      colorkit::plot_color(mat, index = FALSE)

      shadowtext::grid.shadowtext(
        label = "colorkit",
        x = text_x,
        y = text_y,
        gp = grid::gpar(col = "white", cex = text_cex, fontfamily = "Aller_Rg"),
        bg.colour = text_border,
        bg.r = 0.05
      )
    },
    width = w,
    height = h,
    lx = warp_lx,
    ly = warp_ly,
    rx = warp_rx,
    ry = warp_ry
  ) |>
    hex_crop(margin = margin) |>
    as.raster()

  border_raster <- raster
  border_raster[border_raster != "transparent"] <- hex_border

  grid::grid.newpage()
  grid::grid.raster(
    border_raster,
    width = hex_w * (1 + hex_border_w),
    height = hex_h * (1 + hex_border_w)
  )
  grid::grid.raster(raster, width = hex_w, height = hex_h)
}

image_warp <- function(draw_expr, width, height,
                       lx = NULL, ly = NULL,
                       rx = NULL, ry = NULL) {
  tmp_in  <- tempfile(fileext = ".png")

  # 1) Draw your regular 2D grid scene to a PNG
  ragg::agg_png(tmp_in, width = width, height = height, bg = "transparent")
  grid::grid.newpage()
  eval(draw_expr)
  dev.off()

  # 2) Read image and apply perspective distortion
  img <- magick::image_read(tmp_in)
  unlink(tmp_in)

  info <- magick::image_info(img)
  w <- info$width
  h <- info$height

  # Source corners (x,y): TL, TR, BR, BL
  # mapped to destination corners to make right side "farther"
  src <- c(
    0,   0,    # TL
    w,   0,    # TR
    w,   h,    # BR
    0,   h     # BL
  )

  lx <- lx %||% 0.11
  ly <- ly %||% 0.064
  rx <- rx %||% 0.31
  ry <- ry %||% 0.192

  dst <- c(
    lx * w,       ly * h,       # TL moves right/down (appears closer/larger)
    (1 - rx) * w, ry * h,       # TR moves left/down (appears farther)
    (1 - rx) * w, (1 - ry) * h, # BR moves left/up
    lx * w,       (1 - ly) * h  # BL
  )

  # magick expects c(x1,y1,X1,Y1, x2,y2,X2,Y2, ...)
  mapping <- as.vector(rbind(src[seq(1,8,2)], src[seq(2,8,2)],
                            dst[seq(1,8,2)], dst[seq(2,8,2)]))

  magick::image_distort(img, coordinates = mapping, bestfit = TRUE)
}

hex_crop <- function(img, margin = 0.02, pointy_top = TRUE) {
  info <- magick::image_info(img)
  w <- info$width
  h <- info$height

  cx <- w / 2
  cy <- h / 2
  r  <- min(w, h) / 2 * (1 - margin)

  start  <- if (pointy_top) pi / 6 else 0
  angles <- seq(start, by = pi / 3, length.out = 6)
  vx <- cx + r * cos(angles)
  vy <- cy + r * sin(angles)

  points_str <- paste(sprintf("%.1f,%.1f", vx, vy), collapse = " ")

  # Build an RGBA SVG where:
  #   - outside the hexagon is fully transparent
  #   - inside the hexagon is fully opaque white
  svg <- sprintf(
    '<svg width="%d" height="%d" xmlns="http://www.w3.org/2000/svg">
       <polygon points="%s" fill="white"/>
     </svg>',
    w, h, points_str
  )

  mask <- magick::image_read_svg(svg, width = w, height = h)

  # Ensure the source carries an alpha channel
  img <- magick::image_convert(img, format = "png")

  # DstIn: keeps the source (Dst) pixels only where the mask (Src) is opaque.
  # Outside the hexagon the SVG is transparent → source becomes transparent.
  magick::image_composite(img, mask, operator = "DstIn")
}

dev.off.all <- function() {
  while(!is.null(dev.list())) dev.off()
}

dev.off.all()
ragg::agg_png(width = 240 * 2, height = 278 * 2,
              filename = "logo/logo.png", background = "transparent")
hex_logo(
  w = 700,
  h = 675,
  margin = -0.1,
  hex_w = 1.02,
  hex_h = 1.26,
  hex_border = "black",
  hex_border_w = 0.04,
  text_x = 0.45,
  text_y = 0.52,
  text_cex = 10,
  text_border = grey(0 / 255),
  warp_lx = 0.11,
  warp_ly = 0.064,
  warp_rx = 0.31,
  warp_ry = 0.24
)
dev.off.all()

tinyimg::tinypng(
  "logo/logo.png",
  "logo/logo.png",
  level = 4L,
  alpha = TRUE,
  lossy = 2.3
)

plotpeek::peek("logo/logo.png")

file.copy(from = "logo/logo.png",
          to = "man/figures/",
          overwrite = TRUE)
