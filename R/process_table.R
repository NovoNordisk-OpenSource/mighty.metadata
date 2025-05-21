# Function to process a single table
process_table <- function(table_name,
                          source_tables,
                          source_columns,
                          source_values,
                          valid_classes,
                          valid_subclasses,
                          verbose) {
  # Build table_metadata - check for column existence before selecting
  available_cols <- names(source_tables)
  table_cols <- c("table", "label", "class", "structure", "keys", "comment", "chkalias")

  # Add subclass only if it exists
  if ("subclass" %in% available_cols) {
    table_cols <- c(table_cols, "subclass")
  }

  # Only select columns that exist
  select_cols <- intersect(table_cols, available_cols)

  table_meta <- source_tables |>
    dplyr::filter(table == table_name) |>
    dplyr::select(dplyr::all_of(select_cols))

  # Add class handling
  if ("class" %in% names(table_meta)) {
    table_meta <-  table_meta |>
      dplyr::mutate(class = dplyr::if_else(class %in% valid_classes, class, "ADAM OTHER"))
  }

  # Add subclass handling only if it exists
  if ("subclass" %in% names(table_meta)) {
    table_meta <-  table_meta |>
      dplyr::mutate(subclass = dplyr::if_else(subclass %in% valid_subclasses, subclass, NA_character_))
  }

  # Split keys if the column exists
  if ("keys" %in% names(table_meta)) {
    table_meta <-  table_meta |>
      dplyr::mutate(keys = unlist(strsplit(keys, ",")))
  }

  # Convert to list and clean
  table_meta <-  table_meta |>
    as.list() |>
    clean_list()

  # Process column metadata

  col_data <-  source_columns |>
    dplyr::filter(table == table_name) |>
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

      # Flag for ADaM predecessor columns
      is_adam_predecessor = is_predecessor &
        grepl("^AD[A-Z][A-Z0-9]+\\.[A-Za-z0-9_]+", origindescription),

      # For predecessor variables, use the full domain.variable reference if available
      column_final = dplyr::case_when(
        is_predecessor & !is_renamed & grepl("^[A-Z]+\\.[A-Z]+", origindescription) ~ origindescription,
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
        !is.na(origin) & tolower(origin) == "derived" & !is.na(algorithm) ~ paste0("Derived: ", algorithm),
        !is.na(origin) & tolower(origin) == "assigned" & !is.na(comment) ~ paste0("Assigned: ", comment),
        TRUE ~ NA_character_
      ),

      # Set origin to derived for complex predecessors
      origin_final = dplyr::case_when(
        is_complex_predecessor ~ "derived",
        TRUE ~ origin
      )
    ) |>
    # Create a flow-style dictionary of formatting information.
    dplyr::mutate(dtype = if_else(!is.na(type), paste0('type: "', type, '"'), NA_character_),
                  dlength = if_else(!is.na(length), paste0('length: ', length), NA_character_),
                  ddisplayformat = if_else(!is.na(displayformat), paste0('displayformat: "', displayformat, '"'), NA_character_)) |>
    tidyr::unite(format, dtype, dlength, sep = ", ", ddisplayformat, na.rm = TRUE) |>
    dplyr::mutate(format = paste0("{", format, "}"))

  # Print messages for complex predecessors converted to derived
  if (verbose) {
    complex_preds <-  col_data |>
      dplyr::filter(is_complex_predecessor) |>
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

  # TODO: This can be cleaned up considerably
  # TODO: The listify-function could be pulled out.

  # Create column metadata list with appropriate fields based on type
  col_meta <-  lapply(seq_len(nrow(col_data)), function(i) {
    row <- col_data[i, ]

    if (row$is_predecessor && !row$is_renamed && row$is_adam_predecessor) {
      # For predecessor columns that aren't renamed, only include the column field
      # This follows CDISC requirements that predecessor columns inherit metadata from parent
      list(column = row$column_final)
    } else if (row$is_renamed && row$is_adam_predecessor) {
      # For renamed predecessor columns, include column and source
      list(
        column = row$column_final,
        source = row$source
      )
    } else if (row$is_predecessor && !row$is_renamed && !row$is_adam_predecessor) {
      # For predecessor columns that aren't renamed, only include the column field
      # This follows CDISC requirements that predecessor columns inherit metadata from parent
      list(column = row$column_final,
           label = row$label,
           format = row$format)
    } else if (row$is_renamed && !row$is_adam_predecessor) {
      # For renamed predecessor columns, include column and source
      list(
        column = row$column_final,
        label = row$label,
        format = row$format,
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
        format = row$format,
        xmlcodelist = row$xmlcodelist,
        method = method_text
      ) |> clean_list()
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
        format = row$format,
        xmlcodelist = row$xmlcodelist,
        method = method_text
      ) |> clean_list()
    }
  })

  # Build value_metadata - only if data exists for this table
  val_filtered <- source_values |> dplyr::filter(table == table_name)

  val_list <- process_values(val_filtered, table_name, verbose)
  val_meta <- val_list[[1]]
  val_data <- val_list[[2]]

  # Build referenced_domains to track predecessor relationships
  # This helps with define.xml generation by documenting source domains

  referenced_domains <- extract_references(col_data, val_data, val_filtered, table_name)

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
