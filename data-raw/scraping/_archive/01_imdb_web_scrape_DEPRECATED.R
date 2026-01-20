
## Data:      IMDb - Bob's Burgers, Episode list
## Seasons    1 - 14
## Link:      https://www.imdb.com/title/tt1561755/episodes/?season=1

## Focus      Scrape data from web pages using rvest and polite.

## Author:    Steven Ponce
## Date:      2024-06-12


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
  rvest,       # Easily Harvest (Scrape) Web Pages
  polite       # Be Nice on the Web
)


## 2. SCRAPE THE DATA ----

# Initialize an empty dataframe
final_df <- tibble()

for (page_ in 1:14) {
  print(paste("Processing season", page_))

  # Construct URL session for each season
  session <- polite::bow(
    sprintf('https://www.imdb.com/title/tt1561755/episodes?season=%d', page_),
    user_agent = "Steven Ponce (steven_ponce@yahoo.com)",
    delay = 5,
    force = FALSE,
    verbose = FALSE
  )

  # Scrape the web page once and get all tables
  website <- session |>
    polite::scrape()

  # Episode titles
  episode_titles <- html_nodes(website, ".ipc-title__text") |>
    html_text() |>
    str_extract(pattern = "(?<=∙ ).*$") |>
    na.omit()

  # Ratings
  ratings <- html_nodes(website, ".ipc-rating-star--base") |>
    html_text(trim = TRUE) |>
    str_extract(pattern = "^[0-9]+\\.[0-9]+") |>
    na.omit()

  # synopsis
  synopsis <- html_nodes(website, ".ipc-overflowText--children") |>
    html_text(trim = TRUE)

  # Aired date
  aired_dates <- html_nodes(website, "span.sc-ccd6e31b-10") |>
    html_text(trim = TRUE)

  # Check data lengths and fill missing data if necessary
  max_length <- max(length(episode_titles), length(ratings), length(synopsis), length(aired_dates))
  if (length(episode_titles) != max_length) episode_titles <- c(episode_titles, rep(NA, max_length - length(episode_titles)))
  if (length(ratings) != max_length) ratings <- c(ratings, rep(NA, max_length - length(ratings)))
  if (length(synopsis) != max_length) synopsis <- c(synopsis, rep(NA, max_length - length(synopsis)))
  if (length(aired_dates) != max_length) aired_dates <- c(aired_dates, rep(NA, max_length - length(aired_dates)))

  # Create a temporary dataframe for the current season
  temp_df <- data.frame(
    season           = rep(page_, max_length),
    episode          = seq_along(episode_titles),
    title            = episode_titles,
    rating           = ratings,
    synopsis         = synopsis,
    aired_date       = aired_dates,
    stringsAsFactors = FALSE
  )

  # Append it to the global dataframe
  final_df <- rbind(final_df, temp_df) |>
    as_tibble()

  # Print summary for debugging
  print(paste("Season", page_, "loaded with", nrow(temp_df), "episodes."))

  # Remove temp df
  rm(temp_df)
}

# Glimpse the final dataframe
glimpse(final_df)




## 3. TIDY DATA ----
imdb_data <- final_df |>
  mutate(
    aired_date      = str_remove(string = aired_date, pattern = "^[A-Za-z]{3}, "),
    aired_date      = mdy(aired_date),
    year            = year(aired_date),
    season          = as_factor(season),
    episode_overall = seq(1:length(episode))
  ) |>
  select(
    episode_overall, aired_date, year, season, episode, everything()
  )



## 4. CHECK FOR DUPLICATES ----
# Check for duplicates in the 'title' column
duplicates <- imdb_data  |>
  group_by(title) |>
  filter(n() > 1) |>
  arrange(title)

# View the duplicates
print(duplicates)



## 5. SAVE ----
write.csv(
  imdb_data,
  "data-raw/IMDb_Bobs_Burgers_Data.csv"
  )

## 6. SESSION INFO ----
sessioninfo::session_info(include_base = TRUE)

# ─ Session info ────────────────────────────────────────────────────────────────────
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
# ─ Packages ────────────────────────────────────────────────────────────────────────
# ! package     * version date (UTC) lib source
# P assertthat    0.2.1   2019-03-21 [?] CRAN (R 4.4.0)
# V base        * 4.4.1   2024-04-24 [2] local (on disk 4.4.0)
# base64enc     0.1-3   2015-07-28 [1] CRAN (R 4.4.0)
# cachem        1.1.0   2024-05-16 [1] CRAN (R 4.4.1)
# cli           3.6.3   2024-06-21 [1] CRAN (R 4.4.0)
# colorspace    2.1-0   2023-01-23 [1] CRAN (R 4.4.1)
# P compiler      4.4.0   2024-04-24 [?] local
# curl          5.2.1   2024-03-01 [1] CRAN (R 4.4.1)
# P datasets    * 4.4.0   2024-04-24 [?] local
# digest        0.6.35  2024-03-11 [1] CRAN (R 4.4.1)
# dplyr       * 1.1.4   2023-11-17 [1] CRAN (R 4.4.1)
# fansi         1.0.6   2023-12-08 [1] CRAN (R 4.4.1)
# fastmap       1.2.0   2024-05-15 [1] CRAN (R 4.4.1)
# forcats     * 1.0.0   2023-01-29 [1] CRAN (R 4.4.1)
# fs            1.6.4   2024-04-25 [1] CRAN (R 4.4.1)
# generics      0.1.3   2022-07-05 [1] CRAN (R 4.4.1)
# ggplot2     * 3.5.1   2024-04-23 [1] CRAN (R 4.4.1)
# ggtext      * 0.1.2   2022-09-16 [1] CRAN (R 4.4.1)
# glue        * 1.7.0   2024-01-09 [1] CRAN (R 4.4.1)
# P graphics    * 4.4.0   2024-04-24 [?] local
# P grDevices   * 4.4.0   2024-04-24 [?] local
# P grid          4.4.0   2024-04-24 [?] local
# gridtext      0.1.5   2022-09-16 [1] CRAN (R 4.4.1)
# gtable        0.3.5   2024-04-22 [1] CRAN (R 4.4.1)
# hms           1.1.3   2023-03-21 [1] CRAN (R 4.4.1)
# htmltools     0.5.8.1 2024-04-04 [1] CRAN (R 4.4.1)
# httr          1.4.7   2023-08-15 [1] CRAN (R 4.4.1)
# janitor     * 2.2.0   2023-02-02 [1] CRAN (R 4.4.1)
# jsonlite      1.8.8   2023-12-04 [1] CRAN (R 4.4.1)
# knitr         1.47    2024-05-29 [1] CRAN (R 4.4.1)
# lifecycle     1.0.4   2023-11-07 [1] CRAN (R 4.4.1)
# lubridate   * 1.9.3   2023-09-27 [1] CRAN (R 4.4.1)
# magrittr      2.0.3   2022-03-30 [1] CRAN (R 4.4.1)
# memoise       2.0.1   2021-11-26 [1] CRAN (R 4.4.1)
# P methods     * 4.4.0   2024-04-24 [?] local
# mime          0.12    2021-09-28 [1] CRAN (R 4.4.0)
# munsell       0.5.1   2024-04-01 [1] CRAN (R 4.4.1)
# P pacman        0.5.1   2019-03-11 [?] CRAN (R 4.4.0)
# pillar        1.9.0   2023-03-22 [1] CRAN (R 4.4.1)
# pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.4.1)
# P polite      * 0.1.3   2023-06-30 [?] CRAN (R 4.4.1)
# purrr       * 1.0.2   2023-08-10 [1] CRAN (R 4.4.1)
# R6            2.5.1   2021-08-19 [1] CRAN (R 4.4.1)
# P ratelimitr    0.4.1   2018-10-07 [?] CRAN (R 4.4.1)
# Rcpp          1.0.12  2024-01-09 [1] CRAN (R 4.4.1)
# readr       * 2.1.5   2024-01-10 [1] CRAN (R 4.4.1)
# renv          1.0.7   2024-04-11 [1] CRAN (R 4.4.0)
# repr          1.1.7   2024-03-22 [1] CRAN (R 4.4.1)
# rlang         1.1.4   2024-06-04 [1] CRAN (R 4.4.1)
# P robotstxt     0.7.13  2020-09-03 [?] CRAN (R 4.4.1)
# rstudioapi    0.16.0  2024-03-24 [1] CRAN (R 4.4.1)
# rvest       * 1.0.4   2024-02-12 [1] CRAN (R 4.4.1)
# scales      * 1.3.0   2023-11-28 [1] CRAN (R 4.4.1)
# selectr       0.4-2   2019-11-20 [1] CRAN (R 4.4.1)
# sessioninfo   1.2.2   2021-12-06 [1] CRAN (R 4.4.1)
# showtext    * 0.9-7   2024-03-02 [1] CRAN (R 4.4.1)
# showtextdb  * 3.0     2020-06-04 [1] CRAN (R 4.4.1)
# skimr       * 2.1.5   2022-12-23 [1] CRAN (R 4.4.1)
# snakecase     0.11.1  2023-08-27 [1] CRAN (R 4.4.1)
# P spiderbar     0.2.5   2023-02-11 [?] CRAN (R 4.4.1)
# P stats       * 4.4.0   2024-04-24 [?] local
# stringi       1.8.4   2024-05-06 [1] CRAN (R 4.4.0)
# stringr     * 1.5.1   2023-11-14 [1] CRAN (R 4.4.1)
# sysfonts    * 0.8.9   2024-03-02 [1] CRAN (R 4.4.1)
# tibble      * 3.2.1   2023-03-20 [1] CRAN (R 4.4.1)
# tidyr       * 1.3.1   2024-01-24 [1] CRAN (R 4.4.1)
# tidyselect    1.2.1   2024-03-11 [1] CRAN (R 4.4.1)
# tidyverse   * 2.0.0   2023-02-22 [1] CRAN (R 4.4.1)
# timechange    0.3.0   2024-01-18 [1] CRAN (R 4.4.1)
# P tools         4.4.0   2024-04-24 [?] local
# tzdb          0.4.0   2023-05-12 [1] CRAN (R 4.4.1)
# usethis       2.2.3   2024-02-19 [1] CRAN (R 4.4.1)
# utf8          1.2.4   2023-10-22 [1] CRAN (R 4.4.1)
# P utils       * 4.4.0   2024-04-24 [?] local
# vctrs         0.6.5   2023-12-01 [1] CRAN (R 4.4.1)
# withr         3.0.0   2024-01-16 [1] CRAN (R 4.4.1)
# xfun          0.45    2024-06-16 [1] CRAN (R 4.4.1)
# xml2          1.3.6   2023-12-04 [1] CRAN (R 4.4.1)
#
# V ── Loaded and on-disk version mismatch.
# P ── Loaded and on-disk path mismatch.
#
# ───────────────────────────────────────────────────────────────────────────────────
# >
