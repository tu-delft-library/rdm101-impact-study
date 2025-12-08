# RDM101 Survey Data Analysis

## Overview

This tool allows for the analysis and visualisation of both quantitative and qualitative data from the RDM101 training surveys conducted in the first half of the 2024/2025 academic year. For each training pre- and post-training questionnaires were distributed and these can be analysed separately or used to compare scores given to the same question in both surveys. The tool matches participants who responded to both the pre- and post-training surveys, allowing analysis to be performed only on matched responses. The matching is done using an identification code provided by participants in both surveys. The tool also supports the comparison between the two training formats: online and in-person sessions.

To run the tool, use the following scripts: '00_0\_main_script_pre.R', '00_1\_main_script_comparision.R' and '00_2\_main_script_post.R' as these contain the different analyses possibilities.

------------------------------------------------------------------------

## Requirements

These are the versions used that ensure proper use of the code

-   **R version**: 4.2.2

-   **Required R Packages**:

    -   readxl (version 1.4.3)

    -   dplyr (version 1.1.4)

    -   ggplot2 (version 3.4.4)

    -   stringr (version 1.5.1)

    -   tidyr (version 1.3.1)

    -   stringdist (version 0.9.12)

    -   tidyverse (version 2.0.0)

    -   tm (version 0.7.13)

    -   wordcloud2 (version 0.2.1)

    -   writexl (version 1.5.0)

    -   patchwork (version 1.3.0)

    -   viridis (version 0.6.5)

-   **Data Files**:

    -   To ensure meaningful comparison across training sessions, all pre-training questionnaires must follow the same question structure, as well as all post-training questionnaires.

To install the different packages that are still missing use the following command:

``` r
install.packages(c(
  "readxl", "dplyr", "ggplot2", "stringr", "tidyr", "stringdist", "tidyverse",
  "tm", "wordcloud2", "writexl", "cluster", "patchwork", "viridis"
))
```

------------------------------------------------------------------------

## Code Structure

    ├── 00_0_main_script_pre.R              # Pre-survey analysis
    ├── 00_1_main_script_comparision.R      # Pre vs Post survey comparison
    ├── 00_2_main_script_post.R             # Post-survey analysis
    ├── 01_match_data.R                     # Matching pre- and post-survey responses
    ├── 02_demographic_analysis.R           # Demographic statistics and plots
    ├── 03_comparison_pre_post_analysis.R   # Quantitative comparison logic
    ├── 04_qualitative_category_analysis.R  # Analysis for multiple-choice & category-based questions
    ├── 05_comparison_online_inperson_analysis.R  # Online vs in-person comparison
    ├── 06_qualitative_open_analysis.R      # Open-ended response analysis and clustering
    ├── 07_extra_analysis.R                 # Utility functions for rating-based analysis

------------------------------------------------------------------------

## Step-by-Step Execution

1.  **Pre-Survey Analysis**\
    Run: `00_0_main_script_pre.R`
    -   Loads pre-survey responses
    -   Matches students using `Q1`
    -   Performs demographic, quantitative and qualitative category analysis
2.  **Post-Survey Analysis**\
    Run: `00_2_main_script_post.R`
    -   Same as pre, but for post-survey
    -   Includes comparison between online and in-person formats
3.  **Comparison Between Pre and Post**\
    Run: `00_1_main_script_comparision.R`
    -   Compares rating questions like RDM knowledge, FAIR understanding, etc.
    -   Visualizes multiple-choice evolution

------------------------------------------------------------------------

## Key Functionalities

1.  **Matching** File: `01_match_data.R`
    -   Matches rows across pre- and post-surveys via Q1
    -   Supports partial string matching
2.  **Demographics** File: `02_demographic_analysis.R`
    -   Plots for Faculty, Year, and survey participation rates
3.  **Quantitative Comparison** File: `03_comparison_pre_post_analysis.R`
    -   Extracts numeric values from response text
    -   Computes and visualizes average ratings and standard deviation
4.  **Qualitative Categorization** File: `04_qualitative_category_analysis.R`
    -   Keyword matching for questions like Q6_1, Q4_1, etc.
    -   Creates bar charts and comparison plots
5.  **Online vs In-Person** File: `05_comparison_online_inperson_analysis.R`
    -   Rates 8 key training components (Q15_1 to Q15_8)
    -   Plots grouped/stacked bar charts
6.  **Open Question Analysis** File: `06_qualitative_open_analysis.R`
    -   Manual & semi-automatic categorization
    -   Clustering via string similarity - Plots category distribution
7.  **Extra Tools** File: `07_extra_analysis.R`
    -   Functions for yes/no stats, dynamic bar plots, and scales

------------------------------------------------------------------------

## Contact Information

For questions, issues, or contributions, please feel free to reach out to TU Delft Library -- Research Data and Software Training Team [rdmtraining-lib\@tudelft.nl](mailto:rdmtraining-lib@tudelft.nl).
