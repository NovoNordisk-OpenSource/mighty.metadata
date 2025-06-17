# Functions for writing YAML files

#' Write a single ADaM domain metadata to YAML file
#' @description Writes a single ADaM domain metadata to a YAML file with proper formatting.
#' Origin fields are formatted as multiline strings with literal block scalar style (|-)
#' regardless of whether they contain actual line breaks. Long strings are wrapped
#' at word boundaries to improve readability.
#' @param domain_data The metadata for a single domain
#' @param domain_name The name of the domain
#' @param output_dir Directory where the YAML file will be written
#' @param line_width Maximum line width before wrapping text (default: 80)
#' @return The path to the created YAML file
#' @export
write_adam_domain_yaml <- function(domain_data, domain_name, output_dir = ".", line_width = 80) {
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Process origin fields to ensure they're treated as multiline
  domain_data <- format_origin_fields(domain_data, line_width)

  # Convert to YAML string
  yaml_content <- yaml::as.yaml(domain_data, indent.mapping.sequence = TRUE)

  # Unquote flow-style dictionaries
  yaml_content <- gsub("[\'\"](\\{.*?\\})[\'\"]", "\\1", yaml_content)

  # Write to file
  yaml_file <- file.path(output_dir, paste0(tolower(domain_name), ".yaml"))
  writeLines(yaml_content, yaml_file)

  return(yaml_file)
}

#' Format origin fields to ensure they're treated as multiline strings
#' @description Helper function to format all origin fields in a domain metadata structure
#' @param metadata A domain metadata structure
#' @param line_width Maximum line width before wrapping text
#' @return The metadata structure with origin fields formatted for multiline output
#' @keywords internal
format_origin_fields <- function(metadata, line_width = 80) {
  # Helper function to wrap text at word boundaries
  wrap_text <- function(text, width) {
    if (is.null(text) || is.na(text)) return(text)

    # If text already has newlines, process each line separately
    if (grepl("\n", text)) {
      lines <- strsplit(text, "\n")[[1]]
      wrapped_lines <- sapply(lines, function(line) {
        wrap_text_line(line, width)
      })
      paste(wrapped_lines, collapse = "\n")
    } else {
      wrap_text_line(text, width)
    }
  }

  # Helper function to wrap a single line of text
  wrap_text_line <- function(line, width) {
    if (nchar(line) <= width) return(line)

    words <- strsplit(line, " ")[[1]]
    result <- ""
    current_line <- ""

    for (word in words) {
      if (nchar(current_line) + nchar(word) + 1 <= width) {
        # Add word to current line
        if (current_line == "") {
          current_line <- word
        } else {
          current_line <- paste(current_line, word)
        }
      } else {
        # Start a new line
        if (result == "") {
          result <- current_line
        } else {
          result <- paste0(result, "\n", current_line)
        }
        current_line <- word
      }
    }

    # Add the last line
    if (current_line != "") {
      if (result == "") {
        result <- current_line
      } else {
        result <- paste0(result, "\n", current_line)
      }
    }

    result
  }

  # Process origin fields in column_metadata
  if (!is.null(metadata$column_metadata)) {
    for (i in seq_along(metadata$column_metadata)) {
      if (!is.null(metadata$column_metadata[[i]]$origin)) {
        # Format the origin text
        origin_text <- metadata$column_metadata[[i]]$origin

        # Wrap long lines
        origin_text <- wrap_text(origin_text, line_width)

        # Ensure it has at least one newline to trigger multiline formatting
        if (!grepl("\n", origin_text)) {
          origin_text <- paste0(origin_text, "\n")
        }

        # Update the origin field
        metadata$column_metadata[[i]]$origin <- origin_text
      }
    }
  }

  # Process origin fields in value_metadata
  if (!is.null(metadata$value_metadata)) {
    for (i in seq_along(metadata$value_metadata)) {
      if (!is.null(metadata$value_metadata[[i]]$origin)) {
        # Format the origin text
        origin_text <- metadata$value_metadata[[i]]$origin

        # Wrap long lines
        origin_text <- wrap_text(origin_text, line_width)

        # Ensure it has at least one newline to trigger multiline formatting
        if (!grepl("\n", origin_text)) {
          origin_text <- paste0(origin_text, "\n")
        }

        # Update the origin field
        metadata$value_metadata[[i]]$origin <- origin_text
      }
    }
  }

  return(metadata)
}

#' Write all ADaM metadata domains to YAML files
#' @description Writes all domains in an ADaM metadata structure to individual YAML files.
#' @param adam_metadata A nested list structure containing ADaM metadata organized by dataset
#' @param output_dir Directory where YAML files will be written
#' @param line_width Maximum line width before wrapping text (default: 80)
#' @return Character vector of created YAML file paths
#' @export
write_adam_yaml <- function(adam_metadata, output_dir = ".", line_width = 80) {
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Write each domain to its own YAML file using write_adam_domain_yaml
  yaml_files <- purrr::imap_chr(adam_metadata, function(domain_data, domain_name) {
    write_adam_domain_yaml(domain_data, domain_name, output_dir, line_width)
  })

  message("Created ", length(yaml_files), " YAML files in ", output_dir)
  return(yaml_files)
}
