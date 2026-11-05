test_that("print_color works", {
  pal <- c("black", "#DF536B", "turquoise", "#2297E6")
  pal_mat <- matrix(pal, ncol = 2)

  expect_snapshot(print_color(pal, num_colors = 256^3))
  expect_snapshot(print_color(pal, num_colors = 256))
  expect_snapshot(print_color(pal, num_colors = 8))

  expect_snapshot(print_color(pal, quote = TRUE, num_colors = 256^3))
  expect_snapshot(print_color(pal, width = 1, num_colors = 256^3))
  expect_snapshot(print_color(pal, gap = 2, num_colors = 256^3))

  expect_snapshot(print_color(pal_mat, num_colors = 256^3))

  expect_snapshot(print_color(pal_mat, quote = TRUE, num_colors = 256^3))
  expect_snapshot(print_color(pal_mat, width = 1, num_colors = 256^3))
  expect_snapshot(print_color(pal_mat, gap = 2, num_colors = 256^3))

  expect_snapshot(print_color(
    list(pal, pal_mat, "red", "blue") |>
      stats::setNames(c("", "syntactic", "non-syntactic", NA)),
    num_colors = 256^3
  ))

  reds1000 <- rep("red", 1000)
  expect_snapshot(print_color(reds1000, max = 10, num_colors = 256^3))
  expect_snapshot(print_color(
    matrix(reds1000, ncol = 50),
    max = 100,
    num_colors = 256^3
  ))
})

test_that("print_color errors correctly", {
  expect_snapshot(print_color("waka"), error = TRUE)
  expect_snapshot(print_color("#oops"), error = TRUE)
  expect_snapshot(print_color(sum), error = TRUE)
  expect_snapshot(print_color(list(sum)), error = TRUE)

  expect_snapshot(print_color("red", quote = 0), error = TRUE)
  expect_snapshot(print_color("red", quote = rep(TRUE, 2)), error = TRUE)

  expect_snapshot(print_color("red", width = 0), error = TRUE)
  expect_snapshot(print_color("red", width = rep(1, 2)), error = TRUE)

  expect_snapshot(print_color("red", gap = -1), error = TRUE)
  expect_snapshot(print_color("red", gap = rep(1, 2)), error = TRUE)

  expect_snapshot(print_color("red", max = -1), error = TRUE)
  expect_snapshot(print_color("red", max = rep(1, 2)), error = TRUE)

  expect_snapshot(print_color("red", count = 0), error = TRUE)
  expect_snapshot(print_color("red", count = rep(TRUE, 2)), error = TRUE)
})
