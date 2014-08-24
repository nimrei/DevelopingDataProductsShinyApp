library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("MinerBird v0.1"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      
      numericInput("numTweets", "Select a number of tweets:"
                   ,50,10,100),
      radioButtons("term",
                   "Select which account's tweets to view:",
                   c("Data Mining"="datamining",
                     "Data Science"="datascience",
                     "Simply Statistics"="simplystats",
                     "Rstudio"="rstudio",
                     "Coursera"="coursera",
                     "John Hopkins"="HopkinsMedicine",
                     "kaggle"="kaggle")),
      submitButton(text="Run")
      
   
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      
      h4("Latest selected tweets"),
      tableOutput("table"),

      h4("Twitter Activity in last 24 hours"),
      plotOutput("tweetfrequency"),
      
      h4("Whats being mentioned"),
      plotOutput("wordcloud")
      

      
    )
  )
))