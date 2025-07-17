#' Get User On-Chain Activity from Polymarket
#'
#' Fetches trades and activity history for a specified wallet from the Polymarket API, with optional filters.
#'
#' @param user The address of the user in question (character, required)
#' @param limit Max number of trades to return (default 100, max 500)
#' @param offset Starting index for pagination (default 0)
#' @param market Comma-separated list of market condition IDs to filter (character, optional)
#' @param type Activity types to filter (comma-separated: TRADE, SPLIT, MERGE, REDEEM, REWARD, CONVERSION)
#' @param start Start timestamp (in seconds, optional)
#' @param end End timestamp (in seconds, optional)
#' @param side Side of trade (BUY or SELL, optional)
#' @param sortBy Field to sort by (TIMESTAMP, TOKENS, CASH, optional)
#' @param sortDirection Sort order (ASC or DESC, default DESC)
#' @return A tibble of user activities with all available columns
#' @examples
#' get_user_activity(user = "0x6f05f5c...", limit = 10)
#' @export
get_user_activity <- function(user,
                             limit = 100,
                             offset = 0,
                             market = NULL,
                             type = NULL,
                             start = NULL,
                             end = NULL,
                             side = NULL,
                             sortBy = NULL,
                             sortDirection = "DESC") {
  if (missing(user) || is.null(user) || !nzchar(user)) {
    return(die_empty(cols = c("proxyWallet", "timestamp", "conditionId", "type", "size", "usdcSize", "transactionHash", "price", "asset", "side", "outcomeIndex", "title", "slug", "icon", "eventSlug", "outcome", "name", "pseudonym", "bio", "profileImage", "profileImageOptimized"), warn_msg = "'user' address must be provided."))
  }
  base_url <- "https://data-api.polymarket.com/activity"
  params <- list(user = user,
                 limit = limit,
                 offset = offset,
                 market = market,
                 type = type,
                 start = start,
                 end = end,
                 side = side,
                 sortBy = sortBy,
                 sortDirection = sortDirection)
  params <- params[!sapply(params, is.null)]
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("proxyWallet", "timestamp", "conditionId", "type", "size", "usdcSize", "transactionHash", "price", "asset", "side", "outcomeIndex", "title", "slug", "icon", "eventSlug", "outcome", "name", "pseudonym", "bio", "profileImage", "profileImageOptimized"), warn_msg = "Failed to fetch user activity from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error") || is.null(json)) {
    return(die_empty(cols = c("proxyWallet", "timestamp", "conditionId", "type", "size", "usdcSize", "transactionHash", "price", "asset", "side", "outcomeIndex", "title", "slug", "icon", "eventSlug", "outcome", "name", "pseudonym", "bio", "profileImage", "profileImageOptimized"), warn_msg = "Invalid response from API."))
  }
  if (length(json) == 0) {
    return(die_empty(cols = c("proxyWallet", "timestamp", "conditionId", "type", "size", "usdcSize", "transactionHash", "price", "asset", "side", "outcomeIndex", "title", "slug", "icon", "eventSlug", "outcome", "name", "pseudonym", "bio", "profileImage", "profileImageOptimized"), warn_msg = "No activity found for user."))
  }
  df <- tibble::as_tibble(json)
  if ("timestamp" %in% names(df)) {
    df$datetime <- as.POSIXct(as.numeric(df$timestamp), origin = "1970-01-01", tz = "UTC")
  } else {
    df$datetime <- as.POSIXct(NA)
  }
  df
}
