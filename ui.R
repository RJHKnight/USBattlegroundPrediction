library(shiny)
library(formattable)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Linear Fit Prediction for Battleground States"),
    sidebarLayout(
        sidebarPanel(
            formattableOutput("stats"),
            br(),
            formattableOutput("other")
        ),
        mainPanel(
            plotlyOutput("mainPlot", height = "1200px"),
            "A simple linear fit of Republican lead as a percentage of total votes counted.",
            br(),
            "Data is provided by the good folks over at the ", tags$a("NYTimes Election Scraper", href = "https://github.com/alex/nyt-2020-election-scraper", ),
            br(),
            "Source code for this model available on my ", tags$a("github", href = "https://github.com/RJHKnight/USBattlegroundPrediction")
        )
    )
))
