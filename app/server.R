library(shiny)
library(tm)
library(stringr)
library(dplyr)

shinyServer(function(input, output) {
  # Load ngram frequency data
  uniFreq <- data.frame(readRDS(file="en_us.dataTrain.1gram.freq.rds"))
  biFreq <- data.frame(readRDS(file="en_us.dataTrain.2gram.freq.rds"))
  triFreq <- data.frame(readRDS(file="en_us.dataTrain.3gram.freq.rds"))
  quadFreq <- data.frame(readRDS(file="en_us.dataTrain.4gram.freq.rds"))
  
  #Load functions to apply to input text
    ###Get last word of input string
  getLastWords <- function(string, words) {
    pattern <- paste("[a-z']+( [a-z']+){", words - 1, "}$", sep="")
    return(substring(string, str_locate(string, pattern)[,1]))
  }
  
    ###Get the first part of the string without the last word
  removeLastWord <- function(string) {
    sub(" [a-z']+$", "", string)
  }
  
    ###Tidy the input text
  tidyText <- function(string){
    #Convert lines from text file into a corpus object for cleaning
    post <- Corpus(VectorSource(string))
    #Convert to all lowercase letter
    post <- tm_map(post,content_transformer(tolower))
    #Remove numbers
    post <- tm_map(post, removeNumbers)
    #Create user-defined cleaning transformation.
    #This will take in a user-defined pattern and convert it to nothing
    removePattern <- content_transformer(function(x, pattern) gsub(pattern, "", x))
    #Remove @, #, http://, and https://
    post <- tm_map(post, removePattern, "([^[:space:]]*)(@|#|http://|https://)([^[:space:]]*)")
    #Remove any character that isn't alphanumeric, a space, or a .
    post <- tm_map(post, removePattern, "[^a-zA-Z0-9_. ]+")
    #Remove an lingering punctuation
    post <- tm_map(post, removePunctuation)
    #Remove extra whitespace between characters
    post <- tm_map(post, stripWhitespace)
    #Remove white space at the beginning and end of strings
    post <- tm_map(post, removePattern, "^\\s+|\\s+$")
    #Convert corpus object back to a data frame with cleaned text
    #post <- data.frame(text=sapply(post, identity), stringsAsFactors=F)
    post <- sapply(post, identity)
    return(as.character(post))
  }
  
    ###Next word prediction function
  predictor <- function(input) {
    options(warn = -1)
    input <- tidyText(input)
    options(warn = 0)
    n <- length(strsplit(input, " ")[[1]])
    prediction <- c()
    if(n >= 3 && length(unique(prediction))<5){
      prediction <- c(prediction, filter(quadFreq, getLastWords(input, 3) == FirstWords)$LastWord)
    }
    if(n >= 2 && length(unique(prediction))<5){
      prediction <- c(prediction, filter(triFreq, getLastWords(input, 2) == FirstWords)$LastWord)
    }
    if(n >= 1 && length(unique(prediction))<5) {
      prediction <- c(prediction, filter(biFreq, getLastWords(input, 1) == FirstWords)$LastWord)
    }
    if(length(prediction)<5){
      prediction <- c(prediction, uniFreq$Words)
    }
    return(unique(prediction)[1:5])
  }
  
  predWords <- reactive({
    predWords <- predictor(input$text_in)
    return(predWords)
  })
  
  output$nextWord <- renderTable({
    predWords <- predWords()
    predWords <- data.frame("First Prediction"=predWords[1],
                           "Second Prediction"=predWords[2],
                           "Third Prediction"=predWords[3],
                           "Fourth Prediction"=predWords[4],
                           "Fifth Prediction"=predWords[5])
    
  }, colnames=FALSE
  )
  
})