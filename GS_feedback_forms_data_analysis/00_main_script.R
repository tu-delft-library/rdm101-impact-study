# In order to use the Data Analyser Tool run this R Script

# To make sure the same version of the packages is used, renv::restore()
# needs to be run on the console

# If libraries are not installed yet, you can do so by running the commented lines below
# If renv::restore() was used then this part does not need to happen!!
# install.packages("readxl")
# install.packages("ggplot2")
# install.packages("patchwork")
# install.packages("dplyr")


# Load required libraries
library(readxl)
library(ggplot2)
library(patchwork)
library(dplyr)
library(tidyr)
library(viridis)

# Load required function from the R script 01_data_analysis.R
source("01_data_analysis.R")
source("04_qualitative_analysis.R")

# Run the analysis in one step
run_analysis()

qualitative_data_file <- "Qualitative_data_categories_cal_year.xlsx"
qualitative_data <- read_excel(qualitative_data_file, col_names = TRUE) %>% slice(-1)

# Plot Categorized Responses
plot_categorised_open_responses(qualitative_data, "What 2-3 things did you like most about this course and find most useful \nor valuable for learning?")