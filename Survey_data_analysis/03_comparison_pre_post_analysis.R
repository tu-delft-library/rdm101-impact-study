# Nikki Grens
# Date: 02-03-2025
# Survey Data Analysis: Plotting comparision between answers for questions
# both in Pre- and Post-Survey Data

# Extracts numerical response from answers of the style "5 - text"
extract_numeric_responses <- function(data, questions) {
  data %>%
    mutate(across(all_of(questions), ~ as.numeric(str_extract(as.character(.), "^[0-9]+"))))
}

# Calculate Statistics of the ratings provided by the student
calculate_stats <- function(pre_data, post_data, pre_questions, post_questions) {
  pre_stats <- pre_data %>%
    select(all_of(pre_questions)) %>%
    summarise(across(everything(), list(
      Mean = ~ mean(.x, na.rm = TRUE),
      SD = ~ sd(.x, na.rm = TRUE)
    ))) %>%
    pivot_longer(cols = everything(), names_to = c("Question", ".value"), names_sep = "_") %>%
    mutate(Label = c("Confidence RDM skills", "Familiarity with responsibilities", "Familiarity with FAIR", "Importance of DMP"), Survey = "Pre")
  
  post_stats <- post_data %>%
    select(all_of(post_questions)) %>%
    summarise(across(everything(), list(
      Mean = ~ mean(.x, na.rm = TRUE),
      SD = ~ sd(.x, na.rm = TRUE)
    ))) %>%
    pivot_longer(cols = everything(), names_to = c("Question", ".value"), names_sep = "_") %>%
    mutate(Label = c("Confidence RDM skills", "Familiarity with responsibilities", "Familiarity with FAIR", "Importance of DMP"), Survey = "Post")
  
  bind_rows(pre_stats, post_stats)
}


# Plot function to get comparision between average score for differnet questiosn is both surveys
plot_survey_comparison <- function(data, title, error = FALSE) {
  p <- ggplot(data %>%
           mutate(Survey = factor(Survey, levels = c("Pre", "Post"))), # Set order of Survey levels
         aes(x = Survey, y = Mean, group = Label, color = Label)) +
    geom_point(size = 3) +
    geom_line(linewidth = 1) +
    scale_color_manual(values = c("Confidence RDM skills" = "#0072B2", "Familiarity with responsibilities" = "#009E73", "Familiarity with FAIR" = "#CC79A7", "Importance of DMP" = "#E69F00")) +
    labs(
      title = title,
      x = "Survey Stage",
      y = "Mean Response",
      #color = "Question Label"
    ) +
    theme_minimal() +
    theme(
      legend.position = "top",
      axis.text.x = element_text(size = 12, face = "bold"),
      axis.text.y = element_text(size = 12),
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
    )
  
  if (error) {
    p <- p + geom_errorbar(aes(ymin = Mean - SD, ymax = Mean + SD), width = 0.1)
  }
  
  return(p)
}