#' Search Events by Text (Client-Side)
#'
#' Performs a client-side search of event titles and descriptions for a query string.
#' Returns a tibble of matching events. Uses get_events() to fetch events.
#'
#' @param query Search string (character, required)
#' @param limit Number of events to fetch from API before searching (default 100)
#' @param ... Additional arguments passed to get_events()
#' @return A tibble of events matching the query
#' @examples
#' search_events_text("mayor", limit = 50)
#' @export
search_events_text <- function(query, limit = 100, ...) {
  if (missing(query) || is.null(query) || !nzchar(query)) {
    return(die_empty(cols = c("id", "slug", "title", "volume", "liquidity"), warn_msg = "'query' must be provided."))
  }
  events <- get_events(limit = limit, ...)
  if (nrow(events) == 0) return(events)
  matches <- grepl(query, events$title, ignore.case = TRUE) |
             grepl(query, events$description, ignore.case = TRUE)
  out <- events[matches, , drop = FALSE]
  if (nrow(out) == 0) warning(sprintf("No events found matching query: %s", query), call. = FALSE)
  tibble::as_tibble(out)
}
