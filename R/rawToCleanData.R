#===============================================================================
# Script Name: rawToCleanData.R
# Project : Reporting Strategy
# Author : Melvin Njuaka
# Description : This script read files from their directory

#===============================================================================



# Dependencies and libraries----------------------------------------------------

library(dplyr)


# get the files directories ----------------------------------------------------

fileDir <- function(){
  
  dir <- paste0(getwd(),"/data")
  
  return(dir)
}
  
print(fileDir())

# read files ------------------------------------------------------------------

structureFiles <- function(filename){
  filePath <- paste0(fileDir(), "/", filename)
  data <- read.csv(filePath, check.names = FALSE)
  return(data)
}


deliminatedFiles <- function(filename){
  filePath <- paste0(fileDir(), "/", filename)
  data <- read.csv(filePath, sep = ";" , check.names = FALSE)
  return(data)
}

tempData <- structureFiles("temperature.csv")
rainData <- structureFiles("modified_rain.csv")
pestData <- deliminatedFiles("pesticides_usage.csv")
yieldData <- deliminatedFiles("yield.csv")


head(yieldData)
head(pestData)
head(rainData)
head(tempData)


# Renaming columns names and changing inappropriate value of a column-----------

renameYieldData <- function(data){
  data <- data %>%
    rename("yield_value_hg_per_ha" = "Value", "country" = "Country", "year" = "Year", "crop_type" = "Item") %>%
    mutate(country = ifelse(country =="CÃ´te d'Ivoire", "Côte d'Ivoire", country))
}

renamePestData <- function(data){
  data <- data %>%
    rename("pest_value_tonnes" = "Value", "country" = "Country", "year" = "Year") %>%
    mutate(country = ifelse(country =="CÃ´te d'Ivoire", "Côte d'Ivoire", country))
}


renameRainData <- function(data){
  data <- data %>%
    mutate(country = ifelse(country =="Cote d'Ivoire", "Côte d'Ivoire", country))
}


modifyTempData <- function(data){
 
  data <- data %>%
    rename("country" = "Country", "year" = "Year", "avg_temp_degree_celsius" = "avg_temp (°C)")
  
  data <- data %>%
    mutate(across(all_of("avg_temp_degree_celsius"), ~ ifelse(is.na(.), median(., na.rm = TRUE), .)))
  
  data <- data %>%
    mutate(country = ifelse(country =="CÃ´te D'Ivoire", "Côte d'Ivoire", country))
}


modifiedTempData <- modifyTempData(tempData)
modifiedrainData <- renameRainData(rainData)
modifiedpestData <- renamePestData(pestData)
modifiedyieldData <- renameYieldData(yieldData)

head(modifiedTempData)
head(modifiedrainData)
head(modifiedpestData)
head(modifiedyieldData)


# combine all data ------------------------------------------------------------

combinedData <- modifiedTempData %>% 
  inner_join(modifiedyieldData, by = c("country", "year")) %>%
  inner_join(modifiedrainData, by = c("country", "year")) %>%
  inner_join(modifiedpestData, by = c("country", "year")) %>%
  select(country, year, avg_temp_degree_celsius, pest_value_tonnes, average_rain_fall_mm_per_year,
         crop_type, yield_value_hg_per_ha)



head(combinedData)

print(colnames(combinedData))

#===============================================================================
# End of script
#===============================================================================







