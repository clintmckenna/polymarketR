test_that("get_prices_history returns a tibble (empty if no market)", {
  result <- get_prices_history("")
  expect_s3_class(result, "tbl_df")
})
