#===============================================================================
# Script Name: reportAndVisualisation.R
# Project : Reporting Strategy
# Author : Melvin Njuaka
# Description : This script provides the reports and visualisation for both 
#              analyst and plant breeder

#===============================================================================

# Dependencies and libraries----------------------------------------------------
# make sure you install.packages("R6") before running the script
library(R6)
library(ggplot2)
library(dplyr)
library(reshape2)

# import the raw data

source("rawToCleanData.R", encoding = "UTF-8")


# 


# Define the ReportGenerator class

ReportGenerator <- R6Class("ReportGenerator",
  public = list(
    data = NULL,
    
    initialize = function(data) {
      self$data <- data
    },
    
    user_report = function(user_type = "analyst", include_plots = TRUE, top_n_countries = 5) {
      
      if (user_type == "analyst") {
        
        return(self$generate_analyst_report(include_plots))
        
      } else if (user_type == "breeder") {
          
        return(self$generate_breeder_report(include_plots))
          
      } else {
            
        stop("Invalid user type. Please specify 'analyst' or 'breeder'.")
            
      }
    },
                                     
    generate_analyst_report = function(include_plots) {
        
      summary_stats <- self$data %>%
        summarise(across(where(is.numeric), 
                         list(mean= ~mean(.),
                              median= ~median(.), 
                              sd= ~sd(.))))
        
      if (include_plots) {
        
        avg_yield_per_crop <- self$data %>%
          
          group_by(crop_type) %>%
          
          summarise(avg_yield = mean(yield_value_hg_per_ha))
          
          
        avg_yield_per_crop_plot <- ggplot(avg_yield_per_crop, aes(x = reorder(crop_type, avg_yield), y = avg_yield)) +
          geom_bar(stat = "identity") +
          labs(title = "Average Yield per Crop", x = "Crop", y = "Average Yield (hg/ha)")
          
          
        correlation_matrix <- self$data %>%
          group_by(country) %>%
          summarise(across(where(is.numeric), mean, na.rm = TRUE)) %>%
          select(-country, -year) %>%
          cor()
          
        melted_correlation_matrix <- melt(correlation_matrix)
          
        correlation_matrix_plot <- ggplot(melted_correlation_matrix, aes(Var1, Var2, fill = value)) +
          geom_tile() +
          geom_text(aes(label = round(value, 2)), color = "white", size = 3) +  # Add correlation values
          scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1, 1), space = "Lab", name="Correlation") +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1))
          
        return(list(
          summary_stats = summary_stats,
          correlation_matrix_plot = correlation_matrix_plot
            
       ))
        
      } else {
          
        return(list(summary_stats = summary_stats))
      }
        
    },
      
    generate_breeder_report = function(include_plots) {
      
      avg_yield_per_crop <- self$data %>%
        
        group_by(crop_type) %>%
        
        summarise(avg_yield = mean(yield_value_hg_per_ha))
      
      top_countries <- self$data %>%
        group_by(country) %>%
        summarise(avg_yield = mean(yield_value_hg_per_ha, na.rm = TRUE)) %>%
        arrange(desc(avg_yield))
      
      if (include_plots) {
        
        avg_yield_per_crop_plot <- ggplot(avg_yield_per_crop, aes(x = reorder(crop_type, avg_yield), y = avg_yield)) +
          geom_bar(stat = "identity") +
          labs(title = "Average Yield per Crop", x = "Crop", y = "Average Yield (hg/ha)")
        
        
        top_countries_plot <- ggplot(top_countries, aes(x = reorder(country, avg_yield), y = avg_yield)) +
          geom_bar(stat = "identity") +
          labs(title = "Top Performing Countries", x = "Country", y = "Average Yield (tons/ha)")
        
        
        return(list(
          avg_yield_per_crop = avg_yield_per_crop,    # Include the data in the return list
          top_countries = top_countries,              # Include top countries data
          avg_yield_per_crop_plot = avg_yield_per_crop_plot, 
          top_countries_plot = top_countries_plot

       ))
          
      } else {
        
        return(list(avg_yield_per_crop = avg_yield_per_crop,
                    top_countries = top_countries
        ))
          
      }
        
    }
  )
)



reports <- ReportGenerator$new(combinedData)

# Generate Analyst Report with Plots
 
analyst_report <- reports$user_report(user_type = "analyst", include_plots = TRUE)
write.csv(analyst_report$summary_stats, "analyst_summary.csv", row.names = FALSE)

ggsave("avg_yield_per_crop_plot.png", plot = analyst_report$avg_yield_per_crop_plot)
ggsave("correlation_plot.png", plot = analyst_report$correlation_matrix_plot)

# Generate Breeder Report without Plots

breeder_report <- reports$user_report(user_type = "breeder", include_plots = TRUE, top_n_countries=3)
write.csv(breeder_report$top_countries, "top_countries.csv", row.names = FALSE)
ggsave("top_countries_plot.png", plot = breeder_report$top_countries_plot)
ggsave("avg_yield_per_crop_plot.png", plot = breeder_report$avg_yield_per_crop_plot)
