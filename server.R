library(shiny)
library(dplyr)
library(ggplot2)
library(broom)
library(formattable)
library(stringr)
library(tidyr)
library(purrr)
library(lubridate)
library(plotly)

source("./Load Data.R", local = TRUE)
source("./Summary Stats.R")

results <- load_data()

shinyServer(function(input, output, session) {

  results <- reactivePoll(10000, session,
                          checkFunc = function() {floor_date(now(), "30 second")},
                          valueFunc = load_data)

    output$mainPlot <- renderPlotly({
        main_plot <- ggplot(results(), aes(pct_votes, vote_differential_rep)) +
            geom_point(alpha = 0.6) +
            geom_smooth(method = "lm", se = FALSE) +
            geom_line(y = 0, colour = "red", linetype = "dashed") +
            scale_x_continuous(labels = scales::percent, limits = c(NA, 1)) +
            scale_y_continuous(labels = scales::number) +
            facet_wrap(~ state, scale = "free",ncol = 1) +
            theme_bw()

        ggplotly(main_plot)

    })

    summary_stats <- reactive({get_summary_stats(results())})

    output$stats <- renderFormattable({
      basic_info <- summary_stats() %>%
        mutate(r.squared = scales::percent(r.squared),
               prediction_100 = scales::number(prediction_100, big.mark = ",")
        ) %>%
        select(state, r.squared, prediction_100) %>%
        rename(
          State = state,
          `R Squared` = r.squared,
          `Predicted Lead (Rep) @ 100% of votes` = prediction_100)

      formatted_basic<- formattable(basic_info)
    })

    output$other <- renderFormattable({
      other_info <- summary_stats() %>%
        select(state, last_update, current_leading_candidate, predicted_leading_candidate) %>%
        rename(
          State = state,
          `Last Update Time (EST)` = last_update,
          `Current Winner` = current_leading_candidate,
          `Predicted Winner` = predicted_leading_candidate)

      formatted_other <- formattable(other_info)
    })

})
