#' Get a Single Event by Slug
#'
#' Retrieves a single event by its slug using the dedicated `/events/slug/{slug}` endpoint.
#' If the slug is not found as an event, falls back to looking it up as a market slug
#' and resolving the parent event. This allows passing either event or market slugs
#' (e.g. slugs ending in a numeric suffix like "-914").
#'
#' @param slug The event or market slug (character, required)
#' @return A tibble with one row (the event), or empty if not found
#' @examples
#' get_event_by_slug("new-york-city-mayoral-election")
#' get_event_by_slug("will-stephen-a-smith-win-the-2028-democratic-presidential-nomination-914")
#' @export
get_event_by_slug <- function(slug) {
  if (missing(slug) || is.null(slug) || !nzchar(slug)) {
    return(die_empty(cols = c("id", "slug", "title", "volume", "liquidity"), warn_msg = "'slug' must be provided."))
  }
  # Try the dedicated event slug endpoint first
  event_url <- paste0("https://gamma-api.polymarket.com/events/slug/", slug)
  resp <- try(httr::GET(event_url), silent = TRUE)
  if (!inherits(resp, "try-error") && httr::status_code(resp) == 200) {
    content <- httr::content(resp, as = "text", encoding = "UTF-8")
    # Wrap single object in array so fromJSON produces a one-row data.frame with list columns preserved
    json <- try(jsonlite::fromJSON(paste0("[", content, "]")), silent = TRUE)
    if (!inherits(json, "try-error") && is.data.frame(json) && nrow(json) > 0) {
      return(tibble::as_tibble(json[1, , drop = FALSE]))
    }
  }
  # Fallback: try as a market slug and resolve the parent event
  market_resp <- try(httr::GET("https://gamma-api.polymarket.com/markets", query = list(slug = slug)), silent = TRUE)
  if (!inherits(market_resp, "try-error") && httr::status_code(market_resp) == 200) {
    market_content <- httr::content(market_resp, as = "text", encoding = "UTF-8")
    market_json <- try(jsonlite::fromJSON(market_content), silent = TRUE)
    if (!inherits(market_json, "try-error") && is.data.frame(market_json) && nrow(market_json) > 0) {
      # Extract parent event slug from the market's events field
      event_slug <- NULL
      if (!is.null(market_json$events)) {
        events_data <- market_json$events
        if (is.list(events_data) && length(events_data) > 0) {
          first_event <- events_data[[1]]
          if (is.data.frame(first_event) && "slug" %in% names(first_event)) {
            event_slug <- first_event$slug[1]
          } else if (is.list(first_event) && "slug" %in% names(first_event)) {
            event_slug <- first_event$slug
          }
        }
      }
      if (!is.null(event_slug) && nzchar(event_slug)) {
        # Recursively fetch the actual parent event
        return(get_event_by_slug(event_slug))
      }
    }
  }
  warning(sprintf("No event found for slug: %s", slug), call. = FALSE)
  die_empty(cols = c("id", "slug", "title", "volume", "liquidity"), warn_msg = sprintf("No event found for slug: %s", slug))
}
