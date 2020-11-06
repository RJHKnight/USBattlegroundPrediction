get_summary_stats <- function(results)
{
  by_state <- results %>%
    group_by(state) %>%
    nest()

  state_model <- function(df) {
    lm(vote_differential_rep ~ pct_votes, data = df)
  }

  predict_100 <- function(model) {
    return (predict(model, data.frame(pct_votes = 1))[1])
  }

  by_state <- by_state %>%
    mutate(model = map(data, state_model)) %>%
    mutate(glance = map(model, broom::glance)) %>%
    unnest(glance) %>%
    mutate(prediction_100 = map(model, predict_100)) %>%
    unnest(prediction_100)

  basic_info <- by_state %>%
    select(state, r.squared, prediction_100) %>%
    ungroup()

  other_info <- results %>%
    group_by(state) %>%
    arrange(timestamp) %>%
    summarise(
      last_update = with_tz(max(timestamp), "EST"),
      current_leading_candidate = tail(leading_candidate_name, 1)
    )

  basic_info <- basic_info %>%
    left_join(other_info, by = "state") %>%
    mutate(predicted_leading_candidate = if_else(prediction_100 > 0, "Trump", "Biden"))

  return (basic_info)
}
