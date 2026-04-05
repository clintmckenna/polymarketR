test_that("get_comment_by_id returns a tibble (empty if invalid)", {
  result <- get_comment_by_id("")
  expect_s3_class(result, "tbl_df")
})
