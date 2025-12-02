# Function to save the desired plots
save_plots <- function(plots, output_dir = "./plots") {
  # Ensure the output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  # Display available plots for the user
  cat("\nAvailable plots to save:\n")
  cat("0: Do not save any plot\n")
  cat("1: Seperate Year Histogram\n\n")
  
  valid_input <- FALSE
  save_input <- NULL
  
  while (!valid_input) {
    # Prompt the user for input
    save_input <- readline(prompt = "Enter the plots to save: ")
    
    if (save_input == "0") {
      cat("No plots will be saved.\n")
      return()
    }
    
    # Parse the user input into individual plot groups
    save_input <- strsplit(save_input, ",\\s*")[[1]]
    
    # Validate the input
    valid_input <- all(sapply(save_input, function(group) {
      if (grepl("-", group)) {
        indices <- as.numeric(strsplit(group, "-")[[1]])
        return(all(!is.na(indices) & indices %in% 1:length(plots)))
      } else {
        plot_index <- as.numeric(group)
        return(!is.na(plot_index) & plot_index %in% 1:length(plots))
      }
    }))
    
    if (!valid_input) {
      cat("Invalid input. Please try again.\n")
    }
  }
  
  # Ask for the base filename for saving plots
  name_base <- readline(prompt = "Enter the base name for the plot files for e.g., plot: ")
  rows_value <- readline(prompt = "How many rows does the plot have? ")

  for (group in save_input) {
    plot_index <- as.numeric(group)
    file_name <- file.path(output_dir, paste0(name_base, ".png"))
    ggsave(file_name, plots[[plot_index]], width = 6, height = 7 / 3 * as.numeric(rows_value))
  }
  
  cat("Saved plot:", file_name, "\n")
}