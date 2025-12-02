# Documentation for RDM101 Survey Data Analysis

## Overview

This project analyses pre- and post-survey responses to the RDM_101 course, examining:

-   Student engagement by session format (online/in-person)

-   Evolution in knowledge and attitudes (quantitative ratings)

-   Patterns in open-ended responses (qualitative analysis)

-   Cross-sectional and longitudinal comparisons

------------------------------------------------------------------------

## Script Overview

| Script                                     | Purpose                                           |
|--------------------------------------------|---------------------------------------------------|
| `00_0_main_script_pre.R`                   | Loads and analyses pre-training surveys           |
| `00_1_main_script_comparision.R`           | Compares pre- and post-surveys                    |
| `00_2_main_script_post.R`                  | Loads and analyses post-training surveys          |
| `01_match_data.R`                          | Core logic to match surveys based on unique IDs   |
| `02_demographic_analysis.R`                | Demographic statistics (faculty, year, etc.)      |
| `03_comparison_pre_post_analysis.R`        | Numeric response extraction and comparison        |
| `04_qualitative_category_analysis.R`       | Categorical + multiple-choice question processing |
| `05_comparison_online_inperson_analysis.R` | Evaluates online vs in-person training            |
| `06_qualitative_open_analysis.R`           | Free text response clustering and manual tagging  |
| `07_extra_analysis.R`                      | Extra plotting utilities and response rates       |

------------------------------------------------------------------------

## Input Data Format

-   Excel .xlsx files for pre and post survey responses with the first row after the header as metadata containing the asked questions, so slice(-1) is used after reading.
-   File examples:
    -   `Nov_2024_online/Pre_training_RDM_101_November_2024.xlsx`
    -   `Sept_2024_in_person/Post_training_RDM_101_September_2024.xlsx`

------------------------------------------------------------------------

## R Scripts

### 1. `01_match_data.R`

#### Description

Matches pre- and post-survey datasets by a common identifier column (usually `Q1`). Uses both exact and partial (Levenshtein) string distance for partial matching.

#### Parameters

-   `process_matching(pre_training, post_training, matching_column)`: Performs matching based on pre-survey data, post-survey data and column name to match responses on (default: `"Q1"`).

### 2. `02_demographics_analysis.R`

#### Description

Performs demographic breakdowns on categorical variables such as Faculty and Year. Produces bar plots and percentage tables.

#### Parameters

-   `calculate_distribution(data, column_name, label)`: Counts and computes percentages for a specific column.
-   `plot_distribution(data, x_label, title)`: Visualizes a categorical distribution.
-   `calculate_response_stats(pre_data, post_data, matched_data, mode_name)`: Provides an overview of matched vs unmatched responses.

### 3. `03_comparison_pre_post_analysis.R`

#### Description

Processes and compares numeric rating questions from pre- and post-surveys. Extracts numeric scores, computes mean/SD, and plots grouped line graphs.

#### Parameters

-   `extract_numeric_responses(data, questions)`: Parses numeric part of responses.
-   `calculate_stats(pre_data, post_data, pre_questions, post_questions)`: Returns a tidy dataframe of mean and SD per question.
-   `plot_survey_comparison(data, title, error = FALSE)`: Plots rating evolution from pre to post.

### 4. `04_qualitative_category_analysis.R`

#### Description

Analyzes responses to qualitative or multiple-answer questions. Applies keyword-based categorization and optional manual override. Plots category distributions. Creates wordclouds plots

#### Parameters

-   `categorise_clean_responses(data, column_name, category_keywords)`: Matches free-text to keyword-based categories.
-   `categorise_multiple_choice_questions(data, column_name)`: Splits semicolon-separated answers into individual categories.
-   `plot_categorised_responses(data, title)`: Plots counts per category.
-   `plot_categorised_responses_comparision(data1, data2, title1, title2)`: Variant to compare two datasets visually.
-   `categorise_wordcloud_question(data, column_name)`: Gets the words and frequency for the wordcloud.
-   `plot_wordcloud(data)`: Plots the wordcloud based on the names and frequency.

### 5. `05_comparison_online_inperson_analysis.R`

#### Description

Compares perceptions of course components between online and in-person respondents. Plots grouped or stacked bar charts per rating (1--5 scale).

#### Parameters

-   `comparison_questions_frequency(data, training_name)`: Counts rating frequencies across questions.
-   `calculate_percentage(data)`: Normalizes count data to percentages.
-   `plot_comparison_online_inperson_grouped(data)`: Shows grouped bar plots per comparision question.

### 6. `06_qualitative_open_analysis.R`

#### Description

Processes open-ended responses: cleaning and manual categorisation. Enables categorization via Command-Line Interface input or from pre-saved Excel files.

#### Parameters

-   `clean_open_responses(data, column_name)`: Tokenizes and sanitises text answers.
-   `categorise_open_responses(data, categories)`: Manual assignment of categories.
-   `continuation_categorise_open_responses(file_path, categories)`: Resume from Excel file and revise/confirm categorisation.
-   `plot_categorised_open_responses(data, title)`: Plots categorised open response data.

------------------------------------------------------------------------

### 7. `07_extra_analysis.R`

#### Description

Utility functions for occurrence-based questions and extra plots. Includes bar plotting with facet support and response rate calculations.

#### Parameters

-   `calculate_occurrence_percentage(data, column_name)`: Tabulates counts and percentages for binary/multiple-choice answers.
-   `map_and_save_categories(file_path, category_mapping, category_column)`: Change the category names on a specific excel file containing the qualitative analysis for one question.
