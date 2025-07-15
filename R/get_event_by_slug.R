#' Get a Single Event by Slug
#'
#' Convenience wrapper to retrieve a single event by its slug.
#' Returns a tibble with one row (the event), or an empty tibble with a warning if not found.
#'
#' @param slug The event slug (character, required)
#' @param ... Additional arguments passed to get_events()
#' @return A tibble with one row (the event), or empty if not found
#' @examples
#' get_event_by_slug("new-york-city-mayoral-election")
#' @export
get_event_by_slug <- function(slug, ...) {
  if (missing(slug) || is.null(slug) || !nzchar(slug)) {
    return(die_empty(cols = c("id", "slug", "title", "volume", "liquidity"), warn_msg = "'slug' must be provided."))
  }
  events <- get_events(slug = slug, ...)
  if (nrow(events) == 0) {
    warning(sprintf("No event found for slug: %s", slug), call. = FALSE)
    return(events)
  }
  tibble::as_tibble(events[1, , drop = FALSE])
}
