test_that("search_events_text returns a tibble (empty if no match)", {
  result <- search_events_text("nonexistentquery", limit = 5)
  expect_s3_class(result, "tbl_df")
})
