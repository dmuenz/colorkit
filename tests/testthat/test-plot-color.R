test_that("plot_color works", {
  skip_if_not_installed("vdiffr")

  expect_doppelganger(
    "rainbow vector",
    plot_color(rainbow(5))
  )

  expect_doppelganger(
    "rainbow list-vector",
    plot_color(list(rainbow(5)))
  )

  expect_doppelganger(
    "rainbow matrix",
    plot_color(matrix(rainbow(4), ncol = 2))
  )

  expect_doppelganger(
    "rainbow list-vector-matrix",
    plot_color(list(
      vector = rainbow(5),
      matrix = matrix(rainbow(2 * 10), ncol = 2)
    ))
  )

  expect_doppelganger(
    "rainbow vector no label",
    plot_color(rainbow(5), label = FALSE)
  )

  expect_doppelganger(
    "rainbow matrix no index",
    plot_color(matrix(rainbow(4), ncol = 2), index = FALSE)
  )

  expect_doppelganger(
    "rainbow vector border red",
    plot_color(rainbow(5), border = "red")
  )

  expect_doppelganger(
    "rainbow vector cex-label large",
    plot_color(rainbow(5), cex_label = 2)
  )
})


test_that("plot_color errors correctly", {
  expect_snapshot(plot_color("waka"), error = TRUE)
  expect_snapshot(plot_color(sum), error = TRUE)
  expect_snapshot(plot_color(list(sum)), error = TRUE)

  expect_snapshot(plot_color("red", label = 0), error = TRUE)
  expect_snapshot(plot_color("red", label = rep(TRUE, 2)), error = TRUE)

  expect_snapshot(plot_color("red", index = 0), error = TRUE)
  expect_snapshot(plot_color("red", index = rep(TRUE, 2)), error = TRUE)

  expect_snapshot(plot_color("red", border = sum), error = TRUE)
  expect_snapshot(plot_color("red", border = rep("black", 2)), error = TRUE)

  expect_snapshot(plot_color("red", cex_label = sum), error = TRUE)
  expect_snapshot(plot_color("red", cex_label = rep(1, 2)), error = TRUE)
  expect_snapshot(plot_color("red", cex_label = Inf), error = TRUE)
})
