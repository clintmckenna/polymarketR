#' Get Historical Prices from Polymarket API
#'
#' Retrieves historical price data for a market token from the Polymarket `/prices-history` endpoint.
#' Returns a tibble with timestamped price data. On API error, returns an empty tibble with a warning.
#'
#' @param market The CLOB token ID (character, required)
#' @param start_ts Start timestamp (Unix epoch seconds, optional)
#' @param end_ts End timestamp (Unix epoch seconds, optional)
#' @param interval Interval for data points (e.g., "1h", "1d", "1w", "max")
#' @param fidelity Resolution in minutes (optional)
#' @return A tibble of historical price data
#' @examples
#' get_prices_history(market = "12541509255877010177934715422358422748052378132651567836811989084820478865881", interval = "1d")
#' @export
get_prices_history <- function(market, start_ts = NULL, end_ts = NULL, interval = "1d", fidelity = NULL) {
  # Polymarket API requires either interval or startTs/endTs
  if (is.null(interval) && is.null(start_ts) && is.null(end_ts)) {
    interval <- "1d" # Default to daily if nothing supplied
  }
  if (missing(market) || is.null(market) || !nzchar(market)) {
    return(die_empty(cols = c("timestamp", "price", "volume"), warn_msg = "'market' (token ID) must be provided."))
  }
  base_url <- "https://clob.polymarket.com/prices-history"
  params <- list(
    market = market,
    startTs = start_ts,
    endTs = end_ts,
    interval = interval,
    fidelity = fidelity
  )
  # Remove NULL params
  params <- params[!sapply(params, is.null)]
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("timestamp", "price", "volume"), warn_msg = "Failed to fetch historical prices from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  # Handle both {"prices": ...} and {"history": ...} response structures
  if (inherits(json, "try-error")) {
    return(die_empty(cols = c("timestamp", "price", "volume"), warn_msg = "Invalid response from API."))
  }
  if (!is.null(json$prices)) {
    prices <- json$prices
  } else if (!is.null(json$history)) {
    prices <- json$history
    # Rename columns if needed for compatibility
    if (!is.null(prices$t)) names(prices)[names(prices) == "t"] <- "timestamp"
    if (!is.null(prices$p)) names(prices)[names(prices) == "p"] <- "price"
  } else {
    return(die_empty(cols = c("timestamp", "price", "volume"), warn_msg = "Invalid response from API."))
  }
  tibble::as_tibble(prices)
}
