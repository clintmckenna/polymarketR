test_that("get_event_by_slug returns a tibble (empty if not found)", {
  result <- get_event_by_slug("new-york-city-mayoral-election")
  expect_s3_class(result, "tbl_df")
})
