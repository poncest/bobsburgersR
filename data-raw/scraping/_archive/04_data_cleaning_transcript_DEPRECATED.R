
## Data:      Transcript - Bob's Burgers
## Seasons    1 - 14

## Focus      further clean the data

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
  glue         # Interpreted String Literals
)



## 2. READ IN THE DATA ----
transcript <- read_csv("data-raw/Transcript_Bobs_Burgers_Data.csv") |>
  clean_names() |>
  glimpse()



## 3. TIDY DATA ----

# Remove '=' from the dialogue column
transcript_clean <- transcript  |>
  mutate(dialogue = str_replace_all(dialogue, "=", ""))


## 4. SAVE ----
write_csv(
  transcript_clean,
  "data-raw/Transcript_Bobs_Burgers_Data_Clean.csv"
)



## 5. SESSION INFO ----
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
# V ── Loaded and on-disk version mismatch.
# P ── Loaded and on-disk path mismatch.
#
# ─────────────────────────────────────────────────────────────────────────────────────
# >
