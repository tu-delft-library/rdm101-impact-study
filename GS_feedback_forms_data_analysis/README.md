# Graduate School Feedback Analysis

## Overview

This tool provides a way to analyze and visualize quantitative data from the Graduate School feedback forms stored in folders containing Excel or CSV files. Users can select one question from each dataset grouped by year and generate combined histograms by year. The tool dynamically adjusts plot sizes for better readability and provides options to save plots.

To use the tool run "00_main_script.R"

## Get Started

To get started with this R project from GitHub, follow these simple steps:

1.  **Download the Project**: Clone the repository to your computer using Git or download it as a ZIP file and extract it to a folder by going to the green "\<\> Code" button.

2.  **Set Up R Project**: Open RStudio and navigate to the downloaded folder. Open the .Rproj file included in the repository to launch the R project. This will automatically set your working directory to the correct location.

3.  **Organize Your Data**: Inside the project folder, place your data files in appropriately named subfolders by year (e.g., 2020). Each subfolder should contain one or more Excel (.xlsx) or CSV (.csv) files with [consistent question structures, so always the same question in the same position!]{.underline}

4.  **Install Required Packages**: Make sure you have the necessary R packages installed:

    ``` r
    c("ggplot2", "readxl", "dplyr", "cowplot"))
    ```

    To get the correct version of the packages run:

    ``` r
    renv::restore()
    ```

    The renv contains information about the packages used as well as the version to ensure all functionalities stay the same. This is, however, not necessary to be able to run the code and could slow the process down. So restoring the environment can be skipped.

5.  **Run the Analysis**: Open the main analysis script ("00_main_script.R") in RStudio. Execute the script and follow the prompts to select year folders, choose questions for analysis, and generate plots.

By following these steps, you'll be able to analyze the data and create visualizations as intended.

## Requirements

-   **R version**: 4.2.2

-   **Required R Packages**:

    -   ggplot2 (version 3.4.4)

    -   readxl (version 1.4.3)

    -   dplyr (version 1.1.4)

    -   patchwork (version 1.3.0)

    -   tidyr (version 1.3.1)

    -   viridis (version 0.6.5)

-   **Year Folders**:

    -   Data must be organized in folders named in the format "YYYY" or "YYYY-YYYY" (e.g., 2020, 2020-2021).

    -   These folders must be in the same directory as the script.

-   **Data Files**:

    -   Each folder must contain one or more .xlsx or .csv files. The tool automatically combines data from all files in a folder for analysis. When doing so, the code assumes that within a year the questions and file structure remains the same.

-   **Plots Folder**:

    -   A "plot/" directory will be automatically created in the working directory to store saved plots.

## Contact Information

For questions, issues, or contributions, please feel free to reach out to TU Delft Library -- Research Data and Software Training Team [rdmtraining-lib\@tudelft.nl](mailto:rdmtraining-lib@tudelft.nl).
