#' Get Markets from Polymarket API
#'
#' Retrieves market data from the Polymarket Gamma API `/markets` endpoint.
#' Returns a tibble with market information. On API error, returns an empty tibble with a warning.
#'
#' @param limit Maximum number of markets to return (default 20)
#' @param offset Number of markets to skip (default 0)
#' @param active Filter for active markets (TRUE/FALSE/NULL)
#' @param closed Filter for closed markets (TRUE/FALSE/NULL)
#' @param event_slug Filter by event slug (character or NULL)
#' @param market_slug Filter by market slug (character or NULL)
#' @return A tibble of market data
#' @examples
#' get_markets(limit = 5)
#' get_markets(event_slug = "new-york-city-mayoral-election")
#' @export
get_markets <- function(limit = 20, offset = 0, active = NULL, closed = NULL, event = NULL, event_slug = NULL, market_slug = NULL) {
  base_url <- "https://gamma-api.polymarket.com/markets"
  params <- list(
    limit = limit,
    offset = offset,
    active = active,
    closed = closed,
    event = event, # event ID for filtering markets by event
    eventSlug = event_slug, # legacy/deprecated
    slug = market_slug
  )
  # Remove NULL params
  params <- params[!sapply(params, is.null)]
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("id", "slug", "question", "outcomes", "outcomePrices", "volume", "liquidity"), warn_msg = "Failed to fetch markets from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error")) {
    return(die_empty(cols = c("id", "slug", "question", "outcomes", "outcomePrices", "volume", "liquidity"), warn_msg = "Invalid response from API."))
  }
  # Handle both response types
  if (!is.null(json$markets)) {
    markets <- json$markets
  } else if (is.data.frame(json) && all(c("id", "slug", "question") %in% names(json))) {
    markets <- json
  } else {
    return(die_empty(cols = c("id", "slug", "question", "outcomes", "outcomePrices", "volume", "liquidity"), warn_msg = "Invalid response from API."))
  }
  tibble::as_tibble(markets)
}
