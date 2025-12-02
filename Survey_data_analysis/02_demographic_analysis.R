# Nikki Grens
# Date: 02-03-2025
# Survey Data Analysis - Demographic analysis

# Function to calculate percentage
calculate_percentage_demographic <- function(data) {
  data %>%
    mutate(Percentage = round((Count / sum(Count)) * 100, 2))
}

# Function to calculate distribution of answers for any variable
calculate_distribution <- function(data, column_name, label) {
  data %>%
    group_by(!!sym(column_name)) %>%
    summarise(Count = n(), .groups = "drop") %>%
    rename(!!label := !!sym(column_name)) %>%
    calculate_percentage_demographic()
}

# Function to plot distributions
plot_distribution <- function(data, x_label, title) {
  if (x_label == "Faculty") {
    # Extract abbreviation inside parentheses
    data <- data %>%
      mutate(Short_Label = str_extract(.data[[x_label]], "\\((.*?)\\)") %>% 
               str_replace_all("[()]", "")) %>%
      mutate(Short_Label = ifelse(is.na(Short_Label), .data[[x_label]], Short_Label))  # Fallback to full name
  } else {
    data <- data %>% mutate(Short_Label = .data[[x_label]])  # Use full name for other labels
  }
  
  categories <- unique(data[[x_label]])
  color_palette <- setNames(viridis(length(categories), option = "D"), categories)
  
  ggplot(data, aes(x = Short_Label, y = Count, fill = .data[[x_label]])) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = paste0(Percentage, "%")), vjust = -0.5) + 
    scale_fill_manual(values = color_palette) +
    labs(
      title = title,
      x = paste0("\n", x_label),
      y = "Count \n",
      fill = x_label
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
}


# Function to calculate response statistics for matched and not matched data
calculate_response_stats <- function(pre_data, post_data, matched_data, mode_name) {
  # Calculate counts
  total_pre <- nrow(pre_data)
  total_post <- nrow(post_data)
  matched_count <- nrow(matched_data)
  total_unique <- total_pre + total_post - matched_count
  
  # Calculate percentages
  matched_percentage <- round((matched_count / total_unique) * 100, 2)
  
  # Return a dataframe with results
  return(data.frame(
    Mode = mode_name,
    Total_Pre = total_pre,
    Total_Post = total_post,
    Matched = matched_count,
    Unique_Respondents = total_unique,
    Matched_Percentage = matched_percentage
  ))
}