# Nikki Grens
# Date: 02-03-2025
# Survey Data Analysis - Match the answers between pre and post survey

# Ensures that only the rows corresponding to students who answered both the pre
# and post survey are analysed
process_matching <- function(pre_training, post_training, matching_column) {
  # Filter rows where the matching column is not empty
  pre_training <- pre_training %>%
    filter(!is.na(.data[[matching_column]]) & .data[[matching_column]] != "")
  post_training <- post_training %>%
    filter(!is.na(.data[[matching_column]]) & .data[[matching_column]] != "")
  
  # Convert matching column to lowercase for case-insensitivity
  pre_keys <- tolower(as.character(pre_training[[matching_column]]))
  post_keys <- tolower(as.character(post_training[[matching_column]]))
  
  # Find exact matches
  matched_values_initial <- intersect(pre_keys, post_keys)
  
  # Find unmatched keys
  unmatched_pre_keys <- setdiff(pre_keys, matched_values_initial)
  unmatched_post_keys <- setdiff(post_keys, matched_values_initial)
  
  # Find partial matches (at least 3 matching characters)
  partial_matches <- expand.grid(pre_key = unmatched_pre_keys, post_key = unmatched_post_keys) %>%
    mutate(
      pre_key = as.character(pre_key),
      post_key = as.character(post_key),
      similarity = stringdist(pre_key, post_key, method = "lv"),
      min_length = pmin(nchar(pre_key), nchar(post_key))
    ) %>%
    filter(similarity <= (min_length - 3))
  
  # Print partial matches
  if (nrow(partial_matches) > 0) {
    cat("Partial Matches Found:\n")
    print(partial_matches %>% select(pre_key, post_key, similarity))
  } else {
    cat("No partial matches found.\n")
  }
  
  # Select partial matches with a stricter threshold (e.g., similarity <= 1)
  selected_partial_matches <- partial_matches %>%
    filter(similarity <= 1)
  
  # Combine exact and partial matches
  matched_values <- c(matched_values_initial, selected_partial_matches$pre_key, selected_partial_matches$post_key)
  
  # Filter matched datasets
  matched_post_training <- post_training %>%
    mutate(lower_matching_column = tolower(.data[[matching_column]])) %>%
    filter(lower_matching_column %in% matched_values) %>%
    arrange(match(lower_matching_column, matched_values))
  
  matched_pre_training <- pre_training %>%
    mutate(lower_matching_column = tolower(.data[[matching_column]])) %>%
    filter(lower_matching_column %in% matched_values) %>%
    arrange(match(lower_matching_column, matched_values))
  
  # Remove the temporary lowercase column
  matched_post_training <- matched_post_training %>% select(-lower_matching_column)
  matched_pre_training <- matched_pre_training %>% select(-lower_matching_column)
  
  # Return the matched datasets
  return(list(
    matched_post_training = matched_post_training,
    matched_pre_training = matched_pre_training
  ))
}