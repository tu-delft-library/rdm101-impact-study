# Function to read and extract data for a specific question from a year's Excel file
read_question_data <- function(year_folder, question) {
  folder_path <- file.path(year_folder)
  
  # Locate the Excel file in the folder
  file_paths <- list.files(folder_path, pattern = "\\.(xlsx|csv)$", full.names = TRUE)
  
  # Check if an Excel file exists
  if (length(file_paths) == 0) {
    cat("No Excel or CSV file found in the specified folder:", year_folder, "\n")
    return(NULL)
  }
  
  # Combine data from all files in the folder
  combined_data <- lapply(file_paths, function(file_path) {
    if (grepl("\\.xlsx$", file_path)) {
      data <- read_excel(file_path, col_types = "text")
    } else if (grepl("\\.csv$", file_path)) {
      first_line <- readLines(file_path, n = 1)
      delimiter <- ifelse(grepl(";", first_line), ";", ",")
      data <- read.csv(file_path, sep = delimiter, stringsAsFactors = FALSE, check.names = FALSE)
    }
    question_data <- data[[question]]
    question_data <- question_data[!is.na(question_data) & question_data != ""]
    as.numeric(as.character(question_data))  # Convert to numeric if applicable
  })
  
  combined_data <- unlist(combined_data)
  combined_data <- combined_data[!is.na(combined_data)]  # Remove NAs
  if (length(combined_data) > 0) {
    return(list(data = combined_data, max = max(combined_data, na.rm = TRUE)))
  } else {
    cat("The question", question, "contains no numeric data across files in", year_folder, "\n")
    return(NULL)
  }
}


# Helper function to clean and validate numeric input for which question to be analysed
clean_and_validate_input <- function(prompt_message, max_value) {
  valid_input <- FALSE
  while (!valid_input) {
    user_input <- readline(prompt = prompt_message)
    
    # Remove non-numeric characters
    cleaned_input <- gsub("[^0-9]", "", user_input)
    
    # Convert cleaned input to integer
    numeric_input <- as.integer(cleaned_input)
    
    # Validate the numeric input
    if (!is.na(numeric_input) && numeric_input >= 0 && numeric_input <= max_value) {
      valid_input <- TRUE
      return(numeric_input)
    } else {
      cat("Invalid input. Please enter a valid number between 0 and", max_value, ".\n")
    }
  }
}


# Helper function to find the shortest question from a list
find_shortest_question <- function(questions) {
  shortest_index <- which.min(nchar(questions))
  return(questions[shortest_index])
}

find_longest_question <- function(questions) {
  longest_index <- which.max(nchar(questions))
  return(questions[longest_index])
}