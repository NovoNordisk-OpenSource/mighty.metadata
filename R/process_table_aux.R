# Helper function to remove NULL and NA values from a list
# This ensures cleaner YAML output without empty/NA fields
clean_list <- function(x) {
  if (is.list(x)) {
    # Remove NULL or NA elements
    x <- x[!sapply(x, function(y) is.null(y) || (length(y) == 1 && is.na(y)))]
    # Recursively clean nested lists
    x <- lapply(x, clean_list)
    if (length(x) == 0) return(NULL)
    return(x)
  } else {
    return(x)
  }
}

# Helper function to check if origindescription is a simple Dataset.Column format
# Fixed to handle vectors properly
is_simple_predecessor <- function(desc) {
  # Pattern for simple predecessor: word.word with no additional text
  simple_pattern <- "^[A-Za-z0-9_]+\\.[A-Za-z0-9_]+$"

  # Handle NA values
  is_na <- is.na(desc)

  # For non-NA values, check if they match the simple pattern
  result <- rep(TRUE, length(desc))  # Default to TRUE
  result[!is_na] <- grepl(simple_pattern, trimws(desc[!is_na]))

  return(result)
}

# Helper function to extract domain references from text
extract_domain_references <- function(text) {
  if (is.null(text) || length(text) == 0 || all(is.na(text))) {
    return(character(0))
  }

  # Combine all non-NA text elements
  combined_text <- paste(text[!is.na(text)], collapse = " ")

  # Pattern to match uppercase domain.column references
  # This looks for uppercase letters/numbers followed by a period and more uppercase letters/numbers
  pattern <-  "\\b([A-Z][A-Z0-9]*)\\.[A-Z][A-Z0-9]*\\b"

  # Extract all matches
  matches <- regmatches(combined_text, gregexpr(pattern, combined_text))[[1]]

  # Extract just the domain part (before the period)
  domains <- unique(sub("\\..*", "", matches))

  return(domains)
}
