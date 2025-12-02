# Nikki Grens
# Date: 09-03-2025
# Survey Data Analysis - Main Script Post Survey Analysis

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
matched_post_training_online <- online_results$matched_post_training
matched_post_training_person_sept <- person_results$matched_post_training
matched_post_training_person_feb <- person_results_feb$matched_post_training

# Combine all in person data
matched_post_training_person <- bind_rows(
  matched_post_training_person_sept,
  matched_post_training_person_feb
)

# Combine all post-training responses
combined_post_training <- bind_rows(
  matched_post_training_online %>% mutate(Mode = "Online"),
  matched_post_training_person %>% mutate(Mode = "In-Person")
)

# These rows were removed as the responses stopped halway through the questionnaire
matched_post_training_person <- matched_post_training_person[!matched_post_training_person$Q1 %in% c("B1ko", "R3le"), ]
matched_post_training_online <- matched_post_training_online[!matched_post_training_online$Q1 %in% c("R2ST", "H2ro"), ]
combined_post_training <- combined_post_training[!combined_post_training$Q1 %in% c("B1ko", "R2ST", "H2ro", "R3le"), ]


### Qualitative Analysis with Categories
# Column containing qualitative responses and the possible categories as well as statistics of yes and no answers
occurrence_column <- "Q4"
yes_no_results_combined <- calculate_occurrence_percentage(combined_post_training, occurrence_column)

print(yes_no_results_combined)

post_column_qualitative <- "Q4_1"
category_keywords <- list(
  "Data Stewards" = c("steward", "stewards", "stuart"),
  "Digital Competence Centre (DCC)" = c("competence", "digital"),
  "Library Services" = c("library", "rdm", "training", "courses", "Institutional"),
  "4TU.ResearchData" = c("4TU"),
  "IT Services" = c("IT"),
  "Data Management Plan" = c("DMP", "development plan"),
  "Storage Locations" = c("Git", "drive", "repository", "4TU", "storage"),
  "HPC Services" = c("HPC"),
  "Useful Links and Resources" = c()
)

# Create data frame with answers and the corresponding categories
qualitative_df_combined <- categorise_clean_responses(combined_post_training, post_column_qualitative, category_keywords)

# Save the dataframe as an Excel file
# write_xlsx(qualitative_df_combined, "Results/q4_post_support.xlsx")
qualitative_df_combined <- read_excel("Results/q4_post_support.xlsx")

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


# Column containing yes, no answers
# Options "Q5", "Q6"
occurrence_column <- "Q6"
yes_no_results_combined <- calculate_occurrence_percentage(combined_post_training, occurrence_column)
print(yes_no_results_combined)

# Create data frame with answers and the corresponding multiple choice
# Column containing the multiple choice questions
# Options "Q5_1", "Q6_1"
multi_column <- "Q6_1"

multiple_choice_df_combined <- categorise_multiple_choice_questions(combined_post_training, multi_column)

# Q5 and Q6
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

plot_categorised_responses(multiple_choice_df_combined, "Where are you storing the data/code (scripts) for your research?", category_names)
plot_categorised_responses(multiple_choice_df_combined, "Indicate the backup location for the data/code (scripts) for your research.", category_names)

# Column containing the wordcloud question
wordcloud_column <- "Q8" 

# Create data frame with answers and the corresponding wordcloud terms
wordcloud_df_combined <- categorise_wordcloud_question(combined_post_training, wordcloud_column)

# Plot of the multiple choice responses
plot_wordcloud(wordcloud_df_combined)


### Comparison Between In Person and Online Training Analysis
# Obtaining the frequency of each answer for the different questions
frequency_person <- comparison_questions_frequency(matched_post_training_person, "In-Person")
frequency_online <- comparison_questions_frequency(matched_post_training_online, "Online")

# Percentage of occurrence of each answers to be able to compare data sets with different number of responses
person_percentage <- calculate_percentage(frequency_person)
online_percentage <- calculate_percentage(frequency_online)
combined_percentage <- bind_rows(online_percentage, person_percentage)

# Plots of the comparison between online and in person
plot_comparison_online_inperson_grouped(combined_percentage)

combined_percentage_expanded <- combined_percentage %>%
  uncount(Count)

summary_stats <- combined_percentage_expanded %>%
  group_by(Question, Format) %>%
  summarise(
    Mean = mean(Rating),
    SD = sd(Rating),
    .groups = "drop"
  )

print(summary_stats)

# Plot expectations 
multi_column <- "Q14"

category_names <- c(
  "4 - Exceeded expectations",
  "3 - Met expectations",
  "2 - Somewhat met expectations"
)

# Create data frame with answers and the corresponding multiple choice
multiple_choice_df_person <- categorise_multiple_choice_questions(matched_post_training_person, multi_column)
multiple_choice_df_online <- categorise_multiple_choice_questions(matched_post_training_online, multi_column)
multiple_choice_df_combined <- categorise_multiple_choice_questions(combined_post_training, multi_column)

# Plot of the multiple choice responses
plot_categorised_responses(multiple_choice_df_combined, "Did the course meet your expectations?", category_names)

category_names <- c(
  "4 - Exceeded expectations",
  "3 - Met expectations",
  "2 - Somewhat met expectations"
)

plot_categorised_responses_comparision(multiple_choice_df_online, multiple_choice_df_person,
                                         "Did the course meet your expectations?  - Online", "Did the course meet your expectations?  - In Person", category_names, category_names)

### Qualitative Analysis of Open Questions

post_column_qualitative <- "Q12_1"
# For 12_1
category_keywords <- list(
  "4TU.ResearchData" = c("4TU", "research"),
  "Don't know/Have not decided yet" = c("decide", "know"),
  "Github/Gitlab" = c("github", "gitlab"),
  "Project Data (:U) Drive" = c("U:"),
  "Specific platform" = c(),
  "Remove" = c()
)

# Create data frame with answers and the corresponding categories
qualitative_df_combined <- categorise_clean_responses(combined_post_training, post_column_qualitative, category_keywords)

# Save the dataframe as an Excel file
write_xlsx(qualitative_df_combined, "Results/q12_post_publish_yes.xlsx")

# Q12_1
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


qualitative_df_combined <- read_excel("Results/q12_post_publish_yes.xlsx")

# Q12_1
plot_categorised_responses(qualitative_df_combined, "Please indicate the name of the repository where you plan to publish the research data/code (scripts).", category_names)



# Define the column containing open responses
# Options "Q9_1", "Q9_2", "Q11_1", "Q12_1", "Q12_2", "Q13_1", "Q14_1"
# "Q15_1...46", "Q16_1"
open_column <- "Q13_1"

# Clean Open Responses
open_df_combined <- clean_open_responses(combined_post_training, open_column)

# Categorise open responses
# Here are certain options for the different open questions
categories <- c()

# Question 9_1
categories <-c("Good documentation (Readme, data disctionaries)",
               "Understandable Metadata/implementing metadata standarts",
               "Clear access instructions",
               "Sowcasing data/code reuse",
               "Ensure interoperability of data/software",
               "Descriptive directory/file naming conventions",
               "Structuring /organizing data/folder structure",
               "Data/metadata publication (public repositories)",
               "Open file formats",
               "Perisistent identifiers for data/code",
               "Licensing",
               "Making a DMP",
               "Apply Version Control",
               "Backup (U: drive)",
               "Using open-source research repo",
               "Support in writing/finalising DMP",
               "Documentation",
               "Accesibility",
               "Data Management/organisation/handling the data (to navigate, to keep up to day)",
               "Storage",
               "Understanding the data",
               "Publishing",
               "Backup",
               "Implementation of FAIR",
               "Reusability",
               "Understanding the sensitivity of data and the ways to deal with it")

# Question 11_1
categories <- c("DFM, assignment, 6 themes, trainer's feedback",
                "Research Objects-listing, determing types",
                "Data storage",
                "Data sharing",
                "File formats (open source software)",
                "Metadata standarts/tools",
                "DMP online",
                "Data documentation tools/templates",
                "FAIR principles/tool to asses",
                "Structure/organise the data",
                "Backup (3-2-1 rule)",
                "Folder strcuture/file organisation",
                "File naming conventions",
                "TUD data management assistance/resources/support",
                "Separate raw data",
                "BS content/course material",
                "GitLab/Version control",
                "RDM plan",
                "Data publication",
                "Limitations witht personal data",
                "Aspects to consider/data to be included in DMP")


open_df_combined <- categorise_open_responses(open_df_combined, categories)

# Save the dataframe as an Excel file
write_xlsx(open_df_combined, "Results/q11_post_dmp.xlsx")

# Continue categorisation from results stored in an excel file from initial categorisation
file <- "Results/q11_post_dmp.xlsx"
open_df_combined <- continuation_categorise_open_responses(file, categories)

# Q9_1
category_mapping <- c(
  "Good documentation (Readme, data disctionaries)" = "Data/Code Documentation (README, Data Dictionaries, Electronic Lab Notebooks, etc.)",
  "Understandable Metadata/implementing metadata standarts" = "Use (Standard) Metadata",
  "Descriptive directory/file naming conventions" = "Folder/Data Naming Conventions",
  "Open file formats" = "Open/Non-Proprietary File Formats",
  "Structuring /organizing data/folder structure" = "Folder Structure/Data and Code Organization",
  "Clear access instructions" = "Accessibility Measures",
  "Using open-source research repo" = "Data/Code Sharing/Publication",
  "Data/metadata publication (public repositories)" = "Data/Code Sharing/Publication",
  "Backup (U: drive)" = "Storage/Backup Practices",
  "Licensing" = "Use of Licences",
  "Other" = "Other",
  "Ensure interoperability of data/software" = "Data/Software Interoperability",
  "Apply Version Control" = "Apply Version Control",
  "Perisistent identifiers for data/code" = "PIDs for Data/Code",
  "Making a DMP" = "Write a DMP"
)

# Q11
category_mapping <- c(
  "Other" = "Other",
  "Limitations with personal data" = "Confidential/Personal Data Management",
  "Data sharing" = "Data/Code Sharing/Publication",
  "Data publication" = "Data/Code Sharing/Publication",
  "Licencing" = "Use of Licences",
  "File formats (open source software)" = "Open/Non-Proprietary File Formats",
  "BS content/course material" = "Useful Course Materials",
  "TUD data management assistance/resources/support;" = "TU Delft RDM Support Services",
  "Folder strcuture/file organisation" = "Folder Structure/Data and Code Organization",
  "Structure/organise the data" = "Folder Structure/Data and Code Organization",
  "File naming conventions" = "File Naming Conventions",
  "DMP online" = "Use of DMPonline Tool",
  "Backup (3-2-1 rule)" = "Storage/Backup Practices",
  "Data storage" = "Storage/Backup Practices",
  "Research Objects-listing, determing types" = "Identifying Research Data/Objects",
  "Aspects to consider/data to be included in DMP" = "Understanding/Creating a DMP",
  "Data documentation tools/templates" = "Data/Code Documentation (README, Data Dictionaries, Electronic Lab Notebooks, etc.)",
  "FAIR principles/tool to asses" = "FAIR Principles and Implementation",
  "DFM-a" = "Feedback/Guidance on DFM Assignment",
  "DFM-b" = "Creating a DFM",
  "Metadata standarts/tools" = "Metadata Standarts/Tools",
  "NEW" = "Accessibility Measures",
  "Limitations with perosnal data" = "Confidential/Personal Data Management",
  "Limitations witht personal data" = "Confidential/Personal Data Management"
)


#file <- "Results/q9_post_fair_yes.xlsx"
file <- "Results/q11_post_dmp.xlsx"
open_df_combined <- map_and_save_categories(file, category_mapping)

# Q11
open_df_combined <- read_excel("Results/q11_post_dmp.xlsx")
plot_categorised_open_responses(open_df_combined, "Briefly describe which knowledge and skills from the course you found useful \nto develop/improve your DMP.")

# Q9
open_df_combined <- read_excel("Results/q9_post_fair_yes.xlsx")
plot_categorised_open_responses(open_df_combined, "Can you give an example of the measures/actions to make the research \ndata/code (scripts) more FAIR?")

# Options "Q9", "Q11", "Q12", "Q13"
occurrence_column <- "Q19"
yes_no_results_combined <- calculate_occurrence_percentage(combined_post_training, occurrence_column)
print(yes_no_results_combined)
