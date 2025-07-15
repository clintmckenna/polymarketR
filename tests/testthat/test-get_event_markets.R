test_that("get_event_markets returns a tibble (empty if not found)", {
  result <- get_event_markets("new-york-city-mayoral-election")
  expect_s3_class(result, "tbl_df")
})
