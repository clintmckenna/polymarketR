test_that("get_comments_by_user returns a tibble (empty if invalid)", {
  result <- get_comments_by_user("")
  expect_s3_class(result, "tbl_df")
})
