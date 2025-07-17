#' Get Order Book Summary for a Token (Long Format)
#'
#' Retrieves the order book summary (bids and asks) for a given market token from the Polymarket CLOB API and returns a long-format tibble.
#'
#' @param token_id The token ID (character, required)
#' @param side Which side(s) to return: 'bid', 'ask', or 'both' (default)
#' @return A tibble with columns: token_id, market, asset_id, hash, timestamp, datetime, side, price, size
#' @examples
#' get_book("71321045679252212594626385532706912750332728571942532289631379312455583992563")
#' get_book("71321045679252212594626385532706912750332728571942532289631379312455583992563", side = "bid")
#' @export
get_book <- function(token_id, side = c("both", "bid", "ask")) {
  side <- match.arg(side)
  if (missing(token_id) || is.null(token_id) || !nzchar(token_id)) {
    return(die_empty(cols = c("token_id", "market", "asset_id", "hash", "timestamp", "datetime", "side", "price", "size"), warn_msg = "'token_id' must be provided."))
  }
  base_url <- "https://clob.polymarket.com/book"
  params <- list(token_id = token_id)
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("token_id", "market", "asset_id", "hash", "timestamp", "datetime", "side", "price", "size"), warn_msg = "Failed to fetch order book from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error") || (is.null(json$bids) && is.null(json$asks))) {
    return(die_empty(cols = c("token_id", "market", "asset_id", "hash", "timestamp", "datetime", "side", "price", "size"), warn_msg = "Invalid response from API."))
  }
  # Convert bids and asks to tibbles, add side column
  bids <- tibble::as_tibble(json$bids)
  if (nrow(bids) > 0) bids$side <- "bid"
  asks <- tibble::as_tibble(json$asks)
  if (nrow(asks) > 0) asks$side <- "ask"
  # Combine
  book <- dplyr::bind_rows(bids, asks)
  if (nrow(book) == 0) {
    return(die_empty(cols = c("token_id", "market", "asset_id", "hash", "timestamp", "datetime", "side", "price", "size"), warn_msg = "No order book data returned by API."))
  }
  # Add metadata columns
  book$token_id <- token_id
  book$market <- if (!is.null(json$market)) json$market else NA_character_
  book$asset_id <- if (!is.null(json$asset_id)) json$asset_id else NA_character_
  book$hash <- if (!is.null(json$hash)) json$hash else NA_character_
  book$timestamp <- if (!is.null(json$timestamp)) json$timestamp else NA_character_
  # Add human-readable datetime (timestamp is in ms)
  book$datetime <- if (!is.null(json$timestamp)) as.POSIXct(as.numeric(json$timestamp)/1000, origin = "1970-01-01", tz = "UTC") else as.POSIXct(NA)
  # Filter by side argument
  if (side != "both") {
    book <- book[book$side == side, , drop = FALSE]
  }
  # Reorder columns
  book <- book[, c("token_id", "market", "asset_id", "hash", "timestamp", "datetime", "side", "price", "size")]
  tibble::as_tibble(book)
}
