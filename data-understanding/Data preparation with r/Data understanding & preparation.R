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

climate_data <- read.csv("nyc-daily-weather.csv")

climate_data[is.na(climate_data)] <- 0  # Fix the NA's in climate data

summary(climate_data) 

# W02, W04, W06 will not be useful. 
# W01 and W08 are very similar. W01 = Fog, ice fog, or freezing fog (may include heavy fog) W08 = Smoke or haze. So we can start with keeping one of them.
# Average temperature column is empty for some reason so did not include that column. We can create a new average column based on average of max-min temperatures.
# First column is location identifier so we can remove that as well.

climate_data <- subset(climate_data, , -c(1,8,9,10,11)) #Drop the columns that we are not going to use.

climate_data$temperature <- (climate_data$TMAX + climate_data$TMIN) / 2 #Add the average temp. column.
climate_data <- subset(climate_data, , -c(4,5))

colnames(climate_data)[1] <- "date"
colnames(climate_data)[2] <- "precipitation"
colnames(climate_data)[3] <- "snowfall"
colnames(climate_data)[4] <- "fog"

str(climate_data)
climate_data$date <- strptime(climate_data$date,"%Y-%m-%d")
climate_data$fog <-  factor
str(climate_data) # Now the dataset is ready to be merged. 

# Join the climate data (GHCN (Global Historical Climatology Network))

sample_merged <- merge(x = sample, y = climate_data, by = "date", all.x = TRUE)

# I want to add household income data in neighborhood level. I will write the current merged table and will do some manual cleaning stuff for neigborhood names.

write.csv(sample_merged, file = "sample_merged.csv")

