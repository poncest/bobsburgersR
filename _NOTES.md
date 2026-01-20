# bobsburgersR Package Update Plan
## From v0.09 (S1-S14) → v0.2.0 (S1-S16)

**Created:** January 2026  
**Approach:** Methodical review → verify → update one file at a time  
**Philosophy:** Assume everything is broken until proven otherwise

---

## Phase 0: Preparation & Inventory

### 0.1 Clone/Pull Latest & Create Working Branch
```bash
git checkout main
git pull origin main
git checkout -b update-s15-s16
```

### 0.2 Document Current State
- [ ] List all files in `data-raw/` (scraping scripts)
- [ ] List all files in `R/` (package functions)
- [ ] List all files in `data/` (exported datasets)
- [ ] List all files in `man/` (documentation)
- [ ] Note current version in DESCRIPTION
- [ ] Note current data row counts:
  - `imdb_wikipedia_data`: ___ rows (should be ~270 for S1-14)
  - `transcript_data`: ___ rows

### 0.3 Verify Current Package Installs & Works
```r
# Clean install from local
devtools::install_local(".", force = TRUE)
library(bobsburgersR)

# Verify datasets load
data("imdb_wikipedia_data")
data("transcript_data")

# Quick sanity checks
nrow(imdb_wikipedia_data)
max(imdb_wikipedia_data$season)  # Should be 14
nrow(transcript_data)
max(transcript_data$season)       # Should be 14
```

---

## Phase 1: Script Audit (Before Running Anything)

### 1.1 IMDb Scraping Script Review

**File:** `data-raw/[imdb_script].R` (exact name TBD)

**Check for:**
- [ ] Which packages used? (rvest, httr, polite, etc.)
- [ ] Hard-coded season numbers? (need to extend to 16)
- [ ] CSS selectors still valid? (IMDb redesigns frequently)
- [ ] Rate limiting/polite scraping implemented?
- [ ] Error handling for missing episodes?
- [ ] Date parsing approach (still works?)

**Common IMDb Breakages:**
- IMDb moved to dynamic JavaScript rendering (rvest may not work)
- Class names like `.ipc-title` change periodically
- URL structure changes (`/episodes/?season=X` vs `/episodes?season=X`)

**Verification Test:**
```r
# Test ONE page manually before running full script
library(rvest)
test_url <- "https://www.imdb.com/title/tt1561755/episodes/?season=14"
page <- read_html(test_url)
# Check if selectors return expected content
```

### 1.2 Wikipedia Scraping Script Review

**File:** `data-raw/[wikipedia_script].R` (exact name TBD)

**Check for:**
- [ ] Table selection approach (table index? class name?)
- [ ] Column name changes in Wikipedia tables?
- [ ] Viewer data format (millions, with footnotes?)
- [ ] Director/writer parsing (multiple names handling?)
- [ ] Season 15/16 tables exist on Wikipedia?

**Common Wikipedia Breakages:**
- Table index changes when new sections added
- Footnote markers in viewer numbers (`7.89[45]`)
- "TBA" or "TBD" for recent episodes

**Verification Test:**
```r
library(rvest)
wiki_url <- "https://en.wikipedia.org/wiki/List_of_Bob%27s_Burgers_episodes"
page <- read_html(wiki_url)
tables <- page |> html_elements("table.wikitable")
length(tables)  # How many tables? Which one is episodes?
```

### 1.3 Transcript Scraping Script Review

**File:** `data-raw/[transcript_script].R` (exact name TBD)

**Check for:**
- [ ] Springfield! Springfield! site still active?
- [ ] URL pattern for episodes still valid?
- [ ] Text extraction selectors still work?
- [ ] Episode title matching logic (to align with IMDb data)
- [ ] Encoding handling (special characters?)
- [ ] Season 15/16 transcripts available?

**Common Transcript Breakages:**
- Site structure changes
- Missing transcripts for newer episodes
- Inconsistent episode naming

**Verification Test:**
```r
# Test one known episode
test_url <- "https://www.springfieldspringfield.co.uk/view_episode_scripts.php?tv-show=bobs-burgers&episode=s14e01"
# Check if accessible and parseable
```

---

## Phase 2: Script-by-Script Verification & Fixes

### 2.1 IMDb Script
- [ ] Run on EXISTING data (S1-14) first
- [ ] Compare output to current `imdb_wikipedia_data`
- [ ] Fix any selector/parsing issues
- [ ] Document what changed
- [ ] Test on S15 (partial run)
- [ ] Test on S16 (partial run)

### 2.2 Wikipedia Script  
- [ ] Run on EXISTING data (S1-14) first
- [ ] Compare output to current data
- [ ] Fix any issues
- [ ] Test on S15-16

### 2.3 Transcript Script
- [ ] Run on a FEW KNOWN episodes first
- [ ] Compare to current transcript data
- [ ] Fix any issues
- [ ] Check S15-16 transcript availability

### 2.4 Data Joining/Cleaning Script
- [ ] Review how IMDb + Wikipedia data are merged
- [ ] Review any cleaning/transformation steps
- [ ] Verify join keys still valid
- [ ] Check for edge cases (special episodes, etc.)

---

## Phase 3: Data Collection (S15-S16)

### 3.1 Research: What Episodes Exist?
- [ ] Confirm S15 episode count (Wikipedia)
- [ ] Confirm S16 episode count (in progress? completed?)
- [ ] Note any special episodes (Halloween, holiday, etc.)
- [ ] Check air dates to ensure complete data available

### 3.2 Run Updated Scripts
- [ ] IMDb data for S15-S16
- [ ] Wikipedia data for S15-S16  
- [ ] Transcripts for S15-S16
- [ ] Merge new data with existing

### 3.3 Quality Checks
- [ ] No duplicate episodes
- [ ] No missing episodes
- [ ] Ratings in valid range (1-10)
- [ ] Dates parse correctly
- [ ] Viewer numbers reasonable
- [ ] Transcript data aligns with episode data

---

## Phase 4: Package Updates

### 4.1 Data Files
- [ ] Regenerate `data/imdb_wikipedia_data.rda`
- [ ] Regenerate `data/transcript_data.rda`
- [ ] Verify file sizes reasonable

### 4.2 Documentation Updates
- [ ] Update `man/imdb_wikipedia_data.Rd` (if auto-generated, run roxygen2)
- [ ] Update `man/transcript_data.Rd`
- [ ] Update README.Rmd:
  - [ ] Change "seasons 1-14" → "seasons 1-16"
  - [ ] Update example outputs if they show row counts
  - [ ] Re-knit to README.md
- [ ] Update NEWS.md with changelog

### 4.3 DESCRIPTION Updates
- [ ] Version: 0.0.9 → 0.2.0 (or appropriate)
- [ ] Date field (if present)
- [ ] Any new package dependencies?

### 4.4 Housekeeping (Optional but Recommended)
- [ ] Remove `.Rhistory` from repo, add to .gitignore
- [ ] Review renv - still needed? Or remove?
- [ ] Consider lifecycle badge (experimental → stable?)
- [ ] Check R-CMD-check still passes

---

## Phase 5: Testing & Validation

### 5.1 Package Checks
```r
devtools::check()        # Full R CMD check
devtools::test()         # If tests exist
devtools::document()     # Regenerate docs
```

### 5.2 Data Validation
```r
# Comprehensive checks
library(bobsburgersR)

# Counts
stopifnot(max(imdb_wikipedia_data$season) == 16)
stopifnot(max(transcript_data$season) == 16)

# No NAs in key columns
stopifnot(sum(is.na(imdb_wikipedia_data$episode_overall)) == 0)
stopifnot(sum(is.na(imdb_wikipedia_data$rating)) == 0)

# Rating range
stopifnot(all(imdb_wikipedia_data$rating >= 1 & imdb_wikipedia_data$rating <= 10))

# Episode sequence
stopifnot(all(diff(imdb_wikipedia_data$episode_overall) == 1))
```

### 5.3 Visual Checks
- [ ] Re-run README examples, verify plots look correct
- [ ] Spot-check a few S15-S16 episodes manually

---

## Phase 6: Release

### 6.1 Final Commits
```bash
git add -A
git commit -m "Update data to include seasons 15-16, bump to v0.2.0"
git push origin update-s15-s16
```

### 6.2 Merge & Tag
```bash
git checkout main
git merge update-s15-s16
git tag -a v0.2.0 -m "Seasons 1-16, updated scraping scripts"
git push origin main --tags
```

### 6.3 Announce (Optional)
- [ ] Update repo description if needed
- [ ] Consider blog post / social media if desired

---

## Risk Log

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| IMDb selectors broken | High | High | Test manually first, may need new approach |
| Wikipedia table structure changed | Medium | Medium | Inspect current table structure |
| Transcripts unavailable for S16 | Medium | Medium | May need to release with partial S16 |
| Scraping blocked/rate-limited | Medium | Medium | Use polite package, add delays |
| Edge cases (special episodes) | Low | Low | Manual review of episode list |

---

## Notes & Decisions Log

_Use this section to document decisions made during the update process_

| Date | Decision | Rationale |
|------|----------|-----------|
| | | |

---

## Time Estimate

| Phase | Estimated Time |
|-------|----------------|
| Phase 0: Preparation | 30 min |
| Phase 1: Script Audit | 1-2 hours |
| Phase 2: Script Fixes | 2-4 hours (depends on breakage) |
| Phase 3: Data Collection | 1-2 hours |
| Phase 4: Package Updates | 1 hour |
| Phase 5: Testing | 30 min |
| Phase 6: Release | 15 min |
| **Total** | **6-10 hours** (spread across sessions) |

---

*This plan follows Steven's established pattern: thorough review → systematic fixes → one file at a time → comprehensive documentation*


# Data Source Change: IMDb → TMDB

**Date:** January 2026  
**Affects:** `imdb_wikipedia_data` dataset (ratings column)

---

## What Changed

| Aspect | Before (v0.0.0.9000) | After (v0.2.0) |
|--------|----------------------|----------------|
| Rating source | IMDb user ratings | TMDB community ratings |
| Scale | 1-10 | 1-10 |
| Scraping method | Web scraping (rvest) | API (official) |
| Seasons covered | 1-14 | 1-16 |

---

## Why We Switched

**IMDb blocked web scraping in late 2024/early 2025:**

- IMDb implemented AWS WAF (Web Application Firewall)
- The firewall returns a JavaScript challenge page instead of episode data
- `rvest` cannot execute JavaScript, so scraping became impossible
- This is a permanent change - IMDb intentionally blocks automated access

**Evidence from testing (January 2026):**
```r
# IMDb returns only this - a bot challenge page, not episode data
page |> html_nodes("*") |> html_name() |> table()
#  script   meta   body    div     h1   head noscript  style  title 
#       3      2      1      1      1      1        1      1      1 
```

**Alternatives evaluated:**

| Source | Outcome |
|--------|---------|
| IMDb direct scraping | ❌ Blocked by WAF |
| OMDB API (IMDb data) | ⚠️ 152/306 episodes had "N/A" ratings |
| TVmaze API | ❌ Connection issues |
| **TMDB API** | ✅ Complete ratings, official API |

---

## Impact on Users

**Breaking change for analysis comparing ratings:**
- Old data: IMDb ratings (e.g., S1E1 "Human Flesh" = 7.7)
- New data: TMDB ratings (e.g., S1E1 "Human Flesh" = 6.9)

**These are different rating communities** - direct comparison between old and new package versions is not meaningful for the `rating` column.

**No impact on:**
- Episode titles, air dates, seasons, episode numbers
- Synopsis/plot descriptions
- General trends and patterns within the dataset

---

## Documentation Updates Needed

### README.md

**Data Dictionary section - update:**

```markdown
| `rating` | `dbl` | The TMDB community rating of the episode (scale 1-10). Note: v0.1.x used IMDb ratings; v0.2.0+ uses TMDB ratings due to IMDb blocking automated access. |
```

**Add note in Data Dictionary:**

```markdown
### Note on Ratings

As of v0.2.0, ratings are sourced from TMDB (The Movie Database) rather than IMDb. 
IMDb implemented bot protection in 2024-2025 that prevents web scraping. TMDB 
provides an official API with complete episode data. While both use a 1-10 scale, 
the ratings come from different user communities and are not directly comparable.
```

### NEWS.md

```markdown
# bobsburgersR 0.2.0

## Major Changes

* **Seasons 15-16 added** - Dataset now covers all 16 seasons (309 episodes)
* **Rating source changed from IMDb to TMDB** - IMDb implemented bot protection 
  that blocks web scraping. Ratings now come from TMDB's community ratings via 
  their official API. Both use a 1-10 scale but are from different user communities.

## Data Changes

* `imdb_wikipedia_data` renamed to `episode_data` (or keep name but update docs)
* `rating` column now contains TMDB ratings (was IMDb)
* Added columns: `votes`, `tmdb_id`
* Removed columns: [if any]

## Technical Changes

* Replaced `01_imdb_web_scrape.R` with `01_tmdb_api_fetch.R`
* API key required for data refresh (TMDB_API_KEY in .Renviron)
```

### Data Documentation (R/data_documentation.R)

Update the `@source` field:

```r
#' @source 
#' - Episode data: TMDB API (https://www.themoviedb.org/)
#' - Wikipedia data: https://en.wikipedia.org/wiki/List_of_Bob%27s_Burgers_episodes
#' 
#' Note: Prior to v0.2.0, ratings were sourced from IMDb. TMDB ratings are used 
#' from v0.2.0 onwards due to IMDb blocking automated access.
```

---

## Lessons Learned

**Add to project lessons learned file:**

1. **Web scraping is fragile** - Sites can (and do) block scrapers at any time
2. **Official APIs are more reliable** - TMDB API is stable, documented, and sanctioned
3. **Document data source changes clearly** - Users need to know rating comparisons across versions aren't valid
4. **Keep API keys secure** - Use `.Renviron` + `.gitignore`
5. **Test before assuming** - We tested OMDB first (had gaps), then found TMDB worked better

---

## Column Name Decision

Consider whether to rename the dataset:

| Option | Name | Pros | Cons |
|--------|------|------|------|
| A | `imdb_wikipedia_data` | No breaking change | Misleading (no longer IMDb) |
| B | `tmdb_wikipedia_data` | Accurate | Breaking change |
| C | `episode_data` | Clean, source-agnostic | Breaking change |

**Recommendation:** Option C (`episode_data`) - cleaner long-term, and v0.2.0 is a good time for breaking changes.

---

*Reference this document when updating README.Rmd, NEWS.md, and R/data_documentation.R*
