library(shiny)
library(dplyr)
library(ggplot2)
library(broom)
library(formattable)
library(stringr)
library(tidyr)
library(purrr)
library(lubridate)

source("./Load Data.R", local = TRUE)
source("./Summary Stats.R")

results <- load_data()

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$mainPlot <- renderPlot({
        ggplot(results, aes(pct_votes, vote_differential_rep)) +
            geom_point(alpha = 0.6) +
            geom_smooth(method = "lm", se = FALSE) +
            geom_line(y = 0, colour = "red", linetype = "dashed") +
            scale_x_continuous(labels = scales::percent, limits = c(NA, 1)) +
            scale_y_continuous(labels = scales::number) +
            facet_wrap(~ state, scale = "free",ncol = 1) +
            theme_bw()

    })

    summary_stats <- get_summary_stats(results)

    # Formatting
    basic_info <- summary_stats %>%
      mutate(r.squared = scales::percent(r.squared),
             prediction_100 = scales::number(prediction_100, big.mark = ",")
      ) %>%
      select(state, r.squared, prediction_100) %>%
      rename(
        State = state,
        `R Squared` = r.squared,
        `Predicted Lead (Rep) @ 100% of votes` = prediction_100)

    formatted_basic<- formattable(basic_info)

    output$stats <- renderFormattable({formatted_basic})

    other_info <- summary_stats %>%
      select(state, last_update, current_leading_candidate, predicted_leading_candidate) %>%
      rename(
        State = state,
        `Last Update Time (EST)` = last_update,
        `Current Winner` = current_leading_candidate,
        `Predicted Winner` = predicted_leading_candidate)

    formatted_other <- formattable(other_info)

    output$other <- renderFormattable({formatted_other})

})
