test_that("get_events returns a tibble", {
  result <- get_events(limit = 1)
  expect_s3_class(result, "tbl_df")
})
