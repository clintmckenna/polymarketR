# polymarketR

An R package to access, analyze, and visualize Polymarket event, market, and price data using public API endpoints.

## Installation

This package is currently in development. To install the latest version from GitHub:

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install polymarketR from GitHub
devtools::install_github("clintmckenna/polymarketR")
```

## Usage Examples

```r
library(polymarketR)

# Get events
events <- get_events(limit = 5)

# Get a single event by slug
event <- get_event_by_slug("new-york-city-mayoral-election")

# Get all markets for a specific event
markets <- get_event_markets("new-york-city-mayoral-election")

# Extract token IDs for all outcomes in an event's markets
tokens <- extract_token_ids(markets)

# Get historical prices for a Yes outcome token
yes_token <- tokens$token_id[tokens$outcome == "Yes"][1]
prices <- get_prices_history(market = yes_token, interval = "1d")

# Search events by text (client-side search)
mayoral_events <- search_events_text("mayor", limit = 50)
```

## Example Workflow: Retrieve and Plot Polymarket Event Price History

Below is a full example of using the polymarketR package to search for an event, extract market and price history data, and plot a time series for Yes/No outcomes with ggplot2.

```r
# Load required libraries
library(polymarketR)
library(dplyr)
library(ggplot2)

# 1. Search for an event by text (fuzzy search)
event_results <- search_events_text("new york city mayoral election")
print(event_results)

# 2. Get event details by slug (use a known slug for stability)
event_slug <- "new-york-city-mayoral-election"
event <- get_event_by_slug(event_slug)
print(event)

# 3. Extract all markets for the event
markets <- get_event_markets(event_slug)
print(markets)

# 4. Get price history for all Yes/No tokens in the event
# Note: The interval and fidelity arguments are not always respected by the API—results may still be high-frequency.
history <- get_event_prices_history(event_slug, interval = "max", fidelity = 1440)
print(head(history))

# 5. Plot a time series of prices for all markets and outcomes
# (Here, we facet by groupItemTitle for clarity)
ggplot(history, aes(x = datetime, y = price, color = outcome)) +
  geom_line() +
  facet_wrap(~ groupItemTitle, scales = "free_y") +
  labs(
    title = "Polymarket Price History: New York City Mayoral Election",
    x = "Date",
    y = "Price (Probability)",
    color = "Outcome"
  ) +
  theme_minimal()
```

![Polymarket price history plot](polymarket_price_history.png)

**Notes:**
- Not all events/markets will have price history available for all tokens.
- The interval parameter may not always be honored exactly by the API; you may receive lower- or higher-frequency data.
- All package functions return tibbles for easy manipulation with dplyr/tidyverse tools.

Thanks and feel free to suggest any changes or improvements!