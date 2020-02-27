#
# This server function uses data from kaggles movies dataset
# and let you run predicitons on this data set
# https://www.kaggle.com/tmdb/tmdb-movie-metadata#tmdb_5000_movies.csv

library(shiny)
library(data.table)
library(ggplot2)
library(jsonlite)
library(caret)

#### Server logic ####
shinyServer(function(input, output) {
    
    output$ExplorationPlot <- renderPlot({
        ggplot(movies, aes_string(x = input$xaxis, y = input$yaxis, color = input$color)) + 
            geom_point(alpha = 0.5) + labs(title = "Exploratory Analysis")
    })
    
    output$residPlot <- renderPlot({
        if(input$predict) {
            useColumns <- c("revenue", input$selectCols)
            set.seed(1234)
            trainIndex <- createDataPartition(cleanData$revenue, p = input$splitPercent/100, list = FALSE)
            trainData <- cleanData[trainIndex, useColumns, with = F]
            testData <- cleanData[-trainIndex,]
            fit2 <- train(revenue ~ .,data = trainData, method = input$selectModel)
            pred <- predict(fit2, testData)
            error <- (testData$revenue - pred)
            ggplot(data = testData, aes(x = 1:nrow(testData), y = error)) + 
                geom_point(alpha = 0.5) + ylim(-max(movies$revenue), max(movies$revenue)) + 
                labs(title = "Residual Plot", x = "row index")
        }
    })
    output$redictionRSquare <- renderText({
        if(input$predict) {
            useColumns <- c("revenue", input$selectCols)
            set.seed(1234)
            trainIndex <- createDataPartition(cleanData$revenue, p = input$splitPercent/100, list = FALSE)
            trainData <- cleanData[trainIndex, useColumns, with = F]
            testData <- cleanData[-trainIndex,]
            fit2 <- train(revenue ~ .,data = trainData, method = input$selectModel)
            pred <- predict(fit2, testData)
            mRev <- mean(testData$revenue)
            rSquare <- sum((pred - mRev)^2) / sum((testData$revenue - mRev)^2)
            paste0("R^2 from prediction: ", round(rSquare, 3))
        }
    })
    
})
