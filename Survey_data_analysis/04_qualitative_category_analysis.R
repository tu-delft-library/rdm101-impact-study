# Nikki Grens
# Date: 06-03-2025
# Survey Data Analysis: Qualitative Analysis of Questions with "Known" Categories

# Categorisation function which first tries to assign an exact of the response
# with the different given categories. If this is not possible a similarity 
# analysis is performed where some answers are also categorised. If this did not 
# work then a manual categorisation is performed where the user decided to which
# category the answer is assigned to or assigns the answers to a new category or
# leaves it as other
categorise_clean_responses <- function(data, column_name, categories) {
  qualitative_df <- data %>%
    select(all_of(column_name)) %>%
    rename(Qualitative_Response = all_of(column_name)) %>%
    filter(Qualitative_Response != "", !is.na(Qualitative_Response))  %>%
    mutate(Qualitative_Response = strsplit(as.character(Qualitative_Response), "\\s*(;|,|and)\\s*")) %>%
    unnest(Qualitative_Response) %>%
    mutate(Qualitative_Response = trimws(Qualitative_Response),
           Clean_Response = tolower(Qualitative_Response),
           Clean_Response = removePunctuation(Qualitative_Response))
  
  categories <- names(category_keywords)
  
  assign_category <- function(response) {
    # First, check for exact keyword matches
    for (category in names(category_keywords)) {
      if (any(str_detect(response, fixed(category_keywords[[category]], ignore_case = TRUE)))) {
        return(category)  # Return category immediately if an exact match is found
      }
    }
    
    # If no exact match is found, use Jaro-Winkler similarity to find the closest category
    similarities <- stringdistmatrix(response, categories, method = "jw")  # Jaro-Winkler similarity
    best_match_index <- which.min(similarities)  # Find the closest category
    
    # If similarity is too low (e.g., similarity > 0.25), assign "Other"
    if (similarities[best_match_index] > 0.25) {
      return("Other")
    }
    
    return(categories[best_match_index])
  }
  
  qualitative_df$Assigned_Category <- sapply(qualitative_df$Clean_Response, assign_category)
  
  # Ask the user for manual categorization of "Other" cases
  for (i in seq_along(qualitative_df$Assigned_Category)) {
    if (qualitative_df$Assigned_Category[i] == "Other") {
      cat("\nResponse:", qualitative_df$Qualitative_Response[i])
      cat("\nIt was classified as 'Other'. What would you like to do?\n")
      cat("1: Assign to an existing category\n")
      cat("2: Create a new category\n")
      cat("3: Keep as 'Other'\n")
      cat("\nExisting Categories:\n")
      for (j in seq_along(categories)) {
        cat(j, ":", categories[j], "\n")
      }
      
      choice <- as.integer(readline("Enter your choice (1/2/3): "))
      
      if (choice == 1) {
        category_index <- as.integer(readline("Enter the number of the category: "))
        if (category_index %in% seq_along(categories)) {
          qualitative_df$Assigned_Category[i] <- categories[category_index]
          cat("Assiged to ")
          cat(categories[category_index])
        } else {
          cat("Invalid selection. Keeping as 'Other'.\n")
        }
      } else if (choice == 2) {
        new_category <- readline("Enter the new category name: ")
        categories <- c(categories, new_category)  # Add new category
        qualitative_df$Assigned_Category[i] <- new_category
      }
    }
  }
  
  return(qualitative_df)
}


# Categorises the multiple choice questions which allowed for more than one answer
categorise_multiple_choice_questions <- function(data, column_name){
  multi_df <- data %>%
    select(all_of(column_name)) %>%
    rename(Assigned_Category = all_of(column_name)) %>%
    filter(Assigned_Category != "", !is.na(Assigned_Category)) %>%
    mutate(Assigned_Category = strsplit(as.character(Assigned_Category), "\\s*;\\s*")) %>%
    unnest(Assigned_Category) %>%
    mutate(
      Assigned_Category = str_remove_all(Assigned_Category, "^,|,$"),
      Assigned_Category = trimws(Assigned_Category)
    )
  
  return(multi_df)
}

# Plot the categorised answers
plot_categorised_responses <- function(data, title, categories = NULL){
  data <- data %>%
    mutate(Assigned_Category = as.character(Assigned_Category)) %>%
    separate_rows(Assigned_Category, sep = "\\s*;\\s*")
  
  category_counts <- data %>%
    count(Assigned_Category, sort = TRUE)
  
  if (!is.null(categories)) {
    category_counts$Assigned_Category <- factor(
      category_counts$Assigned_Category,
      levels = categories
    )
    
    full_palette <- viridis(length(categories), option = "D")
    names(full_palette) <- categories
    used_palette <- full_palette[levels(droplevels(category_counts$Assigned_Category))]
    
  } else {
    categories <- unique(category_counts$Assigned_Category)
    category_counts$Assigned_Category <- factor(
      category_counts$Assigned_Category,
      levels = categories
    )
    used_palette <- viridis(length(categories), option = "D")
  }
  
  ggplot(category_counts, aes(x = Assigned_Category, y = n, fill = Assigned_Category)) +
    geom_bar(stat = "identity") +
    scale_fill_manual(values = used_palette) +
    coord_flip() +
    theme_minimal() +
    labs(title = title, x = "Category \n ", y = " \nCount") +
    scale_y_continuous(breaks = seq(0, 50, by = 10), limits = c(0, 55)) +
    theme(legend.position = "none")
  
}

# Plot of comparision between responses for different category questions
plot_categorised_responses_comparision <- function(data1, data2, title1, title2, categories1 = NULL, categories2 = NULL) {
  process_data <- function(data) {
    data %>%
      mutate(Assigned_Category = as.character(Assigned_Category)) %>%
      separate_rows(Assigned_Category, sep = "\\s*;\\s*") %>%
      count(Assigned_Category, sort = TRUE)
  }
  
  # Process both datasets
  category_counts1 <- process_data(data1)
  category_counts2 <- process_data(data2)
  
  # If not provided, use union of categories as default levels
  if (is.null(categories1)) categories1 <- sort(unique(category_counts1$Assigned_Category))
  if (is.null(categories2)) categories2 <- sort(unique(category_counts2$Assigned_Category))
  
  # Ensure both datasets have complete categories
  category_counts1 <- category_counts1 %>%
    complete(Assigned_Category = categories1, fill = list(n = 0))
  category_counts2 <- category_counts2 %>%
    complete(Assigned_Category = categories2, fill = list(n = 0))
  
  # Apply factor levels according to the supplied order
  category_counts1$Assigned_Category <- factor(category_counts1$Assigned_Category, levels = categories1)
  category_counts2$Assigned_Category <- factor(category_counts2$Assigned_Category, levels = categories2)
  
  # Now assign color palette based on desired final order (not on union)
  final_categories <- union(categories1, categories2)
  palette <- setNames(viridis(length(final_categories), option = "D"), final_categories)
  
  # Plot for first dataset
  plot1 <- ggplot(category_counts1, aes(x = Assigned_Category, y = n, fill = Assigned_Category)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    theme_minimal() +
    scale_fill_manual(values = palette) +
    labs(title = title1, x = "Category", y = "\nCount") +
    scale_y_continuous(breaks = seq(0, 20, by = 5), limits = c(0, 22)) +
    theme(legend.position = "none")
  
  # Plot for second dataset
  plot2 <- ggplot(category_counts2, aes(x = Assigned_Category, y = n, fill = Assigned_Category)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    theme_minimal() +
    scale_fill_manual(values = palette) +
    labs(title = title2, x = "Category", y = "\nCount") +
    scale_y_continuous(breaks = seq(0, 20, by = 5), limits = c(0, 22)) +
    theme(legend.position = "none")
  
  # Combine both plots
  combined_plot <- plot1 + plot2 + plot_layout(ncol = 2)
  print(combined_plot)
}




# Preparing the worldcloud data frame
categorise_wordcloud_question <- function(data, column_name){
  wordcloud_df <- data %>%
    select(all_of(column_name)) %>%
    rename(Responses = all_of(column_name)) %>%
    filter(Responses != "", !is.na(Responses)) %>%
    mutate(Responses = strsplit(as.character(Responses), "\\s*[;,]\\s*")) %>%
    unnest(Responses) %>%
    mutate(Responses = trimws(Responses),
           Cleaned_Words = tolower(Responses),
           Cleaned_Words = removePunctuation(Cleaned_Words),
           Cleaned_Words = removeWords(Cleaned_Words, stopwords("en")))
}

#Plot of the worldcloud
plot_wordcloud <- function(data){
  word_frequencies <- data %>%
    count(Cleaned_Words, sort = TRUE)

  wordcloud2(word_frequencies, size = 1)
}