# =============================================================================
# Script:     01_omdb_api_fetch.R
# Purpose:    Fetch Bob's Burgers episode data from OMDB API
# Replaces:   01_imdb_web_scrape.R (broken due to IMDb WAF blocking)
# Data:       Episode titles, air dates, ratings, synopsis, directors
# Seasons:    1-16
# API:        https://www.omdbapi.com/
#
# Author:     Steven Ponce
# Created:    2024-06-12 (original)
# Updated:    2026-01 (switched to OMDB API)
# =============================================================================


# 1. LOAD PACKAGES ----

library(jsonlite)
library(dplyr)
library(tibble)


# 2. SETUP ----

# API key from environment variable (set in .Renviron)
api_key <- Sys.getenv("OMDB_API_KEY")

# Verify key is available
if (api_key == "") {
  stop("OMDB_API_KEY not found. Add it to .Renviron and restart R.")
}

# Bob's Burgers IMDb series ID
series_id <- "tt1561755"

# Seasons to fetch
seasons <- 1:16

# Rate limiting: pause between API calls (seconds)
# OMDB is generous, but be polite
delay_between_calls <- 0.5


# 3. FETCH DATA ----

# Initialize results list
all_episodes <- list()

for (season_num in seasons) {

  cat("\n", strrep("=", 50), "\n", sep = "")
  cat("Processing Season", season_num, "\n")
  cat(strrep("=", 50), "\n")

  # First, get season info to know episode count
  season_url <- paste0(
    "http://www.omdbapi.com/?i=", series_id,
    "&Season=", season_num,
    "&apikey=", api_key
  )

  season_info <- tryCatch(
    fromJSON(season_url),
    error = function(e) {
      cat("  ERROR fetching season info:", e$message, "\n")
      return(NULL)
    }
  )

  if (is.null(season_info) || season_info$Response == "False") {
    cat("  Skipping season", season_num, "- not found or error\n")
    next
  }

  n_episodes <- nrow(season_info$Episodes)
  cat("  Found", n_episodes, "episodes\n")

  # Fetch each episode's full details
  for (ep_num in 1:n_episodes) {

    ep_url <- paste0(
      "http://www.omdbapi.com/?i=", series_id,
      "&Season=", season_num,
      "&Episode=", ep_num,
      "&apikey=", api_key
    )

    ep_info <- tryCatch(
      fromJSON(ep_url),
      error = function(e) {
        cat("    ERROR S", season_num, "E", ep_num, ":", e$message, "\n", sep = "")
        return(NULL)
      }
    )

    if (is.null(ep_info) || ep_info$Response == "False") {
      cat("    Skipping S", season_num, "E", ep_num, "- not found\n", sep = "")
      next
    }

    # Extract data into tibble row
    episode_row <- tibble(
      season       = as.integer(ep_info$Season),
      episode      = as.integer(ep_info$Episode),
      title        = ep_info$Title,
      aired_date   = ep_info$Released,
      rating       = suppressWarnings(as.numeric(ep_info$imdbRating)),
      votes        = suppressWarnings(as.integer(gsub(",", "", ep_info$imdbVotes))),
      synopsis     = ep_info$Plot,
      director     = ep_info$Director,
      runtime      = ep_info$Runtime,
      imdb_id      = ep_info$imdbID
    )

    all_episodes[[length(all_episodes) + 1]] <- episode_row

    # Progress indicator
    cat("    S", season_num, "E", ep_num, ": ", ep_info$Title, "\n", sep = "")

    # Rate limiting
    Sys.sleep(delay_between_calls)
  }

  cat("  Season", season_num, "complete.\n")
}


# 4. COMBINE RESULTS ----

omdb_data <- bind_rows(all_episodes)

cat("\n", strrep("=", 50), "\n", sep = "")
cat("FETCH COMPLETE\n")
cat(strrep("=", 50), "\n")
cat("Total episodes:", nrow(omdb_data), "\n")
cat("Seasons:", paste(range(omdb_data$season), collapse = "-"), "\n")


# 5. ADD DERIVED COLUMNS ----

omdb_data <- omdb_data |>
  mutate(
    episode_overall = row_number(),
    year = as.integer(substr(aired_date, nchar(aired_date) - 3, nchar(aired_date)))
  ) |>
  select(
    episode_overall,
    season,
    episode,
    title,
    aired_date,
    year,
    rating,
    votes,
    synopsis,
    director,
    runtime,
    imdb_id
  )


# 6. QUICK VALIDATION ----

cat("\nValidation:\n")
cat("  - Episodes per season:\n")
print(omdb_data |> count(season) |> as.data.frame())

cat("\n  - Rating range:", range(omdb_data$rating, na.rm = TRUE), "\n")
cat("  - Any missing titles:", sum(is.na(omdb_data$title)), "\n")
cat("  - Any missing ratings:", sum(is.na(omdb_data$rating)), "\n")


# 7. SAVE RAW DATA ----

write.csv(
  omdb_data,
  "data-raw/OMDB_Bobs_Burgers_Data.csv",
  row.names = FALSE
)

cat("\nSaved to: data-raw/OMDB_Bobs_Burgers_Data.csv\n")


# 8. PREVIEW ----

cat("\nPreview (first 10 rows):\n")
print(omdb_data |> select(episode_overall, season, episode, title, rating) |> head(10))


# 9. SESSION INFO ----

cat("\n")
sessioninfo::session_info(include_base = TRUE)
