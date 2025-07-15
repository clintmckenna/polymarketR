# Internal utility functions for polymarketR

#' Issue a warning and return an empty tibble
die_empty <- function(cols = NULL, warn_msg = "API request failed") {
  if (!is.null(cols)) {
    out <- tibble::as_tibble(setNames(replicate(length(cols), logical(0), simplify = FALSE), cols))
  } else {
    out <- tibble::tibble()
  }
  warning(warn_msg, call. = FALSE)
  return(out)
}
