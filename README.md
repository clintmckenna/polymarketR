# polymarketR

An R package to access, analyze, and visualize [Polymarket](https://polymarket.com) event, market, and price data using public API endpoints.

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
# Load required libraries
library(polymarketR)
library(dplyr)
library(ggplot2)

# 1. Search for an event by text (fuzzy search)
event_results <- search_events_text("new york city mayoral election")
print(event_results)

# 2. Get event details by slug (use a known slug for stability)
# Suppose we want to look at the 2025 New York City mayoral election. We can get the slug from the URL on Polymarket: 
# https://polymarket.com/event/new-york-city-mayoral-election

event_slug <- "new-york-city-mayoral-election"
event <- get_event_by_slug(event_slug)
print(event)

# 3. Extract all markets for the event
markets <- get_event_markets(event_slug)
print(markets)

# 4. Get price history for all Yes/No tokens in the event
# Note: The interval and fidelity arguments are not always respected by the API—results may still be high-frequency.
# By default, we exclude markets with zero liquidity.
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
- The interval parameter may not always be honored exactly by the API; you may receive lower- or higher-frequency data. Still trying to figure out a solution for this.
- All package functions return tibbles for easy manipulation with dplyr/tidyverse tools.

Thanks and feel free to suggest any changes or improvements!