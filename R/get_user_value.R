#' Get User Holdings Value from Polymarket
#'
#' Fetches the total USD value of a user's holdings across all markets, or for specified markets, from the Polymarket API.
#'
#' @param user The address of the user in question (character, required)
#' @param market The conditionId(s) of the market(s), comma-separated (character, optional)
#' @return A tibble with columns: user, value
#' @examples
#' get_user_value(user = "0x0166a90c13a7273af742381b6cd7b098dbb00000")
#' @export
get_user_value <- function(user, market = NULL) {
  if (missing(user) || is.null(user) || !nzchar(user)) {
    return(die_empty(cols = c("user", "value"), warn_msg = "'user' address must be provided."))
  }
  base_url <- "https://data-api.polymarket.com/value"
  params <- list(user = user, market = market)
  params <- params[!sapply(params, is.null)]
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("user", "value"), warn_msg = "Failed to fetch user value from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error") || is.null(json$user) || is.null(json$value)) {
    return(die_empty(cols = c("user", "value"), warn_msg = "Invalid response from API."))
  }
  tibble::tibble(user = json$user, value = json$value)
}
