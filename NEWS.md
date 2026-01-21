# bobsburgersR 0.2.0

## Breaking Changes

-   **Dataset renamed:** `imdb_wikipedia_data` is now `episode_data`. Update your code accordingly.

-   **Rating source changed from IMDb to TMDB.** IMDb implemented bot protection in 2024 that prevents web scraping. Ratings now come from TMDB (The Movie Database) community scores via their official API. Both use a 1-10 scale but are from different user communities and are not directly comparable across package versions.

## New Features

-   **Seasons 15-16 added.** Dataset now covers all 16 seasons (309 episodes, up from 275).

-   **New columns in `episode_data`:** `votes` (number of TMDB ratings), `tmdb_id` (TMDB episode identifier), `runtime` (episode length in minutes).

-   **Column renamed:** `us_viewers_millions` (was `wikipedia_viewers`) for clarity.

## Bug Fixes

-   Fixed carriage return characters (`\r`) in transcript data for seasons 13-14 that caused display issues (#1).

-   Removed BOM (byte order mark) characters and line markers from transcripts.

## Data Updates

-   `episode_data`: 309 episodes (was 275)
-   `transcript_data`: 204,027 lines (was 181,031)

## Internal Changes

-   Replaced IMDb web scraper with TMDB API (`01_tmdb_api_fetch.R`).
-   TMDB API key required for data refresh (store in `.Renviron` as `TMDB_API_KEY`).

------------------------------------------------------------------------

# bobsburgersR 0.0.0.9000

-   Initial development version with seasons 1-14.
-   Episode data sourced from IMDb and Wikipedia.
-   Transcript data sourced from Springfield! Springfield!
