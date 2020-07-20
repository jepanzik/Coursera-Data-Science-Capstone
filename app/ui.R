#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("cerulean"),
  
  # Application title
  titlePanel("Next Word Predictor Application"),
  
  
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type="tabs",
                  tabPanel("Next Word Predictor",
                           h4("5 Suggestions for the Next Word:"),
                           tableOutput("nextWord"),
                           HTML("<br><br>"),
                           h4('Enter your word/phrase:'),
                           tags$textarea(id="text_in"),
                           submitButton("Submit"),
                           HTML("<br><br>"),
                           helpText("Enter a string of words and hit 'Submit'. The predictor function will provide 5 suggestions for the next word.")
                           ),
                  tabPanel("Description",
                           includeHTML("appdescription.html")
                           )
                  )
      
      
      
      
    )
  )
)
