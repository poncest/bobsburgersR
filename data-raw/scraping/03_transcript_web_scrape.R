# =============================================================================
# Script:     03_transcript_web_scrape.R
# Purpose:    Scrape Bob's Burgers episode transcripts from Springfield! Springfield!
# Data:       Dialogue lines by episode
# Seasons:    1-16
# Source:     https://www.springfieldspringfield.co.uk/episode_scripts.php?tv-show=bobs-burgers
#
# Author:     Steven Ponce
# Created:    2024-06-30 (original)
# Updated:    2026-01 (fix carriage returns, BOM, line markers; extend to S15-16)
#
# Known Issues Fixed:
#   - Carriage returns (\r) causing empty lines (GitHub issue)
#   - BOM character (\ufeff) at start of transcripts
#   - Line markers (1, 1/r, 2) at beginning of dialogue
#   - Tab characters (\t) before dialogue
#   - Performance: replaced row-by-row add_row with list collection
# =============================================================================


# 1. LOAD PACKAGES ----

library(dplyr)
library(tibble)
library(stringr)
library(janitor)
library(rvest)
library(polite)
library(purrr)


# 2. SETUP ----

# Base URL for the show's script page
base_url <- "https://www.springfieldspringfield.co.uk/episode_scripts.php?tv-show=bobs-burgers"

# Rate limiting
delay_between_episodes <- 2  # seconds


# 3. SCRAPE EPISODE LINKS ----

cat("Fetching episode list...\n")

session_base <- polite::bow(
  base_url,
  user_agent = "Steven Ponce (steven_ponce@yahoo.com)",
  delay = 5,
  force = FALSE,
  verbose = FALSE
)

base_page <- session_base |> polite::scrape()

episode_links <- base_page |>
  html_nodes("a.season-episode-title") |>
  html_attr("href") |>
  purrr::map_chr(~ paste0("https://www.springfieldspringfield.co.uk/", .))

cat("Found", length(episode_links), "episodes\n\n")


# 4. TRANSCRIPT CLEANING FUNCTION ----

clean_transcript <- function(raw_html) {
  # Step 1: Replace <br> with newline
  text <- gsub("<br>", "\n", raw_html)

  # Step 2: Remove remaining HTML tags
  text <- gsub("<.*?>", "", text)

  # Step 3: Normalize line endings (fix carriage return issue)
  text <- gsub("\r\n", "\n", text)  # Windows style
  text <- gsub("\r", "\n", text)     # Old Mac style / stray \r

  # Step 4: Remove BOM (Byte Order Mark)
  text <- gsub("\ufeff", "", text)

  # Step 5: Split into lines
  lines <- str_split(text, "\n")[[1]]

  # Step 6: Clean each line
  lines <- lines |>
    # Remove leading/trailing whitespace and tabs
    str_trim() |>
    # Remove leading line markers (1, 2, 1/r, etc.)
    str_remove("^\\d+/?r?\\s*") |>
    # Remove tab characters
    str_remove_all("\t") |>
    # Final trim
    str_trim()

  # Step 7: Remove empty lines
  lines <- lines[lines != ""]

  return(lines)
}


# 5. SCRAPE TRANSCRIPTS ----

# Collect results in a list (much faster than add_row in loop)
all_results <- list()
result_index <- 1

for (i in seq_along(episode_links)) {
  link <- episode_links[i]

  # Extract season/episode from URL
  season_episode <- str_extract(link, "s(\\d+)e(\\d+)")
  season <- str_sub(season_episode, 2, 3)
  episode <- str_sub(season_episode, 5, 6)

  cat(sprintf("[%3d/%d] S%sE%s: ", i, length(episode_links), season, episode))

  # Polite scraping
  session_episode <- polite::bow(
    link,
    user_agent = "Steven Ponce (steven_ponce@yahoo.com)",
    delay = delay_between_episodes
  )

  episode_page <- tryCatch(
    polite::scrape(session_episode),
    error = function(e) {
      cat("ERROR -", e$message, "\n")
      return(NULL)
    }
  )

  if (is.null(episode_page)) next

  # Extract title
  title <- episode_page |>
    html_node("h3") |>
    html_text() |>
    str_trim()

  cat(title, "")

  # Extract transcript HTML
  transcript_html <- episode_page |>
    html_node(".scrolling-script-container") |>
    as.character()

  if (is.na(transcript_html)) {
    cat("- No transcript found\n")
    next
  }

  # Clean transcript
  lines <- clean_transcript(transcript_html)

  # Store each line
  for (line_num in seq_along(lines)) {
    raw_text <- lines[line_num]

    # Additional dialogue cleaning (remove stage directions in brackets)
    dialogue <- raw_text |>
      str_remove_all("\\[.*?\\]") |>
      str_trim()

    all_results[[result_index]] <- tibble(
      season = season,
      episode = episode,
      title = title,
      line = line_num,
      raw_text = raw_text,
      dialogue = dialogue
    )

    result_index <- result_index + 1
  }

  cat("-", length(lines), "lines\n")
}


# 6. COMBINE RESULTS ----

cat("\nCombining results...\n")
transcript_data <- bind_rows(all_results)

# Clean column names
transcript_data <- transcript_data |>
  clean_names() |>
  mutate(
    season = as.integer(season),
    episode = as.integer(episode)
  )


# 7. VALIDATION ----

cat("\n", strrep("=", 50), "\n", sep = "")
cat("SCRAPE COMPLETE\n")
cat(strrep("=", 50), "\n")

cat("Total lines:", nrow(transcript_data), "\n")
cat("Total episodes:", n_distinct(paste(transcript_data$season, transcript_data$episode)), "\n")
cat("Seasons:", paste(range(transcript_data$season), collapse = "-"), "\n")

cat("\nLines per season:\n")
print(
  transcript_data |>
    group_by(season) |>
    summarise(
      episodes = n_distinct(episode),
      total_lines = n(),
      .groups = "drop"
    ) |>
    as.data.frame()
)

# Check for empty dialogues
empty_dialogue <- sum(transcript_data$dialogue == "" | is.na(transcript_data$dialogue))
cat("\nEmpty dialogue lines:", empty_dialogue, "\n")

# Check for remaining issues
cat("\nChecking for remaining issues:\n")
cat("  - Lines with \\r:", sum(grepl("\r", transcript_data$raw_text)), "\n")
cat("  - Lines with BOM:", sum(grepl("\ufeff", transcript_data$raw_text)), "\n")
cat("  - Lines starting with digit marker:",
    sum(grepl("^\\d+\\s", transcript_data$raw_text)), "\n")


# 8. SAVE ----

write.csv(
  transcript_data,
  "data-raw/Transcript_Bobs_Burgers_Data.csv",
  row.names = FALSE
)

cat("\nSaved to: data-raw/Transcript_Bobs_Burgers_Data.csv\n")


# 9. PREVIEW ----

cat("\nPreview (first 10 non-empty lines from S01E01):\n")
print(
  transcript_data |>
    filter(season == 1, episode == 1, dialogue != "") |>
    select(line, dialogue) |>
    head(10)
)

cat("\nPreview (first 10 non-empty lines from S16E01):\n")
print(
  transcript_data |>
    filter(season == 16, episode == 1, dialogue != "") |>
    select(line, dialogue) |>
    head(10)
)


# 10. SESSION INFO ----

cat("\n")
sessioninfo::session_info(include_base = TRUE)
