
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bobsburgersR <img src="man/figures/bobsburgersR.png" align="right" height="240"/>

[![R-CMD-check](https://github.com/poncest/bobsburgersR/workflows/R-CMD-check/badge.svg)](https://github.com/poncest/bobsburgersR/actions)
![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A collection of datasets on the [Bob’s
Burgers](https://www.fox.com/bobs-burgers/) American animated sitcom.
This package aims to provide easy access to data about the show,
allowing for analysis of trends in ratings, character dialogue, and
more. Included in the package are 2 datasets detailed below for seasons
1-16 (309 episodes).

# Installation

Install from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("poncest/bobsburgersR")
```

# Data Dictionary

## `episode_data`

| Column Name | Data Type | Description |
|----|----|----|
| `episode_overall` | `dbl` | The overall episode number in the entire Bob’s Burgers series (1-309). |
| `season` | `dbl` | The season number (1-16). |
| `episode` | `dbl` | The episode number within the season. |
| `title` | `chr` | The title of the episode. |
| `aired_date` | `date` | The date the episode originally aired. Format: YYYY-MM-DD. |
| `year` | `dbl` | The year the episode aired. |
| `rating` | `dbl` | The TMDB community rating of the episode (scale 1-10). |
| `votes` | `dbl` | The number of TMDB user votes for the episode rating. |
| `synopsis` | `chr` | A brief description of the episode’s plot from TMDB. |
| `directed_by` | `chr` | The name(s) of the director(s), from Wikipedia. |
| `written_by` | `chr` | The name(s) of the writer(s), from Wikipedia. |
| `us_viewers_millions` | `dbl` | The number of US viewers (in millions) who watched the episode when it first aired, from Wikipedia. |
| `runtime` | `dbl` | Episode runtime in minutes. |
| `tmdb_id` | `dbl` | The unique TMDB episode identifier. |

### Notes:

- **Data Sources**: Episode ratings and synopses are from
  [TMDB](https://www.themoviedb.org/) (The Movie Database). Director,
  writer, and viewership data are from Wikipedia.

- **Rating Change (v0.2.0)**: Prior to v0.2.0, ratings were sourced from
  IMDb. TMDB and IMDb ratings are from different user communities and
  are not directly comparable across package versions.

- Viewer numbers (`us_viewers_millions`) represent the viewership in
  millions, so 9.38 means 9.38 million viewers.

## `transcript_data`

| Column Name | Data Type | Description |
|----|----|----|
| `season` | `dbl` | The season number (1-16). |
| `episode` | `dbl` | The episode number within the season. |
| `title` | `chr` | The title of the episode in which the dialogue line appears. |
| `line` | `dbl` | The line number of the dialogue in the episode (the order in which it appears). |
| `raw_text` | `chr` | The original raw text of the dialogue, possibly including formatting or special characters. |
| `dialogue` | `chr` | Cleaned-up version of the `raw_text`, containing the actual dialogue spoken by the characters in the episode. |

------------------------------------------------------------------------

### Notes:

- The `raw_text` column contains the unprocessed version of the
  dialogue, while `dialogue` is the cleaned-up version.

# Examples

## TMDB Ratings by Season

This plot shows the distribution of TMDB ratings for each season, with
individual episode ratings represented as jittered points.

``` r
data("episode_data")
head(episode_data)
```

    ## # A tibble: 6 × 14
    ##   episode_overall season episode title    aired_date  year rating votes synopsis
    ##             <dbl>  <int>   <int> <chr>    <date>     <int>  <dbl> <dbl> <chr>   
    ## 1               1      1       1 Human F… 2011-01-09  2011   6.93    28 A healt…
    ## 2               2      1       2 Crawl S… 2011-01-16  2011   7.48    21 A leaky…
    ## 3               3      1       3 Sacred … 2011-01-23  2011   7.4     18 Bob tak…
    ## 4               4      1       4 Sexy Da… 2011-02-13  2011   7.1     19 Tina de…
    ## 5               5      1       5 Hamburg… 2011-02-20  2011   7.3     19 Linda a…
    ## 6               6      1       6 Sheesh!… 2011-03-06  2011   7       20 Tina is…
    ## # ℹ 5 more variables: directed_by <chr>, written_by <chr>,
    ## #   us_viewers_millions <dbl>, runtime <dbl>, tmdb_id <dbl>

``` r
# Box Plot with Jitter: TMDB Ratings by Season

ggplot(episode_data, aes(x = as.factor(season), y = rating)) +
  geom_boxplot(fill = "lightblue", color = "black", outlier.shape = NA) + 
  geom_point(alpha = 0.6, color = "darkred", position = position_jitter(seed = 42, width = 0.2)) +
  labs(
    title = "TMDB Ratings by Season",
    x = "Season",
    y = "TMDB Rating"
  ) +
  theme_minimal()
```

![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

## Heatmap: Lines Spoken by Season and Episode

The following heatmap shows the number of dialogue lines spoken in each
episode across different seasons of Bob’s Burgers.

``` r
data("transcript_data")
head(transcript_data)
```

    ## # A tibble: 6 × 6
    ##   season episode title        line raw_text                         dialogue    
    ##    <dbl>   <dbl> <chr>       <dbl> <chr>                            <chr>       
    ## 1      1       1 Human Flesh     1 <NA>                             <NA>        
    ## 2      1       1 Human Flesh     2 <NA>                             <NA>        
    ## 3      1       1 Human Flesh     3 <NA>                             <NA>        
    ## 4      1       1 Human Flesh     4 Listen, pep talk.                Listen, pep…
    ## 5      1       1 Human Flesh     5 Big day today.                   Big day tod…
    ## 6      1       1 Human Flesh     6 It's our grand re-re-re-opening. It's our gr…

``` r
## Heatmap: Lines Spoken by Season and Episode

# Summarize number of lines per episode per season
heatmap_data <- transcript_data |>
  filter(!is.na(dialogue)) |>  
  group_by(season, episode) |>
  summarize(total_lines = n(), .groups = "drop") 

# Heatmap: Lines Spoken by Season and Episode
ggplot(heatmap_data, aes(x = as.factor(episode), y = as.factor(season), fill = total_lines)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "lightyellow", high = "red") +
  coord_equal() +
  labs(
    title = "Lines Spoken by Season and Episode",
    x = "Episode",
    y = "Season",
    fill = "Total Lines"
  ) +
  theme_minimal()
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

# Question/Contribute

If there is any data you would like to include or if you have
suggestions, please get in touch. You can contact me at
<steven_ponce@yahoo.com> or open an issue on the [GitHub
repository](https://github.com/poncest/bobsburgersR/issues).

# References

1.  TMDB: [Bob’s
    Burgers](https://www.themoviedb.org/tv/32726-bob-s-burgers)
2.  Wikipedia (episodes): [List of Bob’s Burgers
    episodes](https://en.wikipedia.org/wiki/List_of_Bob%27s_Burgers_episodes#Episodes)
3.  Springfield! Springfield! (episode scripts): [Springfield
    Springfield - Bob’s Burgers
    scripts](https://www.springfieldspringfield.co.uk/episode_scripts.php?tv-show=bobs-burgers)
