library(shiny)
library(data.table)
library(ggplot2)
library(jsonlite)
library(caret)

source("data preparation.R")


#### UI for application ####
ui <- fluidPage(
    
    
    # Application title
    titlePanel("Predict Movie Revenue"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("xaxis",
                        "X-Axis:",
                        choices = names(cleanData), selected = "budget"),
            selectInput("yaxis",
                        "Y-Axis:",
                        choices = names(cleanData), selected = "revenue"),
            selectInput("color",
                        "Color:",
                        choices = names(cleanData), selected = "action"),
            HTML('<hr style="border:solid #ccc 1px;height:1px;background-color:#ccc;">'),
            actionButton("predict", "Predict revenues"),
            checkboxGroupInput(inputId = "selectCols", 
                               label = "Columns used to predict", 
                               choices = names(cleanData[,-c("id","revenue")]),
                               selected = c("budget", "runtime")),
            radioButtons(inputId = "selectModel", 
                         label = "Algorithm", 
                         choices = c("lm", "rpart", "glm"),
                         selected = "glm"),
            sliderInput("splitPercent", label = "Percentage of Data to use for training",
                        min = 0, max = 100, value = 70)
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("ExplorationPlot"),
            HTML('<hr style="border:solid #ccc 1px;height:1px;background-color:#ccc;">'),
            conditionalPanel(condition = "input.predict", 
                             h3("Validation on Test Data")),
            h4(textOutput("redictionRSquare")),
            plotOutput("residPlot")
        )
    )
)