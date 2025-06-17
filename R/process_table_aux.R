#' Cleaner function for recursively removing empty records from a list
#' @description Helper function to remove NULL and NA values from a list.
#' This ensures cleaner YAML output without empty/NA fields
#' @param x A (nested) list containing NULL or missing records to be cleaned up
#' @return The cleaned up list.
#' @keywords internal
#' @noRd
clean_list <- function(x) {
  if (is.list(x)) {
    # Remove NULL or NA elements
    x <- x[!sapply(x, function(y) is.null(y) || (length(y) == 1 && is.na(y)))]
    # Recursively clean nested lists
    x <- lapply(x, clean_list)
    if (length(x) == 0) return(NULL)
    x
  } else {
    x
  }
}

#' Function to determine if a record's origin is a simple predecessor
#' @description Helper function to check if origindescription is a simple Dataset.Column format
#' @param desc a vector of origin descriptions
#' @return A logical vector indicating if those descriptions are of simple predecessor
#' @keywords internal
#' @noRd
is_simple_predecessor <- function(desc) {
  # Pattern for simple predecessor: word.word with no additional text
  simple_pattern <- "^[A-Za-z0-9_]+\\.[A-Za-z0-9_]+$"

  # Handle NA values
  is_na <- is.na(desc)

  # For non-NA values, check if they match the simple pattern
  result <- rep(TRUE, length(desc))  # Default to TRUE
  result[!is_na] <- grepl(simple_pattern, trimws(desc[!is_na]))

  result
}
