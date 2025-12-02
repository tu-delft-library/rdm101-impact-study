# Nikki Grens
# Date: 06-03-2025
# Survey Data Analysis: Qualitative Analysis of Open Questions

# Cleans the open responses and seperates them by ; as this was used in some 
# cases if multiple answers were given
clean_open_responses <- function(data, column_name){
  open_df <- data %>%
    select(all_of(column_name)) %>%
    rename(Response = all_of(column_name)) %>%
    filter(Response !="", !is.na(Response)) %>%
    mutate(Response = strsplit(as.character(Response), "\\s*[;]\\s*")) %>%
    unnest(Response) %>%
    mutate(Response = trimws(Response))
  
  return(open_df)
}

# Categorise open responses manually by assigning them to one of the given 
#categories or assigning them to a new category or leaving as other. Removing 
# the answer is also an option in case it does not contain useful feedback
categorise_open_responses <- function(data, categories){
  data <- data %>% mutate(Assigned_Category = vector("list", nrow(data)))
  
  # Iterate over each response and allow flexible category assignment
  for (i in seq_along(data$Response)) {
    cat("\nResponse:", data$Response[i])  
    cat("\nCurrently classified as 'Other'. What would you like to do?\n")
    cat("1: Assign to existing categories\n")
    cat("2: Create new categories\n")
    cat("3: Keep as 'Other'\n")
    cat("4: Remove answer\n")
    
    # Display existing categories
    if (length(categories) > 0) {
      cat("\nExisting Categories:\n")
      for (j in seq_along(categories)) {
        cat(j, ":", categories[j], "\n")
      }
    }
    
    # Get user input (allows multiple options)
    choice <- strsplit(readline("Enter your choice (comma-separated, e.g., 1,2,3,4): "), ",")[[1]]
    choice <- as.integer(trimws(choice))  # Convert to numbers
    
    if (4 %in% choice) {
      data$Assigned_Category[[i]] <- "REMOVE"
      cat("Marked for removal.\n")
      next
    }
    
    assigned_categories <- c()  # Store selected categories
    
    if (1 %in% choice && length(categories) > 0) {
      # Assign to multiple existing categories
      category_indices <- strsplit(readline("Select existing categories (comma-separated numbers, e.g., 1,3):"), ",")[[1]]
      category_indices <- as.integer(trimws(category_indices))
      
      valid_existing <- categories[category_indices[category_indices %in% seq_along(categories)]]
      if (length(valid_existing) > 0) {
        assigned_categories <- c(assigned_categories, valid_existing)
        cat("Assigned to existing categories:", paste(valid_existing, collapse = ", "), "\n")
      } else {
        cat("Invalid selection for existing categories.\n")
      }
    }
    
    if (2 %in% choice) {
      # Create multiple new categories
      new_categories <- strsplit(readline("Enter new categories (comma-separated, e.g., new1, new2):"), ",")[[1]]
      new_categories <- trimws(new_categories)
      
      if (length(new_categories) > 0 && any(nzchar(new_categories))) {
        categories <- unique(c(categories, new_categories))  # Add new categories to the list
        assigned_categories <- c(assigned_categories, new_categories)
        cat("Created and assigned to new categories:", paste(new_categories, collapse = ", "), "\n")
      } else {
        cat("No valid new categories entered.\n")
      }
    }
    
    if (3 %in% choice || length(assigned_categories) == 0) {
      assigned_categories <- c("Other")  # Keep as 'Other' if no category was assigned
      cat("Kept as 'Other'.\n")
    }
    
    # Store categories in the dataframe as a list
    data$Assigned_Category[[i]] <- assigned_categories
  }
  
  data <- data %>% filter(Assigned_Category != "REMOVE")
  
  data$Assigned_Category <- sapply(data$Assigned_Category, function(x) paste(x, collapse = "; "))
  return(data)
}

# Plot the categorised asnwers
plot_categorised_open_responses <- function(data, title){
  # Ensure Assigned_Category is properly formatted
  data <- data %>%
    mutate(Assigned_Category = as.character(Assigned_Category))  # Ensure it's character before splitting
  
  # Split multiple categories into separate rows
  category_counts <- data %>%
    separate_rows(Assigned_Category, sep = "; ") %>%  # Splitting category strings into individual rows
    count(Assigned_Category, sort = TRUE)
  
  categories <- unique(category_counts$Assigned_Category)
  palette <- setNames(viridis(length(categories), option = "D"), categories)
  
  # Bar chart for categorized topics
  ggplot(category_counts, aes(x = reorder(Assigned_Category, -n), y = n, fill = Assigned_Category)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    theme_minimal() +
    scale_fill_manual(values = palette) +
    labs(title = title,
         x = "Category",
         y = "Count") +
    #scale_y_continuous(breaks = seq(0, 35, by = 10), limits = c(0, 37)) +
    theme(legend.position = "none")
}

# Perform categorisation to data saved in an excell file which allows to save 
# the work done and not constantly repeat the entire project
# This allows for certain options to be revised
# Same workflow as above but now it allows to keep selection, proceed as above or
# directly remove it from the dataset
# This function saves the updated results again in the excel file
continuation_categorise_open_responses <- function(file_path, categories) {
  # Load data from Excel
  data <- read_excel(file_path)
  
  # Ensure Assigned_Category exists and convert it into a list of categories
  if (!"Assigned_Category" %in% colnames(data)) {
    data <- data %>% mutate(Assigned_Category = vector("list", nrow(data)))
  } else {
    data <- data %>%
      mutate(Assigned_Category = ifelse(is.na(Assigned_Category), "Other", Assigned_Category),
             Assigned_Category = strsplit(Assigned_Category, "; "))  # Convert from string to list
  }
  
  for (i in seq_along(data$Response)) {
    cat("\nResponse:", data$Response[i])  
    
    # Show existing categorization
    if (!is.null(data$Assigned_Category[[i]]) && length(data$Assigned_Category[[i]]) > 0) {
      cat("\nCurrently assigned categories:", paste(data$Assigned_Category[[i]], collapse = ", "), "\n")
    } else {
      cat("\nCurrently classified as 'Other'.\n")
    }
    
    cat("Options:\n")
    cat("1: Keep existing categories\n")
    cat("2: Modify categories\n")
    cat("3: Remove from dataset\n")
    
    choice <- as.integer(trimws(readline("Enter your choice (1,2,3): ")))
    
    if (choice == 1) {
      cat("Keeping existing categories.\n")
      next  # Move to the next response
    }
    
    if (choice == 3) {
      data$Assigned_Category[[i]] <- "REMOVE"
      cat("Marked for removal.\n")
      next
    }
    
    # If modifying categories, show options
    cat("\nModify categories:\n")
    cat("1: Assign to existing categories\n")
    cat("2: Create new categories\n")
    cat("3: Keep as 'Other'\n")
    
    if (length(categories) > 0) {
      cat("\nExisting Categories:\n")
      for (j in seq_along(categories)) {
        cat(j, ":", categories[j], "\n")
      }
    }
    
    modify_choice <- strsplit(readline("Enter your choice (comma-separated, e.g., 1,2,3): "), ",")[[1]]
    modify_choice <- as.integer(trimws(modify_choice))
    
    assigned_categories <- c() # Keep existing categories
    
    if (1 %in% modify_choice && length(categories) > 0) {
      category_indices <- strsplit(readline("Select existing categories (comma-separated numbers, e.g., 1,3): "), ",")[[1]]
      category_indices <- as.integer(trimws(category_indices))
      
      valid_existing <- categories[category_indices[category_indices %in% seq_along(categories)]]
      if (length(valid_existing) > 0) {
        assigned_categories <- valid_existing  # Merge with existing
        cat("Assigned to existing categories:", paste(valid_existing, collapse = ", "), "\n")
      } else {
        cat("Invalid selection for existing categories.\n")
      }
    }
    
    if (2 %in% modify_choice) {
      new_categories <- strsplit(readline("Enter new categories (comma-separated, e.g., new1, new2): "), ",")[[1]]
      new_categories <- trimws(new_categories)
      
      if (length(new_categories) > 0 && any(nzchar(new_categories))) {
        categories <- unique(c(categories, new_categories))  # Add new categories globally
        assigned_categories <- unique(c(assigned_categories, new_categories))  # Merge new with existing
        cat("Created and assigned to new categories:", paste(new_categories, collapse = ", "), "\n")
      } else {
        cat("No valid new categories entered.\n")
      }
    }
    
    if (3 %in% modify_choice || length(assigned_categories) == 0) {
      assigned_categories <- c("Other")  # Keep as 'Other' if nothing was assigned
      cat("Kept as 'Other'.\n")
    }
    
    # Store updated categories
    data$Assigned_Category[[i]] <- assigned_categories
  }
  
  # Remove marked responses
  data <- data %>% filter(Assigned_Category != "REMOVE")
  
  # Convert lists back to strings for saving in Excel
  data$Assigned_Category <- sapply(data$Assigned_Category, function(x) paste(x, collapse = "; "))
  
  # Save updated data back to Excel
  write_xlsx(data, file_path)
  cat("\nUpdated categorization saved to", file_path, "\n")
  
  return(data)
}