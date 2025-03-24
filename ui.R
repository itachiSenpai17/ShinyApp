# ui.R

library(shiny)
library(shinythemes)
library(DT)
library(wordcloud2)

ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("✈️ Sentiment Analysis of US Airline Tweets"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV file", accept = ".csv"),
      textInput("airline_filter", "Filter by Airline (optional)", value = ""),
      actionButton("analyze", "Run Sentiment Analysis"),
      br(), br(),
      verbatimTextOutput("summary_text")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("📄 Data Preview", DTOutput("data_table")),
        tabPanel("📊 Sentiment Plot", plotOutput("sentiment_plot", height = "500px")),
        tabPanel("🌤️ Wordcloud - Positive", wordcloud2Output("pos_wordcloud")),
        tabPanel("🌧️ Wordcloud - Negative", wordcloud2Output("neg_wordcloud"))
      )
    )
  )
)
