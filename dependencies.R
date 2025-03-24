# dependencies.R

# List of required packages
packages <- c("shiny", "shinythemes", "syuzhet", "tidytext", "dplyr",
              "ggplot2", "wordcloud2", "DT", "textdata")

# Function to check for and install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Install all missing packages
invisible(sapply(packages, install_if_missing))
