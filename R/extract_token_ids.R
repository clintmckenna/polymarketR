#' Extract Token IDs from Market Data
#'
#' Helper to extract token IDs for Yes/No outcomes from market data.
#' Returns a tibble with market_id, outcome, and token_id columns.
#'
#' @param market_data Tibble/data.frame of markets (as returned by get_markets/get_event_markets)
#' @param outcome Which outcomes to extract: "both", "yes", or "no"
#' @return A tibble with columns: market_id, outcome, token_id
#' @examples
#' markets <- get_event_markets("new-york-city-mayoral-election")
#' extract_token_ids(markets, outcome = "both")
#' @export
extract_token_ids <- function(market_data, outcome = c("both", "yes", "no")) {
  outcome <- match.arg(outcome)
  if (is.null(market_data) || nrow(market_data) == 0 || is.null(market_data$clobTokenIds)) {
    if (outcome == "both") {
      return(die_empty(cols = c("market_id", "yes_token_id", "no_token_id"), warn_msg = "No market data or token IDs found."))
    } else {
      return(die_empty(cols = c("market_id", "outcome", "token_id"), warn_msg = "No market data or token IDs found."))
    }
  }
  ids <- market_data$clobTokenIds
  if (is.character(ids)) ids <- lapply(ids, jsonlite::fromJSON)
  out_names <- c("Yes", "No")
  rows <- lapply(seq_along(ids), function(i) {
    tokens <- ids[[i]]
    if (length(tokens) < 2) tokens <- c(tokens, rep(NA, 2 - length(tokens)))
    tibble::tibble(
      market_id = market_data$id[i],
      yes_token_id = tokens[1],
      no_token_id = tokens[2]
    )
  })
  wide_df <- do.call(rbind, rows)
  if (outcome == "both") {
    return(tibble::as_tibble(wide_df))
  }
  # For long format (yes or no)
  long_df <- tidyr::pivot_longer(
    tibble::as_tibble(wide_df),
    cols = c("yes_token_id", "no_token_id"),
    names_to = "outcome",
    values_to = "token_id"
  )
  long_df$outcome <- ifelse(long_df$outcome == "yes_token_id", "Yes", "No")
  if (outcome == "yes") long_df <- long_df[long_df$outcome == "Yes", ]
  if (outcome == "no") long_df <- long_df[long_df$outcome == "No", ]
  tibble::as_tibble(long_df)
}
