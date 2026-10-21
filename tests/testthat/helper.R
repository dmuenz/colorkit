# wrapper around vdiffr::expect_doppelganger
expect_doppelganger <- function(title, fig, ...) {
  fig_wrapper <- function() {
    fig
    grid::grid.text(
      paste("snapshot:", title),
      x = grid::unit(1, "npc") - grid::unit(1, "mm"),
      y = grid::unit(1, "mm"),
      just = c("right", "bottom"),
      gp = grid::gpar(fontsize = 10)
    )
  }

  if (interactive()) {
    cli::cli_alert_info("Can't save or compare snapshot to reference when
                        testing interactively.")
    fig_wrapper()
  } else {
    vdiffr::expect_doppelganger(title, fig_wrapper(), ...)
  }
}
