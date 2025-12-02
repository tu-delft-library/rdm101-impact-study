# Nikki Grens
# Date: 02-03-2025
# Survey Data Analysis - Main Script Pre Survey Analysis


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
post_training_person_sept <- read_excel(post_training_file_person, sheet = 1, col_names = TRUE) %>% slice(-1)
pre_training_person_sept <- read_excel(pre_training_file_person, sheet = 1, col_names = TRUE) %>% slice(-1)

# Read datasets for in-person run - February
post_training_person_feb <- read_excel(post_training_file_person_feb, sheet = 1, col_names = TRUE) %>% slice(-1)
pre_training_person_feb <- read_excel(pre_training_file_person_feb, sheet = 1, col_names = TRUE) %>% slice(-1)

# Combine all in person data
pre_training_person <- bind_rows(
  pre_training_person_sept,
  pre_training_person_feb
)

post_training_person <- bind_rows(
  post_training_person_sept,
  post_training_person_feb
)

# Process the online datasets
cat("Processing Online Data...\n")
online_results <- process_matching(pre_training_online, post_training_online, "Q1")

# Process the in-person datasets
cat("\nProcessing In-Person Data...\n")
person_results <- process_matching(pre_training_person_sept, post_training_person_sept, "Q1")

# Process the in-person datasets February
cat("\nProcessing In-Person Data February...\n")
person_results_feb <- process_matching(pre_training_person_feb, post_training_person_feb, "Q1")

# Extract the matched datasets
matched_pre_training_online <- online_results$matched_pre_training
matched_pre_training_person_sept <- person_results$matched_pre_training
matched_pre_training_person_feb <- person_results_feb$matched_pre_training

# Combine all in person data
matched_pre_training_person <- bind_rows(
  matched_pre_training_person_sept,
  matched_pre_training_person_feb
)

# Combine all pre-training responses
combined_pre_training <- bind_rows(
  matched_pre_training_online %>% mutate(Mode = "Online"),
  matched_pre_training_person %>% mutate(Mode = "In-Person")
)

# These rows were removed as the responses stopped halway through the questionnaire
combined_pre_training <- combined_pre_training[!combined_pre_training$Q1 %in% c("B1ko", "R2st", "H2ro"),]

### Demographic Analysis
# Analysis of amount of answers
online_stats <- calculate_response_stats(pre_training_online, post_training_online, matched_pre_training_online, "Online")
in_person_stats <- calculate_response_stats(pre_training_person, post_training_person, matched_pre_training_person, "In-Person")
final_results <- bind_rows(online_stats, in_person_stats)
print(final_results)

matched_pre_training_online <- matched_pre_training_online[!matched_pre_training_online$Q1 %in% c("R2st", "H2ro"),]
matched_pre_training_person <- matched_pre_training_person[!matched_pre_training_person$Q1 %in% c("B1ko"),]


# Faculty distribution analysis (Q2)
faculty_distribution_matched_combined <- calculate_distribution(combined_pre_training, "Q2", "Faculty")

# Plot faculty distributions
plot_distribution(faculty_distribution_matched_combined, "Faculty", "Faculty Distribution: Combined Data")

# Year distribution analysis (Q3)
year_distribution_matched_combined <- calculate_distribution(combined_pre_training, "Q3", "Year")

# Plot year distributions
plot_distribution(year_distribution_matched_combined, "Year", "Year Distribution: Combined Data")


### Qualitative Analysis with Categories
# Column containing statistics of yes and no answers as well as qualitative responses and the possible categories
occurrence_column <- "Q6"
yes_no_results_combined <- calculate_occurrence_percentage(combined_pre_training, occurrence_column)
print(yes_no_results_combined)

pre_column_qualitative <- "Q6_1"
category_keywords <- list(
  "Data Stewards" = c("steward", "stewards", "stuart"),
  "Digital Competence Centre (DCC)" = c("competence", "digital"),
  "Library Services" = c("library", "rdm", "training", "courses", "Institutional"),
  "IT Services" = c("IT"),
  "Data Management Plan" = c("DMP", "development plan"),
  "Storage Locations" = c("Git", "drive", "repository", "4TU", "storage"),
  "HPC Services" = c("HPC"),
  "Useful Links and Resources" = c()
)

# Create data frame with answers and the corresponding categories
qualitative_df_combined <- categorise_clean_responses(combined_pre_training, pre_column_qualitative, category_keywords)

# Save the dataframe as an Excel file
write_xlsx(qualitative_df_combined, "Results/q6_pre_support.xlsx")
# qualitative_df_combined <- read_excel("Results/q6_pre_support.xlsx")

# Plot of the categorised responses
category_names <- c(
  "Other",
  "4TU.ResearchData",
  "Useful Links and Resources",
  "Storage Locations",
  "Library Services",
  "IT Services",
  "HPC Services",
  "Digital Competence Centre (DCC)",
  "Data Stewards",
  "Data Management Plan"
  )

plot_categorised_responses(qualitative_df_combined, "Are you familiar with the dedicated support available at the University/your faculty for research \ndata/software-related questions?", category_names)


# Column containing the multiple choice questions
# Options "Q7", "Q8_1"
multi_column <- "Q8_1"

# Create data frame with answers and the corresponding multiple choice
multiple_choice_df_combined <- categorise_multiple_choice_questions(combined_pre_training, multi_column)

# For Q7 use Hard Drive and for Q8 use External Hard Drive
category_names <- c(
  "Other",
  "SURFdrive",
  "Project Data (U:) drive",
  "Project Data (M:) drive",
  "OneDrive",
  "MS Teams",
  "Mailbox",
  "Laptop/ Desktop Computer",
  "External Hard Drive",
  "GitHub/GitLab",
  "Commercial Cloud Services (Google Drive, etc.)"
)

# For Q7 run this part only
multiple_choice_df_combined <- multiple_choice_df_combined %>%
  filter(Assigned_Category != "Commercial Cloud") %>%
  filter(Assigned_Category != "Computer") %>%
  mutate(Assigned_Category = if_else(Assigned_Category == "Services (Google Drive, etc.)", "Commercial Cloud Services (Google Drive, etc.)", Assigned_Category)) %>%
  mutate(Assigned_Category = if_else(Assigned_Category == "Laptop/ Desktop", "Laptop/ Desktop Computer", Assigned_Category))

# For Q8 run this part only
multiple_choice_df_combined <- multiple_choice_df_combined %>%
  mutate(Assigned_Category = if_else(Assigned_Category == "“Other” text box", "Other", Assigned_Category))

# "Indicate the backup location for the data/code (scripts) for your research."
plot_categorised_responses(multiple_choice_df_combined, "Where do you store data/code (scripts) of your research project?", category_names)


# Column containing the wordcloud question
wordcloud_column <- "Q10" 

# Create data frame with answers and the corresponding wordcloud terms
wordcloud_df_combined <- categorise_wordcloud_question(combined_pre_training, wordcloud_column)

# Plot of the multiple choice responses
plot_wordcloud(wordcloud_df_combined)


# Occurrence answers if respondents already have a DMP
occurrence_column <- "Q11"
occurrence_results_combined <- calculate_occurrence_percentage(combined_pre_training, occurrence_column)

print(occurrence_results_combined)


### Qualitative Analysis of Open Questions
# Analysis for questions 13.1 and 13.2
# Options: "Q13_1", "Q13_2"
occurrence_column <- "Q13"
yes_no_results_combined <- calculate_occurrence_percentage(combined_pre_training, occurrence_column)
print(yes_no_results_combined)

pre_column_qualitative <- "Q13_2"

# For 13_1
category_keywords <- list(
  "4TU.ResearchData" = c("4TU", "research"),
  "Don't know/Have not decided yet" = c("decide", "know"),
  "Github/Gitlab" = c("github", "gitlab"),
  "Project Data (:U) Drive" = c("U:"),
  "Specific platform" = c(),
  "Remove" = c()
)

# For 13_2
category_keywords <- list("commercial/confidential/sensitive/proprietary data" = c("commercial", "confidential", "sensitive", "proprietary"),
                "personal data" = c("personal"),
                "no reason"= c(),
                "specific experimental setup" = c("specific"),
                "Don't know/Have not decided yet" = c("thought", "know", "discussed"),
                "remove" = c())

# Create data frame with answers and the corresponding categories
qualitative_df_combined <- categorise_clean_responses(combined_pre_training, pre_column_qualitative, category_keywords)

# Save the dataframe as an Excel file as analysis has to be done partially manually 
# due to the knowledge required to interpret the data
write_xlsx(qualitative_df_combined, "Results/q13_2.xlsx")

# Q13_1
category_names <- c(
  "Other",
  "4TU.ResearchData",
  "Zenodo",
  "TU Delft Repository",
  "Project Data (U:) Drive",
  "GitHub/GitLab",
  "Don't Know/Haven't Decided Yet",
  "Data Journal",
  "Discipline-Specific Platform"
)

# Q13_2
category_names <- c(
  "Other",
  "Personal Data",
  "Perceived Lack of Data/Code Reusability",
  "Lack of Motivation",
  "Don't Know/Haven't Decided Yet",
  "Commercial/Confidential/Sensitive/Proprietary Data"
)

# Results are saved to be able to analyse them. To save time, it is possible to 
# open them and immediately make the plot

# qualitative_df_combined <- read_excel("Results/q13_pre_publish_yes.xlsx")
# qualitative_df_combined <- read_excel("Results/q13_pre_publish_no.xlsx")

# Q13_1
plot_categorised_responses(qualitative_df_combined, "Please indicate the name of the repository where you plan to publish the research data/code (scripts).", category_names)

#Q13_2
plot_categorised_responses(qualitative_df_combined, "Please indicate at least one reason why you are not planning to publish the research data/code?", category_names)