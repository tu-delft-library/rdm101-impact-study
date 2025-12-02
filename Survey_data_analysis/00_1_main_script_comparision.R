# Nikki Grens
# Date: 09-03-2025
# Survey Data Analysis - Main Script Comparision Pre and Post Survey Analysis

### Load Libraries
library(readxl)
library(dplyr)
library(ggplot2)
library(stringr)
library(tidyr)
library(stringdist)
library(tidyverse)
library(tm)
library(wordcloud2)
library(writexl)
library(cluster)
library(patchwork)
library(viridis)


### Load External Functions
source("01_match_data.R")
source("02_demographic_analysis.R")
source("03_comparison_pre_post_analysis.R")
source("04_qualitative_category_analysis.R")
source("05_comparison_online_inperson_analysis.R")
source("06_qualitative_open_analysis.R")
source("07_extra_analysis.R")


### Read Data
# Files and folders
folder_path_online <- "Nov_2024_online"
post_training_file_online <- file.path(folder_path_online, "Post_training_RDM_101_November_2024.xlsx")
pre_training_file_online <- file.path(folder_path_online, "Pre_training_RDM_101_November_2024.xlsx")

folder_path_person <- "Sept_2024_in_person"
post_training_file_person <- file.path(folder_path_person, "Post_training_RDM_101_September_2024.xlsx")
pre_training_file_person <- file.path(folder_path_person, "Pre_training_RDM_101_September_2024.xlsx")

folder_path_person_feb <- "Feb_2025_in_person"
post_training_file_person_feb <- file.path(folder_path_person_feb, "Post_training_RDM_101_February_2025.xlsx")
pre_training_file_person_feb <- file.path(folder_path_person_feb, "Pre_training_RDM_101_February_2025.xlsx")

# Read datasets for online run - November
post_training_online <- read_excel(post_training_file_online, sheet = 1, col_names = TRUE) %>% slice(-1)
pre_training_online <- read_excel(pre_training_file_online, sheet = 1, col_names = TRUE) %>% slice(-1)

# Read datasets for in-person run - September
post_training_person <- read_excel(post_training_file_person, sheet = 1, col_names = TRUE) %>% slice(-1)
pre_training_person <- read_excel(pre_training_file_person, sheet = 1, col_names = TRUE) %>% slice(-1)

# Read datasets for in-person run - February
post_training_person_feb <- read_excel(post_training_file_person_feb, sheet = 1, col_names = TRUE) %>% slice(-1)
pre_training_person_feb <- read_excel(pre_training_file_person_feb, sheet = 1, col_names = TRUE) %>% slice(-1)

# Process the online datasets
cat("Processing Online Data...\n")
online_results <- process_matching(pre_training_online, post_training_online, "Q1")

# Process the in-person datasets
cat("\nProcessing In-Person Data...\n")
person_results <- process_matching(pre_training_person, post_training_person, "Q1")

# Process the in-person datasets February
cat("\nProcessing In-Person Data February...\n")
person_results_feb <- process_matching(pre_training_person_feb, post_training_person_feb, "Q1")

# Extract the matched datasets
matched_pre_training_online <- online_results$matched_pre_training
matched_pre_training_person_sept <- person_results$matched_pre_training
matched_pre_training_person_feb <- person_results_feb$matched_pre_training
matched_post_training_online <- online_results$matched_post_training
matched_post_training_person_sept <- person_results$matched_post_training
matched_post_training_person_feb <- person_results_feb$matched_post_training

# Combine all in person data
matched_pre_training_person <- bind_rows(
  matched_pre_training_person_sept,
  matched_pre_training_person_feb
)
matched_post_training_person <- bind_rows(
  matched_post_training_person_sept,
  matched_post_training_person_feb
)

# Combine all pre-training responses
combined_pre_training <- bind_rows(
  matched_pre_training_online %>% mutate(Mode = "Online"),
  matched_pre_training_person %>% mutate(Mode = "In-Person")
)

# Combine all post-training responses
combined_post_training <- bind_rows(
  matched_post_training_online %>% mutate(Mode = "Online"),
  matched_post_training_person %>% mutate(Mode = "In-Person")
)

matched_post_training_person <- matched_post_training_person[!matched_post_training_person$Q1 %in% c("B1ko", "R3le"), ]
matched_post_training_online <- matched_post_training_online[!matched_post_training_online$Q1 %in% c("R2ST", "H2ro"), ]
combined_post_training <- combined_post_training[!combined_post_training$Q1 %in% c("B1ko", "R2ST", "H2ro", "R3le"), ]
combined_pre_training <- combined_pre_training[!combined_pre_training$Q1 %in% c("B1ko", "R2st", "H2ro"),]
matched_pre_training_online <- matched_pre_training_online[!matched_pre_training_online$Q1 %in% c("R2st", "H2ro"),]
matched_pre_training_person <- matched_pre_training_person[!matched_pre_training_person$Q1 %in% c("B1ko"),]


### Comparison Between Pre and Post Survey Analysis
# Questions to Compare
pre_questions <- c("Q4", "Q5", "Q9", "Q12")
post_questions <- c("Q2", "Q3", "Q7", "Q10")

# Process Numeric Responses for Combined Data
pre_training_combined_comparison <- extract_numeric_responses(combined_pre_training, pre_questions)
post_training_combined_comparison <- extract_numeric_responses(combined_post_training, post_questions)

# Calculate Statistics
stats_combined <- calculate_stats(
  pre_training_combined_comparison, post_training_combined_comparison, pre_questions, post_questions
)

# Remove rows with NA values
stats_combined <- stats_combined %>% filter(!is.na(Mean), !is.na(SD))

# Plot comparison questions
plot_survey_comparison(stats_combined, "Pre- vs. Post-Survey Comparison: Combined", TRUE)