#' Process metadata for a single table
#'
#' @param table_name Character string specifying the table name to process
#' @param source_tables Data frame containing table-level metadata
#' @param source_columns Data frame containing column-level metadata
#' @param source_values Data frame containing value-level metadata
#' @param valid_classes Character vector of valid class names
#' @param valid_subclasses Character vector of valid subclass names
#' @param verbose Logical indicating whether to print processing messages
#'
#' @return A list containing processed metadata with components:
#'   \item{table_metadata}{List of table-level metadata}
#'   \item{column_metadata}{List of column-level metadata}
#'   \item{value_metadata}{List of value-level metadata (if applicable)}
#'
#' @noRd
process_table <- function(table_name,
                          source_tables,
                          source_columns,
                          source_values,
                          valid_classes,
                          valid_subclasses,
                          verbose) {
  # Build table_metadata - check for column existence before selecting
  available_cols <- names(source_tables)
  table_cols <- c("table", "label", "class", "structure", "keys", "comment")

  # Add subclass only if it exists
  if ("subclass" %in% available_cols) {
    table_cols <- c(table_cols, "subclass")
  }

  table_meta <- source_tables |>
    dplyr::filter(table == table_name) |>
    dplyr::select(dplyr::any_of(table_cols)) |>
    dplyr::rename(id = table)

  # Add class handling
  if ("class" %in% names(table_meta)) {
    table_meta <- table_meta |>
      dplyr::mutate(class = dplyr::if_else(class %in% valid_classes, class, "ADAM OTHER"))
  }

  # Add subclass handling only if it exists
  if ("subclass" %in% names(table_meta)) {
    table_meta <- table_meta |>
      dplyr::mutate(subclass = dplyr::if_else(subclass %in% valid_subclasses, subclass, NA_character_))
  }

  # Format keys as [KEY1, KEY2, ...] if the column exists
  if ("keys" %in% names(table_meta)) {
    table_meta <- table_meta |>
      dplyr::mutate(keys = paste0("[", gsub("[, ] *", ", ", keys), "]"))
  }

  # Convert to list and clean
  table_meta <- table_meta |>
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

      # Create unified origin field based
      unified_origin = dplyr::case_when(
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
    # Get rid of floating point issue with displayformat decimals
    dplyr::mutate(
      ndigits = nchar(gsub("^\\d+\\.", "", displayformat)),
      displayformatn = dplyr::case_when(grepl("^\\d+", displayformat) ~ displayformat,
                                        TRUE ~ "0"),
      displayformatn = as.double(.data$displayformatn),
      displayformatr = dplyr::case_when(
        grepl("^\\d+\\.\\d+$", displayformatn) ~ round(displayformatn, ndigits - 1),
        TRUE ~ displayformatn
      )
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      displayformatf = dplyr::case_when(
        grepl("^\\d+", displayformat) & isTRUE(all.equal(displayformatn, displayformatr)) ~
          as.character(displayformatr),
        TRUE ~ displayformat
      )
    ) |>
    dplyr::ungroup() |>
    # Create a flow-style dictionary of formatting information.
    dplyr::mutate(
      type = dplyr::case_when(type == "C" ~ "text",
                              type == "N" & grepl("^datetime", displayformat) ~ "datetime",
                              type == "N" & grepl("^date", displayformat) ~ "date",
                              type == "N" & grepl("^time", displayformat) ~ "time",
                              type == "N" ~ "float",
                              TRUE ~ type),
      dtype = ifelse(!is.na(type), paste0('type: "', type, '"'), NA_character_),
      dlength = ifelse(!is.na(length), paste0("length: ", length), NA_character_),
      ddisplayformat = ifelse(!is.na(displayformat),
                              paste0('displayformat: "', .data$displayformatf, '"'),
                              NA_character_)
    ) |>
    tidyr::unite(format, dtype, dlength, sep = ", ", ddisplayformat, na.rm = TRUE) |>
    dplyr::mutate(format = paste0("{", format, "}"))

  # Print messages for complex predecessors converted to derived
  if (verbose) {
    complex_preds <-  col_data |>
      dplyr::filter(is_complex_predecessor) |>
      dplyr::select(column, origindescription)

    if (nrow(complex_preds) > 0) {
      for (i in seq_len(nrow(complex_preds))) {
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

    method_text <- row$unified_origin
    if (!is.na(method_text)) {
      # Standardize newlines
      method_text <- gsub("\r\n", "\n", method_text)
    }

    if (row$is_predecessor && !row$is_renamed && row$is_adam_predecessor) {
      # For predecessor columns that aren't renamed, only include the column field
      # This follows CDISC requirements that predecessor columns inherit metadata from parent
      list(id = row$column,
           method = method_text)
    } else if (row$is_renamed && row$is_adam_predecessor) {
      # For renamed predecessor columns, include column and source
      list(
        id = row$column,
        label = row$label,
        method = method_text
      )
    } else if (row$is_predecessor && !row$is_renamed && !row$is_adam_predecessor) {
      # For predecessor columns that aren't renamed, only include the column field
      # This follows CDISC requirements that predecessor columns inherit metadata from parent
      list(id = row$column,
           label = row$label,
           format = row$format,
           method = method_text,
           core = row$corefl == "Y")
    } else if (row$is_renamed && !row$is_adam_predecessor) {
      # For renamed predecessor columns, include column and source
      list(
        id = row$column,
        label = row$label,
        format = row$format,
        method = method_text,
        core = row$corefl == "Y"
      )
    } else if (row$is_complex_predecessor) {
      # For complex predecessors (now treated as derived)
      list(
        id = row$column,
        label = row$label,
        format = row$format,
        codelist = row$xmlcodelist,
        method = method_text,
        core = row$corefl == "Y"
      )
    } else {
      # For derived/assigned columns, include all relevant metadata
      list(
        id = row$column,
        label = row$label,
        format = row$format,
        codelist = row$xmlcodelist,
        method = method_text,
        core = row$corefl == "Y"
      )
    }
  }) |>
    clean_list()

  # Build value_metadata - only if data exists for this table
  val_filtered <- source_values |> dplyr::filter(table == table_name)

  val_list <- process_values(val_filtered, table_name, verbose)
  val_meta <- val_list[[1]]

  # Build referenced_domains to track predecessor relationships
  # This helps with define.xml generation by documenting source domains

  # Return the complete table metadata structure
  result <- list(
    table_metadata = table_meta,
    column_metadata = col_meta
  )

  # Add value_metadata only if it exists
  if (length(val_meta) > 0) {
    result$value_metadata <-  val_meta
  }

  result
}
