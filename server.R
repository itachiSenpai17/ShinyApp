# server.R

library(shiny)
library(syuzhet)
library(tidytext)
library(dplyr)
library(ggplot2)
library(wordcloud2)
library(DT)

server <- function(input, output) {
  # Read uploaded CSV file
  raw_data <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  # Filter tweets based on the airline keyword if provided
  filtered_texts <- eventReactive(input$analyze, {
    tweets <- raw_data()$text
    if (input$airline_filter != "") {
      tweets <- tweets[grepl(input$airline_filter, tweets, ignore.case = TRUE)]
    }
    tweets
  })
  
  # Display summary information in the sidebar
  output$summary_text <- renderPrint({
    req(filtered_texts())
    paste("Showing", length(filtered_texts()), "tweets",
          ifelse(input$airline_filter != "", paste("for airline:", input$airline_filter), ""))
  })
  
  # Calculate sentiment scores using the NRC lexicon
  sentiment_scores <- reactive({
    req(filtered_texts())
    get_nrc_sentiment(filtered_texts())
  })
  
  # Render data preview table
  output$data_table <- renderDT({
    datatable(raw_data(), options = list(pageLength = 5))
  })
  
  # Plot the distribution of sentiment counts
  output$sentiment_plot <- renderPlot({
    sentiments <- sentiment_scores()
    sentiment_summary <- colSums(sentiments[, 1:8])
    df <- data.frame(sentiment = names(sentiment_summary), count = sentiment_summary)
    
    ggplot(df, aes(x = reorder(sentiment, -count), y = count, fill = sentiment)) +
      geom_bar(stat = "identity") +
      theme_minimal(base_size = 15) +
      labs(title = "Distribution of Emotions in Tweets", x = "", y = "Count") +
      theme(legend.position = "none") +
      scale_fill_brewer(palette = "Set2")
  })
  
  # Generate a wordcloud for tweets (positive words)
  output$pos_wordcloud <- renderWordcloud2({
    df <- tibble(text = filtered_texts()) %>%
      unnest_tokens(word, text) %>%
      anti_join(stop_words) %>%
      count(word, sort = TRUE) %>%
      top_n(100)
    wordcloud2(df)
  })
  
  # Generate a wordcloud for tweets with more negative sentiment
  output$neg_wordcloud <- renderWordcloud2({
    sentiments <- sentiment_scores()
    neg_texts <- filtered_texts()[which(sentiments$negative > sentiments$positive)]
    
    df <- tibble(text = neg_texts) %>%
      unnest_tokens(word, text) %>%
      anti_join(stop_words) %>%
      count(word, sort = TRUE) %>%
      top_n(100)
    wordcloud2(df)
  })
}
