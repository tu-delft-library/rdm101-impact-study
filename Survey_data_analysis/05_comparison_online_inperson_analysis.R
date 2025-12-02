# Nikki Grens
# Date: 06-03-2025
# Survey Data Analysis: Comparison Analysis Between Online and In Person Sessions

# Gets the frequency of the scores given to the questions used to evaluate the 
# performance of online training vs in-person training
comparison_questions_frequency <- function(data, training_name){
  comparison_df <- data %>%
    select(Q15_1:Q15_8) %>%
    mutate(across(Q15_1:Q15_8, ~ as.integer(as.numeric(.)))) %>%
    drop_na()
  
  frequency_df <- comparison_df %>%
    pivot_longer(cols = Q15_1:Q15_8, names_to = "Question", values_to = "Rating") %>%
    group_by(Question, Rating) %>%
    summarise(Count = n(), .groups = "drop") %>%
    mutate(Format = training_name)
  
  return(frequency_df)
  
}

# Calculates the percentages to account for a different number of participanst in
# the two tips of training
calculate_percentage <- function(data) {
  data %>%
    group_by(Question, Format) %>%
    mutate(Percentage = (Count / sum(Count)) * 100) %>%
    ungroup()
}

# Plot the comparision results with each question a seperate bar plot - used
plot_comparison_online_inperson_grouped <- function(combined_percentage){
  # Create a lookup table for full question names
  question_titles <- c(
    "1" = "Interaction with peers",
    "2" = "Interaction with trainers",
    "3" = "Assignments",
    "4" = "Feedback on assignments",
    "5" = "Online content",
    "6" = "In-class activities",
    "7" = "Quizzes",
    "8" = "Discussion forums"
  )
  
  # Remove "Q15_" and replace with full question titles
  combined_percentage <- combined_percentage %>%
    mutate(Question = str_remove(Question, "Q15_") %>% recode(!!!question_titles))
  
  all_ratings <- unique(combined_percentage$Rating)
  
  full_ratings <- expand.grid(
    Rating = all_ratings,  
    Question = unique(combined_percentage$Question)  # Ensure each question has all ratings
  )
  
  combined_percentage <- full_ratings %>%
    left_join(combined_percentage, by = c("Rating", "Question")) %>%
    mutate(Percentage = ifelse(is.na(Percentage), 0, Percentage))
  
  palette <- viridis(2, option = "D")
  
  ggplot(combined_percentage, aes(x = factor(Rating), y = Percentage, fill = Format)) +
    scale_x_discrete(drop = FALSE) +
    scale_y_continuous(
      limits = c(0, 100),
      breaks = seq(0, 100, 20),
      minor_breaks = seq(0, 100, 5)
    ) +
    geom_bar(stat = "identity", position = "dodge") +
    facet_wrap(~ Question, scales = "free_x") +  # Assigns new question titles as facet labels
    theme_minimal() +
    labs(title = "On a scale of 1 to 5, how helpful was each training component in facilitating your effective learning?",
         x = "Scale (1-5)",
         y = "Percentage (%)") +
    #scale_fill_manual(values = palette) +
    scale_fill_manual(values = c("Online" = "#287C8EFF", "In-Person" = "#C7E020FF")) +
    theme(legend.position = "bottom",
          strip.text = element_text(size = 12))#, face = "bold"))  # Improve facet title readability
}