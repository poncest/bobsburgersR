#' Bob's Burgers Episode Data
#'
#' A dataset containing information about Bob's Burgers episodes, including
#' ratings, air dates, synopses, and production credits. Data is compiled from
#' TMDB (The Movie Database) and Wikipedia.
#'
#' @format A data frame with 309 rows and 14 variables:
#' \describe{
#'   \item{episode_overall}{The overall episode number in the series (1-309).}
#'   \item{season}{The season number (1-16).}
#'   \item{episode}{The episode number within the season.}
#'   \item{title}{The title of the episode.}
#'   \item{aired_date}{The date the episode originally aired (Date format).}
#'   \item{year}{The year the episode aired.}
#'   \item{rating}{The TMDB community rating of the episode (scale 1-10). Note: Prior to v0.2.0, ratings were sourced from IMDb. TMDB and IMDb ratings are from different user communities and are not directly comparable.}
#'   \item{votes}{The number of TMDB user votes for the episode rating.}
#'   \item{synopsis}{A brief description of the episode's plot from TMDB.}
#'   \item{directed_by}{The name(s) of the director(s), from Wikipedia.}
#'   \item{written_by}{The name(s) of the writer(s), from Wikipedia.}
#'   \item{us_viewers_millions}{The number of US viewers (in millions) who watched the episode when it first aired, from Wikipedia. NA for episodes where viewership data is not available.}
#'   \item{runtime}{Episode runtime in minutes.}
#'   \item{tmdb_id}{The unique TMDB episode identifier.}
#' }
#'
#' @details
#' This dataset was renamed from \code{imdb_wikipedia_data} in v0.2.0. The rating
#' source changed from IMDb to TMDB because IMDb implemented bot protection that
#' prevents web scraping. TMDB provides an official API with complete episode data.
#'
#' @source
#' \itemize{
#'   \item TMDB API: \url{https://www.themoviedb.org/tv/32726-bob-s-burgers}
#'
#'   \item Wikipedia: \url{https://en.wikipedia.org/wiki/List_of_Bob\%27s_Burgers_episodes}
#' }
#'
#' @examples
#' # Load the data
#' data(episode_data)
#'
#' # View structure
#' str(episode_data)
#'
#' # Summary statistics
#' summary(episode_data$rating)
#'
#' # Count episodes per season
#' table(episode_data$season)
#'
"episode_data"


#' Bob's Burgers Transcript Data
#'
#' A dataset containing the transcripts of Bob's Burgers episodes, including
#' dialogue and stage directions.
#'
#' @format A data frame with 204,027 rows and 6 variables:
#' \describe{
#'   \item{season}{The season number (1-16).}
#'   \item{episode}{The episode number within the season.}
#'   \item{title}{The title of the episode.}
#'   \item{line}{The line number of the dialogue (order of appearance within episode).}
#'   \item{raw_text}{The original text from the transcript, including formatting and stage directions.}
#'   \item{dialogue}{Cleaned version of \code{raw_text} with stage directions and formatting removed.}
#' }
#'
#' @details
#' Transcripts include both spoken dialogue and stage directions (actions,
#' scene descriptions). The \code{raw_text} column preserves the original
#' formatting, while \code{dialogue} contains cleaned text suitable for
#' text analysis.
#'
#' @source Springfield! Springfield! (\url{https://www.springfieldspringfield.co.uk/})
#'
#' @examples
#' # Load the data
#' data(transcript_data)
#'
#' # View structure
#' str(transcript_data)
#'
#' # Count lines per season
#' table(transcript_data$season)
#'
#' # View first few lines of dialogue
#' head(transcript_data$dialogue, 20)
#'
"transcript_data"
