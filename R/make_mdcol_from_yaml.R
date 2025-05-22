
make_mdcol_from_yaml <- function(metadata_directory,
                                 db,
                                 export_formats = c("parquet", "sas7bdat"),
                                 export = TRUE) {

  # Find all yaml files in metadata directory
  all_names <- list.files(metadata_directory) |>
    stringr::str_remove("\\.yaml$")

  # Convert all yaml files to lists
  all_lists <- purrr::map(all_names, \(name) {
    yaml::read_yaml(file.path(metadata_directory, paste0(name, ".yaml")))
  }) |>
    purrr::set_names(all_names)


  all_tbl <- purrr::map2(all_lists, names(all_lists), \(list, name) {

    # Extract table information for each table
    table_tbl <- dplyr::bind_rows(list$table_metadata) |>
      dplyr::select(table, keys, tlabel = label)

    # Extract column information for each table and flatten format information
    column_tbl <- lapply(list$column_metadata, purrr::flatten) |>
      dplyr::bind_rows() |>
      dplyr::select(any_of(c("column", "label", "source", "method", "type", "corefl",
                             "length", "displayformat")))

    # Combine table and column information
    table_tbl |>
      tidyr::expand_grid(column_tbl) |>
      dplyr::mutate(order = dplyr::row_number())
  }) |>
    # Combine information for all tables into a single dataframe
    dplyr::bind_rows() |>
    # Extract source information for each column where appropriate
    dplyr::mutate(source = ifelse(stringr::str_detect(column, "[A-Z0-9]+\\.") & is.na(source), column, source),
                  column = stringr::str_remove(column, "[A-Z0-9]+\\.")) |>
    # Use upper case column names to align with SAS
    dplyr::rename_with(toupper) |>
    # Split source information into source table and source column
    dplyr::mutate(SOURCE = stringr::str_split(SOURCE, "\\.")) |>
    tidyr::unnest_wider(SOURCE, names_sep = "_") |>
    dplyr::rename(STABLE = SOURCE_1, SCOLUMN = SOURCE_2)

  # Add label and format information where appropriate. NB: Not recursively.
  upd_tbl <- all_tbl |>
    dplyr::filter(is.na(LABEL)) |>
    dplyr::select(-LABEL, -TYPE, -LENGTH, -DISPLAYFORMAT) |>
    dplyr::left_join(all_tbl |>
                       dplyr::filter(!is.na(LABEL)) |>
                       dplyr::distinct(SCOLUMN = COLUMN, LABEL, STABLE = TABLE,
                                       TYPE, LENGTH, DISPLAYFORMAT),
                     by = c("STABLE", "SCOLUMN")) |>
    dplyr::bind_rows(all_tbl |>
                       dplyr::filter(!is.na(LABEL))) |>
    dplyr::arrange(TABLE, ORDER) |>
    dplyr::select(-STABLE, -SCOLUMN) |>
    dplyr::rename(FORMAT = DISPLAYFORMAT)

  # write to whale ------------------------------------------------------
  if (export) {
    purrr::walk(export_formats, function(format) {
      db$metadata(
        dataset_name = paste0("mdcol.", format),
        dataset = upd_tbl,
        ext = "derived"
      )
    })
  }

  invisible(upd_tbl)

}

