
## Data:      IMDb & Wikipedia - Bob's Burgers
## Seasons    1 - 14

## Focus      Tidy and combine both datasets

## Author:    Steven Ponce
## Date:      2024-09-13


## 1. LOAD PACKAGES & SETUP ----
pacman::p_load(
  tidyverse,   # Easily Install and Load the 'Tidyverse'
  ggtext,      # Improved Text Rendering Support for 'ggplot2'
  showtext,    # Using Fonts More Easily in R Graphs
  janitor,     # Simple Tools for Examining and Cleaning Dirty Data
  skimr,       # Compact and Flexible Summaries of Data
  scales,      # Scale Functions for Visualization
  lubridate,   # Make Dealing with Dates a Little Easier
  glue,        # Interpreted String Literals
  fuzzyjoin    # Join Tables Together on Inexact Matching
)



## 2. READ IN THE DATA ----

imdb_data <- read_csv('data-raw/IMDb_Bobs_Burgers_Data.csv') |>
  clean_names() |>
  glimpse()


wikipedia_data <- read_csv('data-raw/Wikipedia_Bobs_Burgers_Data.csv') |>
  clean_names() |>
  glimpse()



## 3. TIDY DATA ----

# Step 1: Clean the title Column in Wikipedia Data
# Clean the 'title' column in wikipedia_data
wikipedia_data <- wikipedia_data |>
  mutate(title = str_replace_all(title, "\"", ""))


# Step 2: Perform an Exact Join
# Perform an exact join using episode_overall, season, and episode
combined_data_exact <- imdb_data |>
  left_join(wikipedia_data, by = c("episode_overall", "season", "episode"))

# Check the result
glimpse(combined_data_exact)


# Step 3: Check for Missing Data After the Exact Join
# Check for rows in IMDb data that didn't match Wikipedia data (missing Wikipedia info)
missing_in_wikipedia <- imdb_data |>
  anti_join(wikipedia_data, by = c("episode_overall", "season", "episode"))

# View the unmatched IMDb episodes
print(missing_in_wikipedia)


# Step 4: Perform a Fuzzy Join on Titles
# Perform a fuzzy join on the 'title' column
combined_data_fuzzy <- imdb_data |>
  stringdist_left_join(wikipedia_data, by = "title", max_dist = 1) # Adjust max_dist as needed

# Glimpse the fuzzy joined data
glimpse(combined_data_fuzzy)


# Step 5: Check for Duplicates in the Fuzzy Join
# Check for duplicate matches after the fuzzy join
duplicate_matches <- combined_data_fuzzy |>
  group_by(episode_overall.x, season.x, episode.x) |>
  filter(n() > 1)

# View the duplicate matches
print(duplicate_matches)


# Step 6: Identify Mismatched Titles in the Fuzzy Join
# Find rows where IMDb and Wikipedia titles do not exactly match
mismatch_titles <- combined_data_fuzzy |>
  filter(title.x != title.y)

# View the mismatched titles
print(mismatch_titles)


# Step 7: Handle Duplicates and Incorrect Matches
# Keep only the first match for each episode
combined_data_clean <- combined_data_fuzzy |>
  distinct(episode_overall.x, season.x, episode.x, .keep_all = TRUE)

# Glimpse the cleaned data
glimpse(combined_data_clean)


# Step 8: Final Clean-Up and Renaming Columns
# Remove unnecessary duplicate columns and rename columns
combined_data_clean <- combined_data_clean |>
  select(-x1.y, -aired_date.y, -year.y, -season.y, -episode.y, -title.y) |>
  rename(
    imdb_aired_date = aired_date.x,
    imdb_title = title.x,
    wikipedia_viewers = us_viewers_millions,
    wikipedia_directed_by = directed_by,
    wikipedia_written_by = written_by,
    episode_overall = episode_overall.x,
    year = year.x,
    season = season.x,
    episode = episode.x
  ) |>
  # Drop unnecessary or duplicate columns
  select(-x1.x, -episode_overall.y)

# Glimpse the final cleaned data
glimpse(combined_data_clean)


# Step 9: Remove Temporary Datasets
# Remove temporary or intermediate datasets
rm(combined_data_fuzzy, combined_data_exact, mismatch_titles, duplicate_matches,
   missing_in_wikipedia, imdb_data, wikipedia_data)



## 6. SAVE ----
write_csv(
  combined_data_clean,
  "data-raw/IMDb_Wikipedia_Bobs_Burgers_Data_Clean.csv"
)



## 7. SESSION INFO ----
sessioninfo::session_info(include_base = TRUE)

# ─ Session info ──────────────────────────────────────────────────────────────────────
# setting  value
# version  R version 4.4.1 (2024-06-14 ucrt)
# os       Windows 10 x64 (build 19045)
# system   x86_64, mingw32
# ui       RStudio
# language (EN)
# collate  English_United States.utf8
# ctype    English_United States.utf8
# tz       America/New_York
# date     2024-09-13
# rstudio  2024.04.2+764 Chocolate Cosmos (desktop)
# pandoc   NA
#
# ─ Packages ──────────────────────────────────────────────────────────────────────────
# ! package     * version date (UTC) lib source
# V base        * 4.4.1   2024-04-24 [2] local (on disk 4.4.0)
# cli           3.6.3   2024-06-21 [1] CRAN (R 4.4.0)
# P compiler      4.4.0   2024-04-24 [?] local
# P datasets    * 4.4.0   2024-04-24 [?] local
# P graphics    * 4.4.0   2024-04-24 [?] local
# P grDevices   * 4.4.0   2024-04-24 [?] local
# P methods     * 4.4.0   2024-04-24 [?] local
# P pacman        0.5.1   2019-03-11 [?] CRAN (R 4.4.0)
# renv          1.0.7   2024-04-11 [1] CRAN (R 4.4.0)
# rstudioapi    0.16.0  2024-03-24 [1] CRAN (R 4.4.1)
# sessioninfo   1.2.2   2021-12-06 [1] CRAN (R 4.4.1)
# P stats       * 4.4.0   2024-04-24 [?] local
# P tools         4.4.0   2024-04-24 [?] local
# P utils       * 4.4.0   2024-04-24 [?] local
#
# [1] C:/Users/poncest/OneDrive - Bristol Myers Squibb/RStudio/Bobs_Burguers/renv/library/windows/R-4.4/x86_64-w64-mingw32
# [2] C:/Users/poncest/AppData/Local/R/cache/R/renv/sandbox/windows/R-4.4/x86_64-w64-mingw32/d6ee0ff8
#
# V ── Loaded and on-disk version mismatch.
# P ── Loaded and on-disk path mismatch.
#
# ─────────────────────────────────────────────────────────────────────────────────────
# >
# >

