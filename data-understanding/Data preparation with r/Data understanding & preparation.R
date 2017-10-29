## Package installing

install.packages(c("tidyr", "devtools"))
install.packages("stringr")
library(tidyr)
library(devtools)
library(stringr)
## Import the data & Check the varible names and types.

sample <- read.csv("sample100000.csv")

str(sample) ## class is factor for each datetime data column.

## Daytime data
## - Create new variable: Daypart (factor)
## - Create new variable: Date

## Start with changing datetime columns' classes to time

sample$pickup_datetime <- strptime(sample$pickup_datetime,"%Y-%m-%d %H:%M:%S")
sample$dropoff_datetime <- strptime(sample$dropoff_datetime,"%Y-%m-%d %H:%M:%S")

## Add the trip duration as a new variable

sample$duration <- as.numeric(difftime(sample$dropoff_datetime,sample$pickup_datetime, units = "mins"))
sample$duration <- round(sample$duration, digits = 2)

## I will use the pickup hour for dayparting based on tv & radio broadcast dayparts.

sample$pickup_hours = as.numeric(format(sample$pickup_datetime, "%H"))

sample$pickup_daypart[sample$pickup_hours >= 6 & sample$pickup_hours < 10 ] <- "morning drive time"
sample$pickup_daypart[sample$pickup_hours >= 10 & sample$pickup_hours < 15 ] <- "midday"
sample$pickup_daypart[sample$pickup_hours >= 15 & sample$pickup_hours < 19 ] <- "afternoon drive time"
sample$pickup_daypart[sample$pickup_hours >= 19 ] <- "evening"
sample$pickup_daypart[sample$pickup_hours >= 0 & sample$pickup_hours < 6 ] <- "overnight"

sample$pickup_hours <- NULL

## I want to keep date as a seperate column. This will be used to pull each date's climate info from climate data.

sample$date = format(sample$pickup_datetime, "%Y-%m-%d")

# Read the climate data. This data includes average temperature measured in Fahrenheit for each day in 2015. Also There are 7 dummies for categorical weather type variable.

climate_data <- read.csv("ny-climate-data.csv")

climate_data[is.na(climate_data)] <- 0  # Fix the NA's in climate data

# Join the climate data

colnames(climate_data)[1] <- "date" # Column names should match to use join function.

sample_2 <- merge(x = sample, y = climate_data, by = "date", all.x = TRUE)

colnames(sample_2)[17] <- "average_temperature"

#ftp://ftp.ncdc.noaa.gov/pub/data/cdo/documentation/LCD_documentation.pdf for the definition of weather columns.


