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

## Start with changing their class to character.

sample$pickup_datetime <- as.character(sample$pickup_datetime)
sample$dropoff_datetime <- as.character(sample$dropoff_datetime)

class(sample$pickup_datetime) 
class(sample$dropoff_datetime)

## Split date & time data

str_split(sample$pickup_datetime, " ")

pickup_time <- matrix(unlist(pickup_time), ncol=2, byrow=TRUE)

