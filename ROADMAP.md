# PolymarketR Package Roadmap

## Vision
Create an R package that makes it easy for R users to access, analyze, and visualize Polymarket data using public API endpoints. The package will focus on reliability, usability, and extensibility, returning all data as tibbles/data.frames and mirroring the Polymarket API where possible.

---

## Phase 1: Core Functionality (MVP)
- **Implement direct API-mirroring functions:**
  - `get_events()` — Retrieve event data from `/events` endpoint
  - `get_markets()` — Retrieve market data from `/markets` endpoint
  - `get_prices_history()` — Retrieve historical price data from `/prices-history` endpoint
- **Return all results as tibbles/data.frames**
- **Error handling:**
  - On API error, return empty tibble/data.frame with a warning message
- **Consistent function naming:**
  - Mirror the API endpoint names unless creating a new/convenience function
- **Testing:**
  - Use the event `new-york-city-mayoral-election` for initial tests and examples

## Phase 2: User-Focused Enhancements
- **Convenience wrappers:**
  - `get_event_by_slug(slug)` — Retrieve a single event by slug
  - `get_event_markets(event_slug)` — Retrieve all markets for a given event
  - `extract_token_ids(market_data, outcome = c("both", "yes", "no"))` — Extract token IDs from market data
- **Client-side search:**
  - `search_events_text(query, limit = 100)` — Search event titles/descriptions locally (since API does not provide search)
- **Verbose option:**
  - Add a `verbose` argument to toggle warnings/info messages
- **Documentation:**
  - Provide clear documentation and usage examples for each function

## Phase 3: Robustness & Extensibility
- **Internal helpers:**
  - HTTP request and error handling helpers
- **Input validation:**
  - Validate slugs, token IDs, and date arguments
- **Unit testing:**
  - Create tests for all core and wrapper functions
- **Extensibility:**
  - Structure code so new endpoints (e.g., user positions, trades) can be added easily
- **(Optional) Caching/Rate Limiting:**
  - Prepare for future addition of caching and rate limiting

---

## Guiding Principles
- **Public endpoints only** (no authentication required)
- **Data retrieval first**; advanced features can be added later
- **Always return tibbles/data.frames** for consistency
- **Warning messages** on errors, never fail with hard errors
- **Function names mirror API** unless providing new/convenience functionality
- **Consistent, well-documented API** for R users

---

## Milestones
1. Draft and finalize roadmap
2. Scaffold R package directory structure
3. Implement and test core API-mirroring functions
4. Add convenience wrappers and search helpers
5. Add documentation and examples
6. Add robust error handling and internal helpers
7. Add unit tests and ensure package reliability
8. Prepare for future extensibility (authentication, new endpoints, caching)

---

## Next Steps
- Finalize this roadmap
- Scaffold the package structure
- Begin implementation of core functions

---

*This roadmap is a living document and should be updated as the project evolves.*
