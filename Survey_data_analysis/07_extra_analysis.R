# Nikki Grens
# Date: 12-03-2025
# Survey Data Analysis: Extra functions

# Calculate the occurence of yes, no, maybe like questions
calculate_occurrence_percentage <- function(data, column_name) {
  data %>%
    count(!!sym(column_name)) %>%
    mutate(Percentage = round(n / sum(n) * 100, 2))
}

# Change the category names on a specific excel file containing the qualitative analysis for one question
map_and_save_categories <- function(file_path, category_mapping, category_column = "Assigned_Category") {
  df <- read_excel(file_path)
  
  if (!category_column %in% colnames(df)) {
    stop(paste("Column", category_column, "not found in the Excel file."))
  }

  df_processed <- df %>%
    mutate(!!category_column := str_trim(as.character(!!sym(category_column)))) %>%
    separate_rows(!!sym(category_column), sep = "\\s*;\\s*") %>%
    mutate(
      Mapped_Category = if_else(
        !!sym(category_column) %in% names(category_mapping),
        category_mapping[!!sym(category_column)],
        !!sym(category_column)
      )
    ) %>%
    group_by(across(-c(!!sym(category_column), Mapped_Category))) %>%
    summarise(!!category_column := paste(unique(Mapped_Category), collapse = "; "), .groups = "drop")

  write_xlsx(df_processed, file_path)
  
  return(df_processed)
}
