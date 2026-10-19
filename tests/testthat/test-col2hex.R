test_that("col2hex works", {
  expect_equal(col2hex("red"), "#FF0000")
  expect_equal(col2hex("#facf"), "#FFAACC")
  expect_equal(col2hex(1), "#000000")
  expect_equal(col2hex("1.5"), "#000000")
  expect_equal(col2hex("1.99999999999999999999999999999999"), "#DF536B")
  expect_equal(col2hex(0.5), "#FFFFFF00")
  expect_equal(col2hex(NA), "#FFFFFF00")

  v_a <- c("red", "#facf")
  v_e <- c("#FF0000", "#FFAACC")
  expect_equal(col2hex(v_a), v_e)

  m_a <- matrix(v_a)
  m_e <- matrix(v_e)
  expect_equal(col2hex(m_a), m_e)

  rm_a <- as.raster(m_a)
  rm_e <- as.raster(m_e)
  expect_equal(col2hex(rm_a), rm_e)
})

test_that("col2hex errors correctly", {
  expect_snapshot(col2hex("waka"), error = TRUE)
  expect_snapshot(col2hex(-1), error = TRUE)
  expect_snapshot(col2hex("#"), error = TRUE)
  expect_snapshot(col2hex("#fa"), error = TRUE)
  expect_snapshot(col2hex(sum), error = TRUE)
})
