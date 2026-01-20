# =============================================================================
# Script:     01_tmdb_api_fetch.R
# Purpose:    Fetch Bob's Burgers episode data from TMDB API
# Data:       Episode titles, air dates, ratings (TMDB), synopses
# Seasons:    1-16
# API:        https://api.themoviedb.org/
# API Docs:   https://developer.themoviedb.org/reference/tv-season-details
#
# Note:       Ratings are TMDB community scores (1-10 scale), not IMDb ratings
#
# Author:     Steven Ponce
# Created:    2024-06-12 (original IMDb version)
# Updated:    2026-01 (switched to TMDB API)
# =============================================================================


# 1. LOAD PACKAGES ----

library(jsonlite)
library(dplyr)
library(tibble)


# 2. SETUP ----

# API key from environment variable (set in .Renviron)
tmdb_key <- Sys.getenv("TMDB_API_KEY")

# Verify key is available
if (tmdb_key == "") {

  stop("TMDB_API_KEY not found. Add it to .Renviron and restart R.")
}

# Bob's Burgers TMDB series ID
# https://www.themoviedb.org/tv/32726-bob-s-burgers
series_id <- 32726

# Seasons to fetch
seasons <- 1:16

# Rate limiting: pause between API calls (seconds)
delay_between_calls <- 0.25


# 3. FETCH DATA ----

# Initialize results list
all_episodes <- list()

for (season_num in seasons) {

  cat("\n", strrep("=", 50), "\n", sep = "")
  cat("Processing Season", season_num, "\n")
  cat(strrep("=", 50), "\n")

  # Fetch season data
  season_url <- paste0(
    "https://api.themoviedb.org/3/tv/", series_id,
    "/season/", season_num,
    "?api_key=", tmdb_key
  )

  season_data <- tryCatch(
    fromJSON(season_url),
    error = function(e) {
      cat("  ERROR fetching season:", e$message, "\n")
      return(NULL)
    }
  )

  if (is.null(season_data)) {
    cat("  Skipping season", season_num, "- not found or error\n")
    next
  }

  # Extract episodes
  episodes <- season_data$episodes
  n_episodes <- nrow(episodes)
  cat("  Found", n_episodes, "episodes\n")

  # Process each episode
  for (i in 1:n_episodes) {
    ep <- episodes[i, ]

    # Extract data into tibble row
    episode_row <- tibble(
      season        = as.integer(ep$season_number),
      episode       = as.integer(ep$episode_number),
      title         = ep$name,
      aired_date    = ep$air_date,
      rating        = as.numeric(ep$vote_average),
      votes         = as.integer(ep$vote_count),
      synopsis      = ep$overview,
      runtime       = as.integer(ep$runtime),
      tmdb_id       = as.integer(ep$id)
    )

    all_episodes[[length(all_episodes) + 1]] <- episode_row

    # Progress indicator
    cat("    S", season_num, "E", ep$episode_number, ": ", ep$name, "\n", sep = "")
  }

  cat("  Season", season_num, "complete.\n")

  # Rate limiting between seasons
  Sys.sleep(delay_between_calls)
}


# 4. COMBINE RESULTS ----

tmdb_data <- bind_rows(all_episodes)

cat("\n", strrep("=", 50), "\n", sep = "")
cat("FETCH COMPLETE\n")
cat(strrep("=", 50), "\n")
cat("Total episodes:", nrow(tmdb_data), "\n")
cat("Seasons:", paste(range(tmdb_data$season), collapse = "-"), "\n")


# 5. CLEAN & ADD DERIVED COLUMNS ----

tmdb_data <- tmdb_data |>
  mutate(
    # Convert 0.0 ratings to NA (means no votes yet, not actual zero)
    rating = if_else(rating == 0, NA_real_, rating),

    # Add overall episode number
    episode_overall = row_number(),

    # Extract year from air date
    year = as.integer(substr(aired_date, 1, 4))
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
    runtime,
    tmdb_id
  )


# 6. VALIDATION ----

cat("\nValidation:\n")
cat("  - Episodes per season:\n")
print(tmdb_data |> count(season) |> as.data.frame())

cat("\n  - Rating range (excl NA):",
    paste(range(tmdb_data$rating, na.rm = TRUE), collapse = " - "), "\n")
cat("  - Missing titles:", sum(is.na(tmdb_data$title)), "\n")
cat("  - Missing ratings:", sum(is.na(tmdb_data$rating)), "\n")
cat("  - Missing synopsis:", sum(is.na(tmdb_data$synopsis) | tmdb_data$synopsis == ""), "\n")


# 7. SAVE RAW DATA ----

write.csv(
  tmdb_data,
  "data-raw/TMDB_Bobs_Burgers_Data.csv",
  row.names = FALSE
)

cat("\nSaved to: data-raw/TMDB_Bobs_Burgers_Data.csv\n")


# 8. PREVIEW ----

cat("\nPreview (first 10 rows):\n")
print(tmdb_data |> select(episode_overall, season, episode, title, rating) |> head(10))

cat("\nPreview (last 10 rows - recent episodes):\n")
print(tmdb_data |> select(episode_overall, season, episode, title, rating) |> tail(10))


# 9. SESSION INFO ----

cat("\n")
sessioninfo::session_info(include_base = TRUE)
