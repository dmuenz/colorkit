test_that("rand_color works", {
  expect_equal(rand_color(n = 0), character(0))

  mix1000 <- rand_color(n = 1000)
  expect_length(mix1000, 1000)
  expect_type(mix1000, "character")
  expect_equal(sum(grepl("^#", mix1000)), 500)
  expect_all_equal(nchar(mix1000[grepl("^#", mix1000)]), 7)
  expect_no_error(check_color(mix1000))

  hex1000 <- rand_color(n = 1000, hex = TRUE)
  expect_length(hex1000, 1000)
  expect_type(hex1000, "character")
  expect_all_true(grepl("^#", hex1000))
  expect_all_equal(nchar(hex1000), 7)
  expect_no_error(check_color(hex1000))

  name1000 <- rand_color(n = 1000, hex = FALSE)
  expect_length(name1000, 1000)
  expect_type(name1000, "character")
  expect_all_false(grepl("^#", name1000))
  expect_no_error(check_color(name1000))

  hex1000_alpha <- rand_color(n = 1000, hex = TRUE, alpha = TRUE)
  expect_length(hex1000_alpha, 1000)
  expect_type(hex1000_alpha, "character")
  expect_all_true(grepl("^#", hex1000_alpha))
  expect_in(nchar(hex1000_alpha), c(7, 9))
  expect_no_error(check_color(hex1000_alpha))
})

test_that("rand_color errors correctly", {
  expect_snapshot(rand_color(n = -1), error = TRUE)

  expect_snapshot(rand_color(hex = -1), error = TRUE)
  expect_snapshot(rand_color(hex = 2), error = TRUE)
  expect_snapshot(rand_color(hex = "a"), error = TRUE)

  expect_snapshot(rand_color(alpha = 1), error = TRUE)
})
