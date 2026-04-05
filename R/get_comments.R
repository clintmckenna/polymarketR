#' List Comments from Polymarket
#'
#' Retrieves comments for a given entity (event, series, or market) from the Polymarket
#' `/comments` endpoint. You can provide either a `slug` (for events) or both
#' `parent_entity_type` and `parent_entity_id`. If `slug` is provided, the event ID
#' is resolved automatically via `get_event_by_slug()`, which also accepts market slugs.
#'
#' @param parent_entity_type The entity type: "Event", "Series", or "market" (character). Required if `slug` is not provided.
#' @param parent_entity_id The entity ID (numeric or character). Required if `slug` is not provided.
#' @param slug An event or market slug (character, optional). If provided, overrides `parent_entity_type` and `parent_entity_id`.
#' @param limit Maximum number of comments to return (default 20)
#' @param offset Number of comments to skip for pagination (default 0)
#' @param order Comma-separated list of fields to order by (optional)
#' @return A tibble of comments, or an empty tibble with a warning on failure
#' @examples
#' get_comments(slug = "new-york-city-mayoral-election")
#' get_comments(parent_entity_type = "Event", parent_entity_id = 23246)
#' @export
get_comments <- function(parent_entity_type = NULL, parent_entity_id = NULL, slug = NULL, limit = 20, offset = 0, order = NULL) {
  # If slug is provided, resolve to event ID
  if (!is.null(slug) && nzchar(slug)) {
    event <- get_event_by_slug(slug)
    if (nrow(event) == 0) {
      return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                       warn_msg = sprintf("No event found for slug: %s", slug)))
    }
    parent_entity_type <- "Event"
    parent_entity_id <- event[["id"]][1]
  }
  if (is.null(parent_entity_type) || !nzchar(parent_entity_type)) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = "'parent_entity_type' (or 'slug') must be provided."))
  }
  if (is.null(parent_entity_id)) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = "'parent_entity_id' (or 'slug') must be provided."))
  }
  base_url <- "https://gamma-api.polymarket.com/comments"
  params <- list(
    parent_entity_type = parent_entity_type,
    parent_entity_id = parent_entity_id,
    limit = limit,
    offset = offset,
    order = order
  )
  params <- params[!sapply(params, is.null)]
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = "Failed to fetch comments from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error") || !is.data.frame(json) || nrow(json) == 0) {
    return(die_empty(cols = c("id", "body", "parentEntityType", "parentEntityID", "userAddress", "createdAt"),
                     warn_msg = "No comments found."))
  }
  tibble::as_tibble(json)
}
