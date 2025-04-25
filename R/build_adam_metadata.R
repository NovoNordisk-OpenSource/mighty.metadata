# Functions for building ADaM metadata

#' Build ADaM metadata structure from source metadata components
#' @description Transforms raw ADaM metadata components into a structured format suitable for YAML output.
#' @details
#' The function produces a clean YAML-compatible structure with the following behaviors:
#'
#' Column handling by type:
#' - For predecessor variables (origin = "Predecessor"):
#'   - If not renamed: Only the column field is included (e.g., "DM.USUBJID")
#'     This follows CDISC requirements that predecessor columns inherit metadata from parent
#'   - If renamed: Only column and source fields are included
#'     Example: column: AAGE, source: DM.AGE
#'   - If origindescription is complex (contains filtering or additional text):
#'     Converted to derived column with origindescription as method
#'
#' - For derived variables (origin = "Derived"):
#'   - Includes column, label, xmlcodelist (if applicable), and method fields
#'   - Method contains the algorithm text
#'
#' - For assigned variables (origin = "Assigned"):
#'   - Includes column, label, xmlcodelist (if applicable), and method fields
#'   - Method is formatted as "Assigned: [comment]"
#'
#' Additional features:
#' - NULL/NA fields are omitted from the output for cleaner YAML
#' - Value-level metadata is included only if available for the dataset
#' - Referenced domains are automatically created to track predecessor relationships
#'   from both direct references and method text
#' - Method fields are formatted for multi-line text in YAML
#' - Parameter value level metadata is properly processed and linked to parent variables
#' @param metadata A list containing source_tables, source_columns, and source_values components
#' @param verbose Logical indicating whether to print messages about conversions (default: TRUE)
#' @return A nested list structure containing ADaM metadata organized by dataset
#' @export
build_adam_metadata <-  function(metadata, verbose = TRUE) {
  valid_classes <- c("SUBJECT LEVEL ANALYSIS DATASET", "BASIC DATA STRUCTURE", "OCCURRENCE DATA STRUCTURE")
  valid_subclasses <- c("ADVERSE EVENT", "TIME-TO-EVENT")

  # Check if metadata has expected structure
  required_components <- c("source_tables", "source_columns", "source_values")
  missing_components <- setdiff(required_components, names(metadata))
  if (length(missing_components) > 0) {
    stop("Missing required components: ", paste(missing_components, collapse = ", "))
  }

  # Extract source data with error handling
  source_tables <-  tryCatch(
    metadata$source_tables %>% dplyr::rename_all(tolower),
    error = function(e) stop("Error processing source_tables: ", e$message)
  )

  source_columns <-  tryCatch(
    metadata$source_columns %>% dplyr::rename_all(tolower),
    error = function(e) stop("Error processing source_columns: ", e$message)
  )

  source_values <-  tryCatch(
    metadata$source_values %>% dplyr::rename_all(tolower),
    error = function(e) stop("Error processing source_values: ", e$message)
  )

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

  # Function to process a single table
  process_table <- function(table_name) {
    # Build table_metadata - check for column existence before selecting
    available_cols <- names(source_tables)
    table_cols <- c("table", "label", "class", "structure", "keys", "comment", "chkalias")

    # Add subclass only if it exists
    if ("subclass" %in% available_cols) {
      table_cols <- c(table_cols, "subclass")
    }

    # Only select columns that exist
    select_cols <- intersect(table_cols, available_cols)

    table_meta <- source_tables %>%
      dplyr::filter(table == table_name) %>%
      dplyr::select(dplyr::all_of(select_cols))

    # Add class handling
    if ("class" %in% names(table_meta)) {
      table_meta <-  table_meta %>%
        dplyr::mutate(class = dplyr::if_else(class %in% valid_classes, class, "ADAM OTHER"))
    }

    # Add subclass handling only if it exists
    if ("subclass" %in% names(table_meta)) {
      table_meta <-  table_meta %>%
        dplyr::mutate(subclass = dplyr::if_else(subclass %in% valid_subclasses, subclass, NA_character_))
    }

    # Split keys if the column exists
    if ("keys" %in% names(table_meta)) {
      table_meta <-  table_meta %>%
        dplyr::mutate(keys = strsplit(keys, ","))
    }

    # Convert to list and clean
    table_meta <-  table_meta %>%
      as.list() %>%
      clean_list()

    # Process column metadata
    col_data <-  source_columns %>%
      dplyr::filter(table == table_name) %>%
      dplyr::mutate(
        # Clean column names by removing trailing periods
        column = gsub("\\s*\\.\\s*$", "", column),

        # Clean origindescription by removing trailing periods
        origindescription = gsub("\\s*\\.\\s*$", "", origindescription),

        # Check if origindescription is complex (not a simple Dataset.Column format)
        is_complex_predecessor = !is.na(origin) &
          tolower(origin) == "predecessor" &
          !is_simple_predecessor(origindescription),

        # Flag for predecessor columns (only simple ones now)
        is_predecessor = !is.na(origin) &
          tolower(origin) == "predecessor" &
          !is_complex_predecessor,

        # Flag for renamed predecessor columns (when source column name differs from target)
        is_renamed = is_predecessor &
          grepl("^[A-Z]+\\.[A-Z]+", origindescription) &
          column != sub("^[A-Z]+\\.", "", origindescription),

        # For predecessor variables, use the full domain.variable reference if available
        column_final = dplyr::case_when(
          is_predecessor & grepl("^[A-Z]+\\.[A-Z]+", origindescription) ~ origindescription,
          TRUE ~ column
        ),

        # Only include source for renamed predecessor columns
        source = dplyr::case_when(
          is_renamed ~ origindescription,
          TRUE ~ NA_character_
        ),

        # Create unified method field based on origin
        method = dplyr::case_when(
          is_complex_predecessor ~ paste0("Source: ", origindescription),
          is_predecessor ~ paste0("Predecessor: ", origindescription),
          !is.na(origin) & tolower(origin) == "derived" & !is.na(algorithm) ~ algorithm,
          !is.na(origin) & tolower(origin) == "assigned" & !is.na(comment) ~ paste0("Assigned: ", comment),
          TRUE ~ NA_character_
        ),

        # Set origin to derived for complex predecessors
        origin_final = dplyr::case_when(
          is_complex_predecessor ~ "derived",
          TRUE ~ origin
        )
      )

    # Print messages for complex predecessors converted to derived
    if (verbose) {
      complex_preds <-  col_data %>%
        dplyr::filter(is_complex_predecessor) %>%
        dplyr::select(column, origindescription)

      if (nrow(complex_preds) > 0) {
        for (i in 1:nrow(complex_preds)) {
          message(paste0("Converting column '", complex_preds$column[i],
                         "' in table '", table_name,
                         "' from predecessor to derived due to complex origindescription: '",
                         complex_preds$origindescription[i], "'"))
        }
      }
    }

    # Create column metadata list with appropriate fields based on type
    col_meta <-  lapply(seq_len(nrow(col_data)), function(i) {
      row <- col_data[i, ]

      if (row$is_predecessor && !row$is_renamed) {
        # For predecessor columns that aren't renamed, only include the column field
        # This follows CDISC requirements that predecessor columns inherit metadata from parent
        list(column = row$column_final)
      } else if (row$is_renamed) {
        # For renamed predecessor columns, include column and source
        list(
          column = row$column_final,
          source = row$source
        )
      } else if (row$is_complex_predecessor) {
        # For complex predecessors (now treated as derived)
        method_text <- row$method
        if (!is.na(method_text)) {
          # Standardize newlines
          method_text <- gsub("\r\n", "\n", method_text)
        }

        list(
          column = row$column,
          label = row$label,
          xmlcodelist = row$xmlcodelist,
          method = method_text
        ) %>% clean_list()
      } else {
        # For derived/assigned columns, include all relevant metadata
        method_text <-  row$method
        if (!is.na(method_text)) {
          # Standardize newlines
          method_text <- gsub("\r\n", "\n", method_text)
        }

        list(
          column = row$column_final,
          label = row$label,
          xmlcodelist = row$xmlcodelist,
          method = method_text
        ) %>% clean_list()
      }
    })

    # Build value_metadata - only if data exists for this table
    val_filtered <-  source_values %>% dplyr::filter(table == table_name)

    if (nrow(val_filtered) > 0) {
      # Process value-level metadata similar to column metadata
      val_data <-  val_filtered %>%
        dplyr::mutate(
          # Clean column names by removing trailing periods
          column = gsub("\\s*\\.\\s*$", "", column),

          # Clean whereclause
          whereclause = gsub("\\s*\\.\\s*$", "", whereclause),

          # Check if origindescription is complex
          is_complex_predecessor = !is.na(origin) &
            tolower(origin) == "predecessor" &
            !is_simple_predecessor(origindescription),

          # Create method field using the same logic as for columns
          method = dplyr::case_when(
            is_complex_predecessor ~ paste0("Source: ", origindescription),
            !is.na(origin) & tolower(origin) == "predecessor" ~ paste0("Predecessor: ", origindescription),
            !is.na(origin) & tolower(origin) == "derived" & !is.na(algorithm) ~ algorithm,
            !is.na(origin) & tolower(origin) == "assigned" & !is.na(comment) ~ paste0("Assigned: ", comment),
            TRUE ~ NA_character_
          ),

          # Set origin to derived for complex predecessors
          origin_final = dplyr::case_when(
            is_complex_predecessor ~ "derived",
            TRUE ~ origin
          )
        )

      # Print messages for complex predecessors in value metadata
      if (verbose) {
        complex_preds <-  val_data %>%
          dplyr::filter(is_complex_predecessor) %>%
          dplyr::select(column, whereclause, origindescription)

        if (nrow(complex_preds) > 0) {
          for (i in 1:nrow(complex_preds)) {
            message(paste0("Converting value metadata for column '", complex_preds$column[i],
                           "' with where clause '", complex_preds$whereclause[i],
                           "' in table '", table_name,
                           "' from predecessor to derived due to complex origindescription: '",
                           complex_preds$origindescription[i], "'"))
          }
        }
      }

      val_meta <-  lapply(seq_len(nrow(val_data)), function(i) {
        row <- val_data[i, ]

        method_text <- row$method
        if (!is.na(method_text)) {
          # Standardize newlines
          method_text <- gsub("\r\n", "\n", method_text)
        }

        result <- list(
          column = row$column,
          whereclause = row$whereclause,
          method = method_text
        )

        # Add origin for complex predecessors
        if (row$is_complex_predecessor) {
          result$origin <- "derived"
          result$derivation_type <- "assigned"
        }

        clean_list(result)
      })
    } else {
      val_meta <- list() # Empty list if no value metadata exists
    }

    # Build referenced_domains to track predecessor relationships
    # This helps with define.xml generation by documenting source domains

    # 1. Extract direct references from simple predecessors
    direct_refs <-  list()

    # From column metadata
    predecessor_cols <- col_data %>%
      dplyr::filter(is_predecessor) %>%
      dplyr::mutate(
        domain = stringr::str_extract(origindescription, "^[^.]+"),
        variable = column
      )

    if (nrow(predecessor_cols) > 0) {
      for (i in 1:nrow(predecessor_cols)) {
        domain <-  predecessor_cols$domain[i]
        variable <- predecessor_cols$variable[i]

        if (is.null(direct_refs[[domain]])) {
          direct_refs[[domain]] <- c()
        }
        direct_refs[[domain]] <- c(direct_refs[[domain]], variable)
      }
    }

    # From renamed columns with source field
    renamed_cols <- col_data %>%
      dplyr::filter(!is.na(source)) %>%
      dplyr::mutate(
        domain = stringr::str_extract(source, "^[^.]+"),
        variable = column
      )

    if (nrow(renamed_cols) > 0) {
      for (i in 1:nrow(renamed_cols)) {
        domain <-  renamed_cols$domain[i]
        variable <- renamed_cols$variable[i]

        if (is.null(direct_refs[[domain]])) {
          direct_refs[[domain]] <- c()
        }
        direct_refs[[domain]] <- c(direct_refs[[domain]], variable)
      }
    }

    # 2. Extract references from method text in both column and value metadata
    method_refs <- list()

    # From column metadata methods
    col_methods <- col_data %>%
      dplyr::filter(!is.na(method)) %>%
      dplyr::select(column, method)

    if (nrow(col_methods) > 0) {
      for (i in 1:nrow(col_methods)) {
        method_text <-  col_methods$method[i]
        column_name <- col_methods$column[i]

        # Extract domains referenced in the method
        domains <- extract_domain_references(method_text)

        for (domain in domains) {
          if (is.null(method_refs[[domain]])) {
            method_refs[[domain]] <- c()
          }
          method_refs[[domain]] <- c(method_refs[[domain]], column_name)
        }
      }
    }

    # From value metadata methods
    if (nrow(val_filtered) > 0) {
      val_methods <-  val_data %>%
        dplyr::filter(!is.na(method)) %>%
        dplyr::select(column, whereclause, method)

      if (nrow(val_methods) > 0) {
        for (i in 1:nrow(val_methods)) {
          method_text <-  val_methods$method[i]
          column_name <- val_methods$column[i]
          where_clause <- val_methods$whereclause[i]

          # Extract domains referenced in the method
          domains <- extract_domain_references(method_text)

          for (domain in domains) {
            if (is.null(method_refs[[domain]])) {
              method_refs[[domain]] <- c()
            }
            # For value metadata, include both column and whereclause
            var_desc <- paste0(column_name, " (", where_clause, ")")
            method_refs[[domain]] <- c(method_refs[[domain]], var_desc)
          }
        }
      }
    }

    # 3. Combine direct and method references
    all_domains <- unique(c(names(direct_refs), names(method_refs)))

    referenced_domains <- lapply(all_domains, function(domain) {
      vars <- c()
      if (!is.null(direct_refs[[domain]])) {
        vars <- c(vars, direct_refs[[domain]])
      }
      if (!is.null(method_refs[[domain]])) {
        vars <- c(vars, method_refs[[domain]])
      }

      list(
        domain = domain,
        variables = unique(vars)
      )
    })

    # Return the complete table metadata structure
    result <- list(
      table_metadata = table_meta,
      column_metadata = col_meta
    )

    # Add value_metadata only if it exists
    if (length(val_meta) > 0) {
      result$value_metadata <-  val_meta
    }

    # Add referenced_domains only if they exist
    if (length(referenced_domains) > 0) {
      result$referenced_domains <- referenced_domains
    }

    return(result)
  }

  # Process all tables
  tables <- unique(source_tables$table)
  result <- lapply(tables, process_table)
  names(result) <- tables

  return(result)
}
