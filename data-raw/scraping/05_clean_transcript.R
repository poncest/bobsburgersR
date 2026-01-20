# =============================================================================
# Script:     05_clean_transcript.R
# Purpose:    Final cleaning and save transcript data as package data
# Input:      Transcript_Bobs_Burgers_Data.csv
# Output:     transcript_data.rda (package data)
# Seasons:    1-16
#
# Author:     Steven Ponce
# Created:    2024-09-13 (original as 04_data_cleaning_transcript.R)
# Updated:    2026-01 (simplified - heavy cleaning now in scraping script)
#
# Note:       Most cleaning (carriage returns, BOM, markers) is now handled
#             in 03_transcript_web_scrape.R. This script does final touches.
# =============================================================================


# 1. LOAD PACKAGES ----

library(dplyr)
library(readr)
library(stringr)
library(janitor)


# 2. READ DATA ----

cat("Reading transcript data...\n")

transcript_data <- read_csv(
  "data-raw/Transcript_Bobs_Burgers_Data.csv",
  show_col_types = FALSE
) |>
  clean_names()

cat("Rows:", nrow(transcript_data), "\n")
cat("Episodes:", n_distinct(paste(transcript_data$season, transcript_data$episode)), "\n")


# 3. FINAL CLEANING ----

transcript_data <- transcript_data |>
  mutate(
    # Remove any stray "=" characters (legacy issue)
    dialogue = str_replace_all(dialogue, "=", ""),

    # Ensure proper types
    season = as.integer(season),
    episode = as.integer(episode),
    line = as.integer(line)
  )


# 4. VALIDATION ----

cat("\n", strrep("=", 50), "\n", sep = "")
cat("TRANSCRIPT DATA VALIDATION\n")
cat(strrep("=", 50), "\n")

cat("\nDimensions:", nrow(transcript_data), "rows x", ncol(transcript_data), "cols\n")
cat("Seasons:", min(transcript_data$season), "-", max(transcript_data$season), "\n")

cat("\nLines per season:\n")
print(
  transcript_data |>
    group_by(season) |>
    summarise(
      episodes = n_distinct(episode),
      lines = n(),
      .groups = "drop"
    ) |>
    as.data.frame()
)

cat("\nMissing values:\n")
cat("  - title:", sum(is.na(transcript_data$title)), "\n")
cat("  - raw_text:", sum(is.na(transcript_data$raw_text)), "\n")
cat("  - dialogue:", sum(is.na(transcript_data$dialogue)), "\n")

# Check for remaining issues
cat("\nQuality checks:\n")
cat("  - Empty dialogues:", sum(transcript_data$dialogue == "", na.rm = TRUE), "\n")
cat("  - Lines with '=':", sum(grepl("=", transcript_data$dialogue)), "\n")


# 5. SAVE AS PACKAGE DATA ----

usethis::use_data(transcript_data, overwrite = TRUE)
cat("\nSaved to: data/transcript_data.rda\n")


# 6. PREVIEW ----

cat("\nPreview (S01E01, first 10 lines with dialogue):\n")
print(
  transcript_data |>
    filter(season == 1, episode == 1, dialogue != "") |>
    select(line, dialogue) |>
    head(10)
)

cat("\nPreview (S16E01, first 10 lines with dialogue):\n")
print(
  transcript_data |>
    filter(season == 16, episode == 1, dialogue != "") |>
    select(line, dialogue) |>
    head(10)
)


# 7. SESSION INFO ----

cat("\n")
sessioninfo::session_info(include_base = TRUE)
