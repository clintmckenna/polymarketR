test_that("search_events returns a tibble (empty if no match)", {
  result <- search_events("nonexistentquery", limit_per_type = 5, max_pages = 1)
  expect_s3_class(result, "tbl_df")
})
