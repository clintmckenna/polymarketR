test_that("get_markets returns a tibble", {
  result <- get_markets(limit = 1)
  expect_s3_class(result, "tbl_df")
})
