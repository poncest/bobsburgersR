# =============================================================================
# Script:     04_clean_tmdb_wikipedia.R
# Purpose:    Combine TMDB and Wikipedia data into final episode dataset
# Input:      TMDB_Bobs_Burgers_Data.csv, Wikipedia_Bobs_Burgers_Data.csv
# Output:     episode_data.rda (package data)
# Seasons:    1-16
#
# Author:     Steven Ponce
# Created:    2024-09-13 (original as 04_data_cleaning_imdb_wikipedia.R)
# Updated:    2026-01 (switched from IMDb to TMDB, simplified join)
#
# Note:       Ratings are TMDB community scores (1-10), not IMDb ratings.
#             See DATA_SOURCE_CHANGE_NOTES.md for details.
# =============================================================================


# 1. LOAD PACKAGES ----

library(dplyr)
library(readr)
library(janitor)
library(lubridate)


# 2. READ DATA ----

cat("Reading TMDB data...\n")
tmdb_data <- read_csv(
  'data-raw/TMDB_Bobs_Burgers_Data.csv',
  show_col_types = FALSE
) |>
  clean_names()

cat("Reading Wikipedia data...\n
")
wikipedia_data <- read_csv(
  'data-raw/Wikipedia_Bobs_Burgers_Data.csv',
  show_col_types = FALSE
) |>
  clean_names()

cat("TMDB rows:", nrow(tmdb_data), "\n")
cat("Wikipedia rows:", nrow(wikipedia_data), "\n")


# 3. PREVIEW DATA STRUCTURES ----

cat("\nTMDB columns:\n")
names(tmdb_data)

cat("\nWikipedia columns:\n")
names(wikipedia_data)


# 4. JOIN DATA ----

# Join on season and episode (most reliable keys)
# TMDB is the primary source, Wikipedia adds director/writer/viewers

episode_data <- tmdb_data |>
  left_join(
    wikipedia_data |>
      select(season, episode, directed_by, written_by, us_viewers_millions),
    by = c("season", "episode")
  )

cat("\nJoined rows:", nrow(episode_data), "\n")


# 5. CHECK FOR JOIN ISSUES ----

# Episodes in TMDB but not Wikipedia
missing_wikipedia <- episode_data |>
  filter(is.na(directed_by))

if (nrow(missing_wikipedia) > 0) {
  cat("\nEpisodes missing Wikipedia data:\n")
  print(missing_wikipedia |> select(season, episode, title))
} else {
  cat("\nAll episodes have Wikipedia data.\n")
}

# Episodes in Wikipedia but not TMDB
extra_wikipedia <- wikipedia_data |>
  anti_join(tmdb_data, by = c("season", "episode"))

if (nrow(extra_wikipedia) > 0) {
  cat("\nEpisodes in Wikipedia but not TMDB:\n")
  print(extra_wikipedia |> select(season, episode, title))
}


# 6. FINAL COLUMN SELECTION AND ORDERING ----

episode_data <- episode_data |>
  select(
    # Identifiers
    episode_overall,
    season,
    episode,

    # Episode info
    title,
    aired_date,
    year,

    # Ratings (TMDB)
    rating,
    votes,

    # Content
    synopsis,

    # Credits (Wikipedia)
    directed_by,
    written_by,

    # Viewership (Wikipedia)
    us_viewers_millions,

    # Technical
    runtime,
    tmdb_id
  )


# 7. DATA TYPE FIXES ----

episode_data <- episode_data |>
  mutate(
    # Ensure proper types
    season = as.integer(season),
    episode = as.integer(episode),
    year = as.integer(year),

    # Parse air date if needed
    aired_date = as.Date(aired_date)
  )


# 8. VALIDATION ----

cat("\n", strrep("=", 50), "\n", sep = "")
cat("FINAL DATASET VALIDATION\n")
cat(strrep("=", 50), "\n")

cat("\nDimensions:", nrow(episode_data), "rows x", ncol(episode_data), "cols\n")
cat("Seasons:", min(episode_data$season), "-", max(episode_data$season), "\n")
cat("Episodes per season:\n")
print(episode_data |> count(season) |> as.data.frame())

cat("\nMissing values:\n")
cat("  - title:", sum(is.na(episode_data$title)), "\n")
cat("  - rating:", sum(is.na(episode_data$rating)), "\n")
cat("  - synopsis:", sum(is.na(episode_data$synopsis) | episode_data$synopsis == ""), "\n")
cat("  - directed_by:", sum(is.na(episode_data$directed_by)), "\n")
cat("  - written_by:", sum(is.na(episode_data$written_by)), "\n")
cat("  - us_viewers_millions:", sum(is.na(episode_data$us_viewers_millions)), "\n")

cat("\nRating range:",
    min(episode_data$rating, na.rm = TRUE), "-",
    max(episode_data$rating, na.rm = TRUE), "\n")

cat("\nDate range:",
    as.character(min(episode_data$aired_date, na.rm = TRUE)), "to",
    as.character(max(episode_data$aired_date, na.rm = TRUE)), "\n")


# 9. SAVE CLEANED CSV ----

write_csv(
  episode_data,
  "data-raw/Episode_Data_Clean.csv"
)
cat("\nSaved to: data-raw/Episode_Data_Clean.csv\n")


# 10. SAVE AS PACKAGE DATA ----

# This creates the .rda file that gets loaded with data("episode_data")
usethis::use_data(episode_data, overwrite = TRUE)
cat("Saved to: data/episode_data.rda\n")


# 11. PREVIEW ----

cat("\nPreview (first 5 rows):\n")
print(episode_data |> head(5))

cat("\nPreview (last 5 rows):\n")
print(episode_data |> tail(5))


# 12. SESSION INFO ----

cat("\n")
sessioninfo::session_info(include_base = TRUE)
