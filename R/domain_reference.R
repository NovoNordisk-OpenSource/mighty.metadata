# Functions for extracting and building domain references

#' Extract domain references from text
#' @description Extracts all references of the form DATASET.COLUMN from text
#' @param text Character vector containing text to search for domain references
#' @return Character vector of domain references
#' @export
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

#' Build referenced domains from metadata
#' @description Creates referenced_domains section by analyzing column metadata and methods
#' for references to other datasets
#' @param metadata List containing column_metadata with columns and methods
#' @param table_name Optional table name for filtering (if NULL, processes all tables)
#' @return List of referenced domains with their variables
#' @export
build_referenced_domains <- function(metadata, table_name = NULL) {
  if (is.null(metadata)) {
    stop("Metadata cannot be NULL")
  }

  # If table_name is provided, filter to just that table
  if (!is.null(table_name)) {
    if (!table_name %in% names(metadata)) {
      stop("Table '", table_name, "' not found in metadata")
    }
    tables_to_process <- table_name
  } else {
    tables_to_process <- names(metadata)
  }

  # Process each table
  result <- lapply(tables_to_process, function(current_table) {
    table_meta <- metadata[[current_table]]

    # Skip if no column metadata
    if (is.null(table_meta$column_metadata)) {
      return(NULL)
    }

    # Extract all columns that are direct references (simple predecessors)
    direct_refs <- list()
    for (col in table_meta$column_metadata) {
      # Check if this is a simple predecessor (column value contains a period)
      if (!is.null(col$column) && grepl("\\.", col$column)) {
        domain <- sub("\\..*", "", col$column)
        var_name <- sub(".*\\.", "", col$column)

        if (is.null(direct_refs[[domain]])) {
          direct_refs[[domain]] <- c()
        }
        direct_refs[[domain]] <- c(direct_refs[[domain]], var_name)
      }

      # Also check source field if it exists
      if (!is.null(col$source) && grepl("\\.", col$source)) {
        domain <- sub("\\..*", "", col$source)
        var_name <- col$column  # Use the target column name

        if (is.null(direct_refs[[domain]])) {
          direct_refs[[domain]] <- c()
        }
        direct_refs[[domain]] <- c(direct_refs[[domain]], var_name)
      }
    }

    # Extract references from method text
    method_refs <- list()
    for (col in table_meta$column_metadata) {
      if (!is.null(col$method)) {
        # Extract domains referenced in the method
        domains <- extract_domain_references(col$method)

        for (domain in domains) {
          if (is.null(method_refs[[domain]])) {
            method_refs[[domain]] <- c()
          }
          method_refs[[domain]] <- c(method_refs[[domain]], col$column)
        }
      }
    }

    # Also check value_metadata if it exists
    if (!is.null(table_meta$value_metadata)) {
      for (val in table_meta$value_metadata) {
        if (!is.null(val$method)) {
          # Extract domains referenced in the method
          domains <- extract_domain_references(val$method)

          for (domain in domains) {
            if (is.null(method_refs[[domain]])) {
              method_refs[[domain]] <- c()
            }
            # For value metadata, include both column and whereclause
            var_desc <- paste0(val$column, " (", val$whereclause, ")")
            method_refs[[domain]] <- c(method_refs[[domain]], var_desc)
          }
        }
      }
    }

    # Combine direct and method references
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

    # Return the referenced domains for this table
    if (length(referenced_domains) > 0) {
      return(referenced_domains)
    } else {
      return(NULL)
    }
  })

  # Name the results by table
  names(result) <-  tables_to_process

  # If processing a single table, return just that table's referenced domains
  if (length(tables_to_process) == 1) {
    return(result[[1]])
  } else {
    return(result)
  }
}

#' Update referenced domains in existing metadata
#' @description Updates or adds referenced_domains section in existing metadata by analyzing
#' column metadata and methods for references to other datasets
#' @param metadata List containing ADaM metadata structure
#' @param table_name Optional table name for filtering (if NULL, processes all tables)
#' @return Updated metadata with refreshed referenced_domains sections
#' @export
update_referenced_domains <- function(metadata, table_name = NULL) {
  if (is.null(metadata)) {
    stop("Metadata cannot be NULL")
  }

  # If table_name is provided, only process that table
  if (!is.null(table_name)) {
    if (!table_name %in% names(metadata)) {
      stop("Table '", table_name, "' not found in metadata")
    }
    tables_to_process <- table_name
  } else {
    tables_to_process <- names(metadata)
  }

  # Build referenced domains for each table
  ref_domains <- build_referenced_domains(metadata, table_name)

  # Update metadata with new referenced domains
  for (tbl in tables_to_process) {
    if (!is.null(table_name)) {
      # Single table mode
      if (!is.null(ref_domains) && length(ref_domains) > 0) {
        metadata[[tbl]]$referenced_domains <-  ref_domains
      } else {
        metadata[[tbl]]$referenced_domains <- NULL
      }
    } else {
      # Multi-table mode
      if (!is.null(ref_domains[[tbl]]) && length(ref_domains[[tbl]]) > 0) {
        metadata[[tbl]]$referenced_domains <- ref_domains[[tbl]]
      } else {
        metadata[[tbl]]$referenced_domains <- NULL
      }
    }
  }

  return(metadata)
}
