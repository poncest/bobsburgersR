# =============================================================================
# Script:     02_wikipedia_web_scrape.R
# Purpose:    Scrape Bob's Burgers episode data from Wikipedia
# Data:       Directors, writers, US viewers, air dates
# Seasons:    1-16
# Source:     https://en.wikipedia.org/wiki/List_of_Bob%27s_Burgers_episodes
#
# Author:     Steven Ponce
# Created:    2024-09-12 (original)
# Updated:    2026-01 (extended to S15-16)
# =============================================================================


# 1. LOAD PACKAGES ----

library(dplyr)
library(tibble)
library(stringr)
library(janitor)
library(lubridate)
library(rvest)
library(polite)


# 2. SCRAPE THE DATA ----

# The base URL - all seasons on single page
base_url <- 'https://en.wikipedia.org/wiki/List_of_Bob%27s_Burgers_episodes'

# Bow to the website (polite scraping)
session <- polite::bow(
  base_url,
  user_agent = "Steven Ponce (steven_ponce@yahoo.com)",
  delay = 2,
  force = FALSE,
  verbose = FALSE
)

cat("Scraping Wikipedia...\n")

# Scrape the web page and get all tables
all_tables <- polite::scrape(session) |>
  rvest::html_table(fill = TRUE)

cat("Found", length(all_tables), "tables on page\n")

# Episode tables are at indices 2-17 (Seasons 1-16)
# Index 1 = Season summary table
# Index 18+ = Movie, navigation tables, etc.
season_tables <- all_tables[2:17]

cat("Processing", length(season_tables), "season tables\n")


# 3. CLEAN AND COMBINE TABLES ----

# Function to clean column names (removes superscripts, standardizes names)
clean_table <- function(df) {
  # Clean column names
  clean_names <- colnames(df) |>
    str_replace_all("\\[.*?\\]", "") |>   # Remove [290] style suffixes
    str_trim() |>
    make_clean_names()

  colnames(df) <- clean_names

  # Drop columns that are entirely NA
  df <- df |>
    select(where(~!all(is.na(.))))

  return(df)
}

# Use first table's columns as reference structure
reference_colnames <- colnames(clean_table(season_tables[[1]]))
cat("Reference columns:", paste(reference_colnames, collapse = ", "), "\n\n")

# Initialize results
final_df <- tibble()

# Process each season table
for (i in seq_along(season_tables)) {
  cat("Processing Season", i, "...")

  # Convert to tibble and clean
  season_df <- as_tibble(season_tables[[i]], .name_repair = "unique")
  season_df <- clean_table(season_df)

  # Align columns with reference (handle varying structures)
  missing_cols <- setdiff(reference_colnames, colnames(season_df))
  for (col in missing_cols) {
    season_df[[col]] <- NA
  }

  # Keep only reference columns, in order
  season_df <- season_df[, reference_colnames]

  # Ensure consistent types
  season_df <- season_df |>
    mutate(
      no_overall = as.character(no_overall),
      no_inseason = as.character(no_inseason)
    )

  # Clean viewers column (remove footnote references)
  if ("u_s_viewers_millions" %in% names(season_df)) {
    season_df <- season_df |>
      mutate(
        u_s_viewers_millions = str_replace_all(u_s_viewers_millions, "\\[.*?\\]", ""),
        u_s_viewers_millions = as.numeric(u_s_viewers_millions)
      )
  }

  # Add season number
  season_df <- mutate(season_df, season = i)

  # Append to final
  final_df <- bind_rows(final_df, season_df)

  cat(" ", nrow(season_df), "episodes\n")
}

cat("\nTotal episodes loaded:", nrow(final_df), "\n")


# 4. TIDY DATA ----

wikipedia_data <- final_df |>
  clean_names() |>
  # Drop production code and any artifact columns
  select(
    -matches("prod_code"),
    -matches("title_\\d+"),
    -matches("original_air_date_\\d+")
  ) |>
  mutate(
    # Clean title (remove quotes and footnotes)
    title = str_replace_all(title, "\\[.*?\\]", ""),
    title = str_remove_all(title, '^\\"|\\"$'),
    title = str_trim(title),

    # Parse air date (extract YYYY-MM-DD from parentheses)
    original_air_date = str_extract(original_release_date, "\\d{4}-\\d{2}-\\d{2}"),
    original_air_date = ymd(original_air_date),

    # Extract year
    year = year(original_air_date),

    # Clean episode numbers
    episode_overall = as.integer(no_overall),
    episode = as.integer(no_inseason)
  ) |>
  rename(
    aired_date = original_air_date,
    us_viewers_millions = u_s_viewers_millions
  ) |>
  select(
    episode_overall,
    aired_date,
    year,
    season,
    episode,
    title,
    directed_by,
    written_by,
    us_viewers_millions
  ) |>
  # Remove any header rows that got parsed as data
  filter(!is.na(year))


# 5. VALIDATION ----

cat("\n", strrep("=", 50), "\n", sep = "")
cat("SCRAPE COMPLETE\n")
cat(strrep("=", 50), "\n")

cat("Total episodes:", nrow(wikipedia_data), "\n")
cat("Seasons:", paste(range(wikipedia_data$season), collapse = "-"), "\n")

cat("\nEpisodes per season:\n")
print(wikipedia_data |> count(season) |> as.data.frame())

cat("\nMissing values:\n")
cat("  - Titles:", sum(is.na(wikipedia_data$title)), "\n")
cat("  - Directors:", sum(is.na(wikipedia_data$directed_by)), "\n")
cat("  - Writers:", sum(is.na(wikipedia_data$written_by)), "\n")
cat("  - Viewers:", sum(is.na(wikipedia_data$us_viewers_millions)), "\n")


# 6. CHECK FOR DUPLICATES ----

duplicates <- wikipedia_data |>
  group_by(title) |>
  filter(n() > 1) |>
  arrange(title)

if (nrow(duplicates) > 0) {
  cat("\nDuplicate titles found:\n")
  print(duplicates)
} else {
  cat("\nNo duplicate titles found.\n")
}


# 7. SAVE ----

write.csv(
  wikipedia_data,
  "data-raw/Wikipedia_Bobs_Burgers_Data.csv",
  row.names = FALSE
)

cat("\nSaved to: data-raw/Wikipedia_Bobs_Burgers_Data.csv\n")


# 8. PREVIEW ----

cat("\nPreview (first 5 rows):\n")
print(wikipedia_data |> head(5))

cat("\nPreview (last 5 rows - S16):\n")
print(wikipedia_data |> tail(5))


# 9. SESSION INFO ----

cat("\n")
sessioninfo::session_info(include_base = TRUE)
