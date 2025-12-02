source("02_data_cleaning.R")
source("03_save_plots.R")

# Main function to run the analysis to get the different distributions of 
# the answers for a specific question
run_analysis <- function() {
  cat("Welcome to the Data Analyser Tool!\n\n")
  
  year_type_input <- ""
  while (!(year_type_input %in% c("calendar", "academic"))) {
    cat("Which type of year do you want to analyse? 'calendar' or 'academic' or 'exit'\n")
    year_type_input <- tolower(readline(prompt = "Enter type: "))
    
    if (year_type_input == "exit") {
      cat("Exiting the analysis.\n")
      return()
    }
  }
  
  
  folder_map <- c(
    "academic" = "Academic_year_data",
    "calendar" = "Calendar_year_data"
  )
  
  # Get the actual folder name
  subfolder_path <- file.path(".", folder_map[[year_type_input]])
  
  if (!dir.exists(subfolder_path)) {
    stop(paste("Folder", subfolder_path, "not found."))
  }
  
  # List available year folders
  year_folders <- list.dirs(subfolder_path, full.names = FALSE, recursive = FALSE)
  
  # Ensure valid year folders are present
  if (length(year_folders) == 0) {
    stop("No year folders found in the current directory. Please ensure folders are present.")
  }
  
  cat("Available year folders:\n")
  print(year_folders)
  
  # Prompt the user to select year folders
  valid_folders <- c()
  while (length(valid_folders) == 0) {
    cat("Enter the year folders to analyse comma-separated (e.g., 2020-2021, 2021-2022 (academic) or 2020, 2021 (calendar)) \n")
    year_input <- readline(prompt = "Type 'all' for all folders or 'exit' to stop: ")
    
    if (tolower(year_input) == "exit") {
      cat("Exiting the analysis \n")
      return()
    }
    
    if (tolower(year_input) == "all") {
      valid_folders <- year_folders[grepl("^\\d{4}(-\\d{4})?$", year_folders)]
    } else {
      selected_folders <- strsplit(year_input, ",\\s*")[[1]]
      valid_folders <- selected_folders[selected_folders %in% year_folders]
    }
    
    if (length(valid_folders) == 0) {
      cat("Invalid input. Please enter valid year folders or 'all'.\n")
    }
  }
  
  # Initialize data storage for all years
  all_data <- list()
  max_values <- c()
  selected_questions <- list()
  
  # Process each valid year folder
  for (year_folder in valid_folders) {
    folder_path <- file.path(subfolder_path, year_folder)
    file_path <- list.files(folder_path, pattern = "\\.(xlsx|csv)$", full.names = TRUE)
    
    if (length(file_path) == 0) {
      cat("No Excel or CSV file found in", year_folder, ". Skipping...\n")
      next
    }
    
    # Read headers from the Excel file
    if (grepl("\\.xlsx$", file_path[1])) {
      data <- read_excel(file_path[1], n_max = 0)
    } else if (grepl("\\.csv$", file_path)) {
      first_line <- readLines(file_path, n = 1)
      delimiter <- ifelse(grepl(";", first_line), ";", ",")
      data <- read.csv(file_path, sep = delimiter, stringsAsFactors = FALSE, check.names = FALSE)
    }
    
    headers <- colnames(data)
    
    # Display available questions for the year
    cat("\nAvailable questions in", year_folder, ":\n")
    for (i in seq_along(headers)) {
      cat(i, ":", headers[i], "\n")
    }
    cat("0: Skip this year\n")
    
    # Prompt user to select a question for analysis
    question_number <- clean_and_validate_input(
      prompt_message = paste("Enter the number of the question to analyse for", year_folder, "or 0 to skip: "),
      max_value = length(headers)
    )
    
    if (question_number == 0) {
      cat("Skipping analysis for", year_folder, "\n")
      next
    }
    
    # Process the selected question
    question <- headers[question_number]
    selected_questions[[year_folder]] <- question
    result <- read_question_data(folder_path, question)
    
    if (!is.null(result)) {
      if (year_type_input == "calendar"){
        year_folder <- substr(year_folder, 1, 4)
      }
      #all_data[[year_folder]] <- result$data
      if (!is.null(all_data[[year_folder]])) {
        all_data[[year_folder]] <- c(all_data[[year_folder]], result$data)
      } else {
        all_data[[year_folder]] <- result$data
      }
      
      max_values <- c(max_values, result$max)
      cat("Max value for", question, "in", year_folder, "is:", result$max, "\n")
    }
  }
  
  # Check for consistent maximum values
  if (length(unique(max_values)) > 1) {
    cat("The maximum values across selected years are not the same:\n")
    print(max_values)
    
    proceed <- ""
    while (!proceed %in% c("yes", "no")) {
      proceed <- tolower(readline(prompt = "Do you want to proceed with combining the data? yes/no: "))
      if (!proceed %in% c("yes", "no")) {
        cat("Invalid input. Please type 'yes' or 'no'.\n")
      }
    }
    
    if (proceed == "no") {
      stop("Analysis aborted by user.")
    }
  } else {
    cat("The maximum values across all selected years are consistent.\n")
  }
  
  # Use the shortest question as the plot title
  all_selected_questions <- unlist(selected_questions)
  shortest_question <- find_shortest_question(all_selected_questions)
  longest_question <- find_longest_question(all_selected_questions)
  
  # Combine data for plotting
  combined_data <- unlist(all_data)
  combined_data <- na.omit(combined_data)
  mean_value <- mean(combined_data)
  quantiles <- quantile(combined_data, probs = c(0.25, 0.5, 0.75))
  
  # Combined Histogram by Year
  seperated_data <- do.call(rbind, lapply(names(all_data), function(year) {
    # Order the factor levels explicitly
    data.frame(
      year = year, 
      votes = factor(all_data[[year]], levels = sort(unique(unlist(all_data))))
    )
  }))
  
  analysed_years <- unique(seperated_data$year)
  
  # Create plots
  different_values <- ""
  while (!different_values %in% c("yes", "no")) {
    different_values <- tolower(readline(prompt = "Is the maximum score of part of the questions 5 and the other part 10? yes/no: "))
    if (!different_values %in% c("yes", "no")) {
      cat("Invalid input. Please type 'yes' or 'no'.\n")
    }
  }
  
  
  # Plot for each year separately
  year_data <- seperated_data %>%
    group_by(year) %>%
    {
      if (different_values == "yes") {
        mutate(., votes = if (max(as.numeric(as.character(votes))) <=5) 2 * as.numeric(as.character(votes)) else as.numeric(as.character(votes)))
      } else {
        .
      }
    } %>%
    #mutate(votes = if (max(as.numeric(as.character(votes))) <=5) 2 * as.numeric(as.character(votes)) else as.numeric(as.character(votes))) %>%
    ungroup() %>% 
    group_by(year, votes) %>%
    summarise(count = n(), .groups = "drop") %>%
    group_by(year) %>%
    mutate(percentage = round((count / sum(count)) * 100, 1)) %>%
    select(Year = year, Rating = votes, Percentage = percentage)
  
  
    
  response_counts <- seperated_data %>%
    group_by(year) %>%
    summarise(total_responses = n(), .groups = "drop")
  
  count_data <- seperated_data %>%
    group_by(year) %>%
    {
      if (different_values == "yes") {
        mutate(., votes = if (max(as.numeric(as.character(votes))) <=5) 2 * as.numeric(as.character(votes)) else as.numeric(as.character(votes)))
      } else {
        .
      }
    } %>%
    #mutate(votes = if (max(as.numeric(as.character(votes))) <=5) 2 * as.numeric(as.character(votes)) else as.numeric(as.character(votes))) %>%
    ungroup() %>% 
    group_by(year, votes) %>%
    summarise(count = n(), .groups = "drop") %>%
    select(Year = year, Rating = votes, COunt = count)
  
  # print(count_data)
  
  vote_data <- seperated_data %>%
    mutate(votes = as.numeric(as.character(votes))) %>%
    group_by(year) %>%
    {
      if (different_values == "yes") {
        mutate(., votes = if (max(votes) <=5) 2 * votes else votes)
      } else {
        .
      }
    } %>%
    ungroup() %>% 
    select(Year = year, votes = votes)
  
  summary_stats <- vote_data %>%
    group_by(Year) %>%
    summarise(
      standard_deviation = sd(votes, na.rm = TRUE),
      mean_rating = mean(votes, na.rm = TRUE),
      q25 = quantile(votes, 0.25, na.rm = TRUE),
      q75 = quantile(votes, 0.75, na.rm = TRUE),
      min_rating = min(votes, na.rm = TRUE),
      max_rating = max(votes, na.rm = TRUE),
      .groups = "drop"
    )
  
  max_value <- vote_data %>%
    summarise(max_vote = max(votes, na.rm = TRUE)) %>%
    pull(max_vote)
  
  
  #title_name <- c(paste(longest_question))
  title_name <- c(paste(shortest_question))
  individual_hist <- bar_plot(year_data, title_name, response_counts, summary_stats, max_value)
  
  
  # Combine and display plots
  print(individual_hist)
  
  # Save plots
  plots <- list(individual_hist)
  save_plots(plots)
}




bar_plot <- function(data, title_name, response_counts, summary_stats, max_value, question_titles = NULL, facet = TRUE) {
  # Optional recoding of question names
  if (!is.null(question_titles)) {
    data <- data %>%
      mutate(Year = recode(Year, !!!question_titles))
  }
  
  data <- data %>%
    mutate(Rating = as.integer(as.character(Rating)))
  
  #all_ratings <- unique(data$Rating)
  all_ratings <- 1:max_value
  
  full_ratings <- expand.grid(
    Rating = all_ratings,  
    Year = unique(data$Year)  # Ensure each question has all ratings
  )
  
  data <- full_ratings %>%
    left_join(data, by = c("Rating", "Year")) %>%
    mutate(Percentage = ifelse(is.na(Percentage), 0, Percentage))
  
  lower_text <- readline(prompt = "What does the lower score value refere to? For the x label or if not neccessary say 0 ")
  upper_text <- readline(prompt = "What does the higher score value refere to? For the x label or if not neccessary say 0 ")
  
  # Build base plot
  p <- ggplot() +
    geom_bar(data = data, aes(x = factor(Rating), y = Percentage, fill = if (facet) NULL else Question), 
             stat = "identity", position = "dodge", fill= "#0072B2") +
    # Simulate box (from Q1 to Q3)
    geom_rect(data = summary_stats,
              aes(xmin = q25, xmax = q75, ymin = 92, ymax = 98),
              fill = "skyblue") +
    
    # Whiskers
    geom_segment(data = summary_stats,
                 aes(x = min_rating, xend = q25, y = 95, yend = 95),
                 color = "skyblue", linewidth = 0.7) +
    geom_segment(data = summary_stats,
                 aes(x = q75, xend = max_rating, y = 95, yend = 95),
                 color = "skyblue", linewidth = 0.7) +
    
    # Mean point
    geom_point(data = summary_stats,
               aes(x = mean_rating, y = 95),
               color = "red", size = 1) +
    
    scale_y_continuous(
      limits = c(0, 100),
      breaks = seq(0, 100, 20),
      minor_breaks = seq(0, 100, 5)
    ) +
    theme_minimal() +
    labs(title = title_name,
         x = if (lower_text == 0 || upper_text == 0) {
           paste("Score (1 -", max_value, ")")
         } else {
           paste("Score (1 -", max_value, ")  (1 -", lower_text, ",", max_value, "-", upper_text, ")")
         },
         y = "Percentage (%)") +
    theme(
      legend.position = "bottom",
      panel.grid.minor = element_line(color = "gray90", linewidth = 0.2),
      panel.grid.major = element_line(color = "gray70", linewidth = 0.4),
      axis.text.x = element_text(),  # Show x-axis labels on all facets
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA)
    )
  
  
  # Add facetting per question if requested
  if (facet) {
    custom_labels <- setNames(
      paste0(response_counts$year, "\n(n = ", response_counts$total_responses, ", av. = ",
             round(summary_stats$mean_rating, digits = 2), ", dev. = ", 
             round(summary_stats$standard_deviation, digits = 2),  ")"),
      response_counts$year
    )
    
    p <- p +
      facet_wrap(~ Year, scales = "free_x", labeller = as_labeller(custom_labels), ncol = 2) +
      theme(
        strip.text = element_text(size = 10),
        strip.placement = "outside"
      )
  }
  
  return(p)
}