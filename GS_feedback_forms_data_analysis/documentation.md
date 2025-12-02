# Documentation for Graduate School Feedback Forms Data Analysis Tool

## Overview

This tool facilitates the analysis and visualisation of data collected from GS feedback forms on training provided by the RDS training team. Quantitative and qualitative data of the previous years is stored in the Staff Umbrella Drive in Excel or CSV formats within specified year folders. Using this tool users can select specific questions from each year's dataset to analyse and generate plots containing the histograms per year. The tool dynamically adapts plot sizes (based on the number of plots being combined and saved) for readability. The tool is robust against mixed or invalid data entries and will clean or skip non-numeric data during processing.

## Analysis Requirements

In order to be able to use this tool correctly the following requirements must be met:

-   The folders containing the data must be named in one of the following formats: YYYY-YYYY (e.g., 2020-2021) or YYYY (e.g., 2020) as these naming conventions are used for the script to identify the relevant data folders. The files itself do not need to follow any naming convention as long as their format is either .xlsx or .csv.

-   The R project and the data folders must be in the same directory.

-   Each data folder to be analysed must contain one or more Excel or CSV files with a .xlsx or .csv extension. If multiple files are present in a year folder then the tool will process all of them. These files will be combined into one dataset for that year so they must have the [same question structure]{.underline}. It will only be asked once per year which question to analyse. During the analysis, when the user selects a question for a year, the tool applies the selection to all files in the folder and combines the data for the selected question into a single dataset for analysis.

-   The questions to be analysed must be numerical and each question should correspond to one column.

-   A folder named plots should exist in the same directory as the tool. This is where the generated plots will be saved. If the folder does not exist, the tool will create it automatically.

-   Run renv::restore() to make sure the required packages are installed and that the version is compatible with the one that was used during the creation of this project and that all functionalities work. This is, however, not necessary if the code runs with the version of the packages the users use.

## Functions

### 1. run_analysis

#### Description

Main function to run the data analysis process. Prompts the user to select folders either by specifying the desired folder(s) by entering their name(s) comma-separated or by selecting all folders by typing "all". It allows the user to exit the tool by typing "exit". For each folder all the questions will be prompted and the user needs to specify which question to analyse for that given folder or to choose "0" to skip the folder. This is because the structure of the questions changes per year as well as the order of the questions so the user has to find the right match. If a folder contains multiple Excel or CSV files, the tool automatically combines data for the selected question across all files in the folder. The plot is then generated and can be saved at the end of the analysis.\
This function handles errors in the following ways: If invalid input is provided, the tool will prompt the user to try again. If a folder or question does not meet requirements (e.g., no numeric data or no Excel or CSV file), the tool will skip that folder, display a message and continue.

#### Parameters

None

#### Steps

1.  Prompts the user to select year folders (all, comma-separated list, or exit).
2.  Validates folder selection.
3.  Iterates through each folder to prompt for question selection.
4.  Reads and validates data.
5.  Generates the plot
6.  Saves plots using the save_plot function.

### 2. read_question_data

#### Description

Reads and extracts numeric data for a specific question from all the Excel or CSV files in the given folder.

#### Parameters

-   **year_folder** *(string)*: Folder containing the Excel or CSV file.
-   **question** *(string)*: Column name corresponding to the question to analyze.

#### Returns

-   A list with:
    -   data: Numeric values for the question.
    -   max: Maximum value for the question.

### 3. clean_and_validate_input

#### Description

Prompts the user for numeric input and validates it against a specified range. This function will be used to check if the number of the question to be analysed is within the range of possible questions or 0 if desired to skip that folder.

#### Parameters

-   **prompt_message** *(string)*: Message to display to the user.
-   **max_value** *(integer)*: Maximum valid value.

#### Returns

-   Validated numeric input.

### 4. find_shortest_question

#### Description

In case multiple years are being analysed together, this function identifies the shortest question (in terms of character length) from the list of questions the user selected for the different years. This question will be used in the titles of the plots.

#### Parameters

-   **questions** *(list)*: List of question strings.

#### Returns

-   Shortest question string.

### 5. save_plots

#### Description

Saves plots to a specified output directory.

#### Parameters

-   **plot** *(list)*: A list of ggplot objects to save.
-   **output_dir** *(string)*: Directory to save the plots. Defaults to "./plots".

#### Behavior

-   If the user specifies 0, no plots are saved.
-   Dynamic resizing ensures combined plots are legible.

## Outputs

-   **Plots**: Saved in the specified directory ("./plots" by default).
