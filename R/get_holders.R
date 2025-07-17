#' Get Market Token Holders from Polymarket
#'
#' Fetches the top holders of a specified market token from the Polymarket API.
#'
#' @param market The market (conditionId) to query (character, required)
#' @param limit Maximum number of holders to return (default 100)
#' @return A tibble of token holders with all available columns
#' @examples
#' get_holders(market = "0x123...", limit = 10)
#' @export
get_holders <- function(market, limit = 100) {
  if (missing(market) || is.null(market) || !nzchar(market)) {
    return(die_empty(cols = c("proxyWallet", "bio", "asset", "pseudonym", "amount", "displayUsernamePublic", "outcomeIndex", "name", "profileImage", "profileImageOptimized"), warn_msg = "'market' (conditionId) must be provided."))
  }
  base_url <- "https://data-api.polymarket.com/holders"
  params <- list(market = market, limit = limit)
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("proxyWallet", "bio", "asset", "pseudonym", "amount", "displayUsernamePublic", "outcomeIndex", "name", "profileImage", "profileImageOptimized"), warn_msg = "Failed to fetch market holders from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error") || is.null(json$holders)) {
    return(die_empty(cols = c("proxyWallet", "bio", "asset", "pseudonym", "amount", "displayUsernamePublic", "outcomeIndex", "name", "profileImage", "profileImageOptimized"), warn_msg = "Invalid response from API."))
  }
  # If holders is a list of data.frames, bind them together
  holders <- json$holders
  if (is.list(holders) && all(sapply(holders, is.data.frame))) {
    holders <- do.call(rbind, holders)
  }
  tibble::as_tibble(holders)
}
