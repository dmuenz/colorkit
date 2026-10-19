test_that("bg2fg works", {
  expect_equal(
    bg2fg(c("white", "black", "red", "orange", "yellow", "green", "blue", "purple")),
    c("#000000", "#F8F8F8", "#000000", "#000000", "#000000", "#000000", "#F8F8F8", "#F8F8F8")
  )

  expect_equal(
    matrix(bg2fg(c("white", "black"))),
    matrix(c("#000000", "#F8F8F8"))
  )
})

test_that("bg2fg errors correctly", {
  expect_snapshot(bg2fg("waka"), error = TRUE)
  expect_snapshot(bg2fg(sum), error = TRUE)
})
