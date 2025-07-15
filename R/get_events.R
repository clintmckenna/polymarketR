#' Get Events from Polymarket API
#'
#' Retrieves event data from the Polymarket Gamma API `/events` endpoint.
#' Returns a tibble with event information. On API error, returns an empty tibble with a warning.
#'
#' @param limit Maximum number of events to return (default 20)
#' @param offset Number of events to skip (default 0)
#' @param active Filter for active events (TRUE/FALSE/NULL)
#' @param closed Filter for closed events (TRUE/FALSE/NULL)
#' @param archived Filter for archived events (TRUE/FALSE/NULL)
#' @param min_liquidity Minimum liquidity filter (numeric or NULL)
#' @param max_liquidity Maximum liquidity filter (numeric or NULL)
#' @param min_volume Minimum volume filter (numeric or NULL)
#' @param max_volume Maximum volume filter (numeric or NULL)
#' @param start_date Start date filter (YYYY-MM-DD or NULL)
#' @param end_date End date filter (YYYY-MM-DD or NULL)
#' @param tag_labels Filter by tag labels (character or NULL)
#' @param order Order by field (liquidity, volume, start_date, end_date)
#' @param ascending Logical, whether to sort ascending (default FALSE)
#' @return A tibble of event data
#' @examples
#' get_events(limit = 5)
#' get_events(active = TRUE, min_liquidity = 10000)
#' @export
get_events <- function(limit = 20, offset = 0, active = NULL, closed = NULL, archived = NULL,
                      min_liquidity = NULL, max_liquidity = NULL, min_volume = NULL, max_volume = NULL,
                      start_date = NULL, end_date = NULL, tag_labels = NULL,
                      order = "liquidity", ascending = FALSE, slug = NULL) {
  base_url <- "https://gamma-api.polymarket.com/events"
  params <- list(
    limit = limit,
    offset = offset,
    active = active,
    closed = closed,
    archived = archived,
    minLiquidity = min_liquidity,
    maxLiquidity = max_liquidity,
    minVolume = min_volume,
    maxVolume = max_volume,
    startDate = start_date,
    endDate = end_date,
    tagLabels = tag_labels,
    order = order,
    ascending = tolower(as.character(ascending)),
    slug = slug
  )
  # Remove NULL params
  params <- params[!sapply(params, is.null)]
  resp <- try(httr::GET(base_url, query = params), silent = TRUE)
  if (inherits(resp, "try-error") || httr::status_code(resp) != 200) {
    return(die_empty(cols = c("id", "slug", "title", "volume", "liquidity"), warn_msg = "Failed to fetch events from API."))
  }
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  json <- try(jsonlite::fromJSON(content), silent = TRUE)
  if (inherits(json, "try-error")) {
    return(die_empty(cols = c("id", "slug", "title", "volume", "liquidity"), warn_msg = "Invalid response from API."))
  }
  # Handle both response types
  if (!is.null(json$events)) {
    events <- json$events
  } else if (is.data.frame(json) && all(c("id", "slug", "title") %in% names(json))) {
    events <- json
  } else {
    return(die_empty(cols = c("id", "slug", "title", "volume", "liquidity"), warn_msg = "Invalid response from API."))
  }
  tibble::as_tibble(events)
}
