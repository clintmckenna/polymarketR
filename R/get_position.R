#' Get User Positions from Polymarket
#'
#' Fetches current positions for a given user address from the Polymarket API, with optional filters.
#'
#' @param user The Polygon/Profile address of the user (character, required)
#' @param market One or more market (conditionId) IDs, comma-separated (character, optional)
#' @param eventId The event ID (character, optional)
#' @param sizeThreshold Minimum position size to include (numeric, default 1)
#' @param redeemable Filter for redeemable positions (logical, optional)
#' @param mergeable Filter for mergeable positions (logical, optional)
#' @param title Filter by market title (character, optional)
#' @param limit Max number of positions to return (default 50, max 500)
#' @param offset Index to start paginated results from (default 0)
#' @param sortBy Sort criteria (character, optional)
#' @param sortDirection Sort direction: 'ASC' or 'DESC' (default 'DESC')
#' @return A tibble of user positions with all available columns
#' @examples
#' get_position(user = "0x6f05f5c...", limit = 10)
#' @export
get_position <- function(user,
                        market = NULL,
                        eventId = NULL,
                        sizeThreshold = 1,
                        redeemable = NULL,
                        mergeable = NULL,
                        title = NULL,
                        limit = 50,
                        offset = 0,
                        sortBy = NULL,
                        sortDirection = "DESC") {
  if (missing(user) || is.null(user) || !nzchar(user)) {
    return(die_empty(cols = c("proxyWallet", "asset", "conditionId", "size", "avgPrice", "initialValue", "currentValue", "cashPnl", "percentPnl", "totalBought", "realizedPnl", "percentRealizedPnl", "curPrice", "redeemable", "title", "slug", "icon", "eventSlug", "outcome", "outcomeIndex", "oppositeOutcome", "oppositeAsset", "endDate", "negativeRisk"), warn_msg = "'user' address must be provided."))
  }
  base_url <- "https://data-api.polymarket.com/positions"
  params <- list(user = user,
                 market = market,
                 eventId = eventId,
                 sizeThreshold = sizeThreshold,
                 redeemable = redeemable,
                 mergeable = mergeable,
                 title = title,
                 limit = limit,
                 offset = offset,
                 sortBy = sortBy,
                 sortDirection = sortDirection)
  # Remove NULL params
  params <- params[!sapply(params, is.null)]
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("proxyWallet", "asset", "conditionId", "size", "avgPrice", "initialValue", "currentValue", "cashPnl", "percentPnl", "totalBought", "realizedPnl", "percentRealizedPnl", "curPrice", "redeemable", "title", "slug", "icon", "eventSlug", "outcome", "outcomeIndex", "oppositeOutcome", "oppositeAsset", "endDate", "negativeRisk"), warn_msg = "Failed to fetch user positions from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error") || is.null(json)) {
    return(die_empty(cols = c("proxyWallet", "asset", "conditionId", "size", "avgPrice", "initialValue", "currentValue", "cashPnl", "percentPnl", "totalBought", "realizedPnl", "percentRealizedPnl", "curPrice", "redeemable", "title", "slug", "icon", "eventSlug", "outcome", "outcomeIndex", "oppositeOutcome", "oppositeAsset", "endDate", "negativeRisk"), warn_msg = "Invalid response from API."))
  }
  # The response is a list of positions
  if (length(json) == 0) {
    return(die_empty(cols = c("proxyWallet", "asset", "conditionId", "size", "avgPrice", "initialValue", "currentValue", "cashPnl", "percentPnl", "totalBought", "realizedPnl", "percentRealizedPnl", "curPrice", "redeemable", "title", "slug", "icon", "eventSlug", "outcome", "outcomeIndex", "oppositeOutcome", "oppositeAsset", "endDate", "negativeRisk"), warn_msg = "No positions found for user."))
  }
  tibble::as_tibble(json)
}
