#' Get Comments by User Address from Polymarket
#'
#' Retrieves comments posted by a specific user from the Polymarket
#' `/comments/user_address/{user_address}` endpoint.
#'
#' @param user_address The user's wallet address (character, required)
#' @param limit Maximum number of comments to return (default 20)
#' @param offset Number of comments to skip for pagination (default 0)
#' @param order Comma-separated list of fields to order by (optional)
#' @return A tibble of comments, or an empty tibble with a warning on failure
#' @examples
#' get_comments_by_user(user_address = "0xdf3a93d5475b74c88cb52b60340e9be58d156a8a")
#' @export
get_comments_by_user <- function(user_address, limit = 20, offset = 0, order = NULL) {
  if (missing(user_address) || is.null(user_address) || !nzchar(user_address)) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = "'user_address' must be provided."))
  }
  base_url <- paste0("https://gamma-api.polymarket.com/comments/user_address/", user_address)
  params <- list(
    limit = limit,
    offset = offset,
    order = order
  )
  params <- params[!sapply(params, is.null)]
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = sprintf("Failed to fetch comments for user: %s", user_address)))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error") || !is.data.frame(json) || nrow(json) == 0) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = sprintf("No comments found for user: %s", user_address)))
  }
  tibble::as_tibble(json)
}
