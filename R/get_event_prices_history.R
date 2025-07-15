#' Get Price History for All Markets in an Event
#'
#' Given an event slug, retrieves all markets for that event, extracts Yes/No token IDs,
#' fetches price history for each token, and returns a long-format tibble suitable for plotting/analysis.
#'
#' @param event_slug The event slug (character, required)
#' @param interval Interval for price data (e.g., "1h", "1d", "1w", "max")
#' @param ... Additional arguments passed to get_event_markets() or get_prices_history()
#' @return A tibble with columns: market_id, outcome, token_id, timestamp, price, volume, etc.
#' @examples
#' get_event_prices_history("new-york-city-mayoral-election", interval = "1d")
#' @export
get_event_prices_history <- function(event_slug, interval = "1d", ...) {
  markets <- get_event_markets(event_slug, ...)
  if (nrow(markets) == 0) {
    return(die_empty(cols = c("market_id", "outcome", "token_id", "timestamp", "price", "volume", "question", "slug", "startDate", "endDate", "datetime"), warn_msg = paste0("No markets found for event: ", event_slug)))
  }
  # Prepare long-format tokens table
  tokens <- extract_token_ids(markets, outcome = "both")
  # tokens: columns market_id, yes_token_id, no_token_id
  tokens_long <- tidyr::pivot_longer(
    tokens,
    cols = c("yes_token_id", "no_token_id"),
    names_to = "outcome",
    values_to = "token_id"
  )
  tokens_long$outcome <- ifelse(tokens_long$outcome == "yes_token_id", "Yes", "No")
  # Remove missing token_ids
  tokens_long <- tokens_long[!is.na(tokens_long$token_id) & nzchar(tokens_long$token_id), ]
  # Fetch price history for each token
  all_history <- lapply(seq_len(nrow(tokens_long)), function(i) {
    row <- tokens_long[i, ]
    ph <- get_prices_history(row$token_id, interval = interval)
    if (nrow(ph) == 0) return(NULL)
    ph$market_id <- row$market_id
    ph$outcome <- row$outcome
    ph$token_id <- row$token_id
    ph
  })
  out <- do.call(rbind, all_history)
  if (is.null(out) || nrow(out) == 0) {
    return(die_empty(cols = c("market_id", "outcome", "token_id", "timestamp", "price", "volume", "question", "slug", "startDate", "endDate", "datetime"), warn_msg = paste0("No price history found for event: ", event_slug)))
  }
  # Join market metadata
  meta_cols <- c("id", "question", "slug", "startDate", "endDate", "groupItemTitle")
  market_meta <- unique(markets[, meta_cols])
  names(market_meta)[names(market_meta) == "id"] <- "market_id"
  out <- merge(out, market_meta, by = "market_id", all.x = TRUE, sort = FALSE)
  # Add human-readable datetime column
  out$datetime <- as.POSIXct(out$timestamp, origin = "1970-01-01", tz = "UTC")
  # Reorder columns for usability
  preferred_order <- c("market_id", "slug", "question", "groupItemTitle", "startDate", "endDate", "outcome", "token_id", "timestamp", "datetime", "price", "volume")
  final_cols <- intersect(preferred_order, names(out))
  out <- out[, c(final_cols, setdiff(names(out), final_cols))]
  tibble::as_tibble(out)
}
