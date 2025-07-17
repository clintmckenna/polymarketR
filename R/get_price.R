#' Get the Best Bid or Ask Price for a Token
#'
#' Retrieves the best bid (buy) or ask (sell) price for a given market token from the Polymarket CLOB API.
#'
#' @param token_id The token ID (character, required)
#' @param side The side to query: 'buy' (best bid) or 'sell' (best ask) (character, required)
#' @return A tibble with columns: token_id, side, price (numeric)
#' @examples
#' get_price("71321045679252212594626385532706912750332728571942532289631379312455583992563", side = "buy")
#' @export
get_price <- function(token_id, side = c("buy", "sell")) {
  side <- match.arg(side)
  if (missing(token_id) || is.null(token_id) || !nzchar(token_id)) {
    return(die_empty(cols = c("token_id", "side", "price"), warn_msg = "'token_id' must be provided."))
  }
  base_url <- "https://clob.polymarket.com/price"
  params <- list(token_id = token_id, side = side)
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("token_id", "side", "price"), warn_msg = "Failed to fetch price from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error") || is.null(json$price)) {
    return(die_empty(cols = c("token_id", "side", "price"), warn_msg = "Invalid response from API."))
  }
  tibble::tibble(token_id = token_id, side = side, price = as.numeric(json$price))
}
