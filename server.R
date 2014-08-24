library(shiny)
library(ROAuth)
library(twitteR)
library(magrittr)
library(stringr)
library(ggplot2)
library(wordcloud)
library(tm)
library(plyr)

  # to run locally, simply replace the key 
  # & secret with your own
key <- "itsasecret"
secret <- "itsasecret"

# #necessary step for running locally on Windows
# download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

cred <- OAuthFactory$new(consumerKey=key,
                         consumerSecret=secret,
                         requestURL='https://api.twitter.com/oauth/request_token',
                         accessURL='https://api.twitter.com/oauth/access_token',
                         authURL='http://api.twitter.com/oauth/authorize')

credfile="cacert.pem"
cred.save="twitter_authentication.Rdata"
load(cred.save)
registerTwitterOAuth(cred)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
  rawData <- reactive(function(){
    
    searchResults <- twListToDF(searchTwitter(input$term,           
                                   n=input$numTweets,
                                   cainfo=credfile))
    
  })
  
  output$table <- reactiveTable(function(){
    df <- head(rawData()[1], n=5)
    colnames(df) <- c("Tweet")
    df
  })
  
  output$wordcloud <- renderPlot(function(){

      #extract hashtags from posts
    extract.txt <- paste("#(\\w){1,15}")
    
    tw.text <- rawData()$text %>%
      enc2native() %>%
      tolower() %>%
      str_extract_all(extract.txt) %>%
      unlist() %>%    
      removeWords(c(stopwords("en"),"rt",input$term,"http")) %>%
      removePunctuation(T) %>%
      stripWhitespace() 
    
    wordc <- tw.text[tw.text!=""] %>%
      table() %>%
      sort(T)
    
    wordcloud(names(wordc),
              wordc, 
              random.color=T,
              colors=rainbow(10),
              scale=c(8,0.5))
  })
  
  
  
  output$tweetfrequency <- renderPlot(function(){
 
    wc <- rawData()$created %>%
      cut(breaks = "hour") %>%
      table() %>%
      as.data.frame() %>%
      head(n=24)
    
    colnames(wc) <- c("date","count")
    
    ggplot(data=wc, aes(x=date, y=count, group=1)) + 
      xlab("") + 
      ylab("Number of tweets") +
      geom_line() + 
      
      theme(axis.text.x = 
              element_text(angle = 90, hjust = 1))
  
  })

})