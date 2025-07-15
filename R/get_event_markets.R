#' Get All Markets for a Given Event
#'
#' Convenience wrapper to retrieve all markets for a given event by slug.
#' Returns a tibble with all markets for the event, or an empty tibble with a warning if none found.
#'
#' @param event_slug The event slug (character, required)
#' @param ... Additional arguments passed to get_markets()
#' @return A tibble of markets for the event, or empty if none found
#' @examples
#' get_event_markets("new-york-city-mayoral-election")
#' # Uses event ID lookup for precise filtering

#' @export
get_event_markets <- function(event_slug, ...) {
  if (missing(event_slug) || is.null(event_slug) || !nzchar(event_slug)) {
    return(die_empty(cols = c("id", "slug", "question", "outcomes", "outcomePrices", "volume", "liquidity"), warn_msg = "'event_slug' must be provided."))
  }
  event <- get_event_by_slug(event_slug)
  if (nrow(event) == 0 || is.null(event$markets[[1]])) {
    warning(sprintf("No event or markets found for slug: %s", event_slug), call. = FALSE)
    return(die_empty(cols = c("id", "slug", "question", "outcomes", "outcomePrices", "volume", "liquidity"), warn_msg = sprintf("No event or markets found for slug: %s", event_slug)))
  }
  markets <- event$markets[[1]]
  # Filter out markets with zero liquidity
  if (!is.null(markets$liquidity)) {
    markets <- markets[as.numeric(markets$liquidity) > 0, ]
  }
  if (nrow(markets) == 0) {
    warning(sprintf("No nonzero-liquidity markets found for event: %s", event_slug), call. = FALSE)
    return(die_empty(cols = c("id", "slug", "question", "outcomes", "outcomePrices", "volume", "liquidity", "yes_token_id", "no_token_id"), warn_msg = sprintf("No nonzero-liquidity markets found for event: %s", event_slug)))
  }
  # Add yes_token_id and no_token_id columns by parsing JSON strings
  yes_token_id <- rep(NA_character_, nrow(markets))
  no_token_id <- rep(NA_character_, nrow(markets))
  for (i in seq_len(nrow(markets))) {
    ids <- NA
    # Try clobTokenIds first
    if (!is.null(markets$clobTokenIds) && !is.na(markets$clobTokenIds[i])) {
      parsed <- try(jsonlite::fromJSON(markets$clobTokenIds[i]), silent = TRUE)
      if (!inherits(parsed, "try-error") && length(parsed) >= 2) {
        ids <- parsed
      }
    }
    # Fallback to tokenIds
    if (all(is.na(ids)) && !is.null(markets$tokenIds) && !is.na(markets$tokenIds[i])) {
      parsed <- try(jsonlite::fromJSON(markets$tokenIds[i]), silent = TRUE)
      if (!inherits(parsed, "try-error") && length(parsed) >= 2) {
        ids <- parsed
      }
    }
    if (!all(is.na(ids))) {
      yes_token_id[i] <- as.character(ids[1])
      no_token_id[i] <- as.character(ids[2])
    }
  }
  markets$yes_token_id <- yes_token_id
  markets$no_token_id <- no_token_id
  tibble::as_tibble(markets)
}
