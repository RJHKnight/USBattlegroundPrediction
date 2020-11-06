library(readr)

load_data <- function()
{
  results <- read_csv("https://alex.github.io/nyt-2020-election-scraper/battleground-state-changes.csv")

  results  <- results %>%
    filter(str_detect(state, "Georgia|Penn")) %>%
    mutate(vote_differential_rep = if_else(leading_candidate_name == "Trump", vote_differential, -vote_differential)) %>%
    mutate(pct_votes = (leading_candidate_votes + trailing_candidate_votes) / (trailing_candidate_votes + leading_candidate_votes + votes_remaining ))

  return (results)
}
