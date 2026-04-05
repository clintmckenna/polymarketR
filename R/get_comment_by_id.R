#' Get a Comment by ID from Polymarket
#'
#' Retrieves a single comment by its ID from the Polymarket `/comments/{id}` endpoint.
#'
#' @param comment_id The comment ID (character or numeric, required)
#' @return A tibble with one row (the comment), or an empty tibble with a warning on failure
#' @examples
#' get_comment_by_id(comment_id = "2121463")
#' @export
get_comment_by_id <- function(comment_id) {
  if (missing(comment_id) || is.null(comment_id) || !nzchar(as.character(comment_id))) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = "'comment_id' must be provided."))
  }
  url <- paste0("https://gamma-api.polymarket.com/comments/", comment_id)
  resp <- try(httr::GET(url), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = sprintf("Failed to fetch comment with ID: %s", comment_id)))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error")) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = "Invalid response from API."))
  }
  # API returns an array; convert to tibble
  if (is.data.frame(json) && nrow(json) > 0) {
    return(tibble::as_tibble(json[1, , drop = FALSE]))
  }
  die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
            warn_msg = sprintf("No comment found for ID: %s", comment_id))
}
