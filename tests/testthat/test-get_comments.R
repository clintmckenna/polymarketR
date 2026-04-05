test_that("get_comments returns a tibble", {
  result <- get_comments(parent_entity_type = "Event", parent_entity_id = 23246, limit = 2)
  expect_s3_class(result, "tbl_df")
})
