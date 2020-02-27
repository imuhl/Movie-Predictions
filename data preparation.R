library(shiny)
library(data.table)
library(ggplot2)
library(jsonlite)
library(caret)
#### prepare data ####

# data load and column conversion
movies <- fread("data/tmdb_5000_movies.csv", stringsAsFactors = FALSE)
movies$revenue <- as.numeric(movies$revenue)
movies$release_date <- as.Date(movies$release_date)

# replace double-double quotes in chars
chars <- which(sapply(movies, is.character))
movies[,chars] <- movies[,lapply(.SD,gsub, pattern = "\"\"", replacement = "\""), .SDcols = chars]

# get genre columns for most common genres
allGenres <- sapply(movies$genres, fromJSON)
dt_genres <- data.table()
for(i in 1:length(allGenres)) {
    if(length(allGenres[[i]]) < 2) {
        dt_genres <- rbind(dt_genres, NA)
    }
    else {
        dt_genres <- rbind(dt_genres, paste(allGenres[[i]][[2]], collapse = ", "))
    }
    
}
movies$action <- grepl("Action",dt_genres$x)
movies$adventure <- grepl("Adventure",dt_genres$x)
movies$comedy <- grepl("Comedy",dt_genres$x)
movies$crime <- grepl("Crime",dt_genres$x)
movies$crama <- grepl("Drama",dt_genres$x)
movies$romance <- grepl("Romance",dt_genres$x)
movies$thriller <- grepl("Thriller",dt_genres$x)
rm(allGenres, dt_genres)

#### clean data ####
# get numeric columns
numColumns <- sapply(movies, is.numeric)
cleanData <- movies[,numColumns, with=F]
# add genre columns
cleanData <- cbind(cleanData, movies[,action:thriller])

# filter on complete cases with revenue
cleanData <- cleanData[complete.cases(cleanData),]
cleanData <- cleanData[revenue != 0,]