#' Search Polymarket Events by Query with Pagination
#'
#' Uses the public-search endpoint to find events matching a query string,
#' paginating through all results automatically.
#'
#' @param query Search string (character, required)
#' @param events_tag Optional tag filter (e.g. "nba")
#' @param events_status Optional status filter ("active", "closed", etc.)
#' @param keep_closed_markets Include closed markets (0 or 1, default 1)
#' @param limit_per_type Results per page per type (default 20)
#' @param max_pages Maximum pages to fetch (default 50, set NULL for unlimited)
#' @return A tibble of matching events
#' @examples
#' search_events("NBA", events_tag = "nba", keep_closed_markets = 1)
#' @export
search_events <- function(query,
                          events_tag = NULL,
                          events_status = NULL,
                          keep_closed_markets = 1,
                          limit_per_type = 20,
                          max_pages = 50) {

  base_url <- "https://gamma-api.polymarket.com/public-search"
  all_events <- list()
  page <- 1

  repeat {
    params <- list(
      q = query,
      limit_per_type = limit_per_type,
      page = page,
      keep_closed_markets = keep_closed_markets,
      search_tags = FALSE,
      search_profiles = FALSE
    )
    if (!is.null(events_tag))    params$events_tag   <- events_tag
    if (!is.null(events_status)) params$events_status <- events_status

    resp <- try(httr::GET(base_url, query = params), silent = TRUE)
    if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
      warning(sprintf("Failed on page %d", page))
      break
    }

    content <- httr::content(resp, as = "text", encoding = "UTF-8")
    json <- try(jsonlite::fromJSON(content, simplifyDataFrame = TRUE), silent = TRUE)
    if (inherits(json, "try-error") || is.null(json$events)) break

    all_events[[page]] <- json$events

    has_more <- isTRUE(json$pagination$hasMore)
    if (!has_more) break
    if (!is.null(max_pages) && page >= max_pages) break

    page <- page + 1
    Sys.sleep(0.2)  # be polite
  }

  if (length(all_events) == 0) {
    warning("No events found.")
    return(tibble::tibble())
  }

  dplyr::bind_rows(all_events) %>% tibble::as_tibble()
}
