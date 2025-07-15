test_that("extract_token_ids returns a tibble (empty if no data)", {
  result <- extract_token_ids(tibble::tibble())
  expect_s3_class(result, "tbl_df")
})
