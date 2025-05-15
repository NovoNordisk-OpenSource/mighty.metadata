extract_references <- function(col_data, val_data, val_filtered) {
  # 1. Extract direct references from simple predecessors
  direct_refs <-  list()

  # From column metadata
  predecessor_cols <- col_data |>
    dplyr::filter(is_predecessor) |>
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
  renamed_cols <- col_data |>
    dplyr::filter(!is.na(source)) |>
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

  # Check if any domains are missing
  missing_domains <- predecessor_cols |>
    rbind(renamed_cols) |>
    dplyr::select(domain, variable) |>
    dplyr::filter(is.na(domain)) |>
    dplyr::pull(variable) |>
    paste(collapse = ", ")

  if (missing_domains != "") {
    warning("Warning in table ", table_name,
            ": Missing precessor domain for variables: ", missing_domains)
  }

  # 2. Extract references from method text in both column and value metadata
  method_refs <- list()

  # From column metadata methods
  col_methods <- col_data |>
    dplyr::filter(!is.na(method)) |>
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
    val_methods <-  val_data |>
      dplyr::filter(!is.na(method)) |>
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

  return(referenced_domains)

}

