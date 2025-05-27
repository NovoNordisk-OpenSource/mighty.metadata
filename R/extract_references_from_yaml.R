#' Extract Domain References from YAML Metadata File
#'
#' @description
#' Analyzes a YAML metadata file to extract all domain and variable references from
#' column sources and origins. This function helps track dependencies between
#' different domains and variables in the metadata structure.
#'
#' @param path Character string specifying the file path to the YAML metadata file.
#'
#' @return A named list where:
#' \itemize{
#'   \item Names are the referenced domains
#'   \item Values are lists of variables referenced from each domain
#' }
#'
#' @details
#' The function processes references from multiple sources:
#' 1. Direct references in column names or source attributes
#' 2. References embedded in origin descriptions
#' 3. References in value-level metadata
#'
#' References are expected to be in the format "DOMAIN.VARIABLE" (e.g., "ADSL.USUBJID").
#' The function handles both simple references and complex patterns within origin
#' descriptions.
#'
#' Special handling includes:
#' * Filtering out generic dataset references (SDTM, ADM, ADAM, METADATA)
#' * Processing extended references (e.g., SDTM.FA.FALNKID)
#' * Handling value-level metadata with where clauses
#'
#' @note
#' The function will generate a warning if it encounters incomplete source or origin
#' references (missing domain or variable components).
#'
#' @examples
#' \dontrun{
#' # Extract references from a metadata YAML file
#' references <- extract_references_from_yaml("path/to/metadata.yaml")
#'
#' # Example output structure:
#' # list(
#' #   "AE" = c("USUBJID", "STUDYID"),
#' #   "ADSL" = c("TRT01A", "TRT01AN")
#' # )
#' }
#'
#' @importFrom yaml read_yaml
#' @importFrom dplyr bind_rows mutate filter rename distinct group_by summarise
#' @importFrom tidyr unnest_wider unnest_longer
#' @importFrom stringr str_extract str_extract_all str_split
#' @importFrom purrr flatten set_names
#'
#' @export
extract_references_from_yaml <- function(path) {

  list_in <- yaml::read_yaml(path)

  table_name <- list_in$table_metadata$table

  # Load column information and transform to dataframe
  column_data <- lapply(list_in$column_metadata, purrr::flatten) |>
    dplyr::bind_rows()

  # Load value information and transform to dataframe
  value_data <- list_in$value_metadata |>
    dplyr::bind_rows()

  if ("column" %in% colnames(value_data) & "whereclause" %in% colnames(value_data)) {
    value_data <- value_data |>
      mutate(column = paste0(column, " (", whereclause, ")"))
  }

  # Pattern to match uppercase domain.column references
  # This looks for uppercase letters/numbers followed by a period and more uppercase letters/numbers
  pattern <- "\\b([A-Z][A-Z0-9]+\\.)?[A-Z][A-Z0-9]+\\.[A-Z][A-Z0-9]+\\b"

  # Extract domain-value pairs from direct references in column or source
  direct_columns <- column_data |>
    dplyr::mutate(source2 = dplyr::case_when(!is.na(source) ~ source,
                                             grepl(pattern, column) ~ column)) |>
    dplyr::filter(!is.na(source2)) |>
    dplyr::mutate(source2 = stringr::str_split(source2, "\\.")) |>
    tidyr::unnest_wider(source2, names_sep = "_") |>
    dplyr::rename(domain = source2_1, variable = source2_2)

  # Extract domain-value pairs from references in column or value origin
  origin_columNs <- column_data |>
    bind_rows(value_data) |>
    dplyr::filter(!is.na(origin)) |>
    # Extract everything in origin that looks like a domain.variable reference
    dplyr::mutate(origin_source = stringr::str_extract_all(origin, pattern)) |>
    tidyr::unnest_longer(origin_source) |>
    # If it is an extended reference, e.g. SDTM.FA.FALNKID, only keep the last bit
    # Pull out the domain and variable in seperate columns
    dplyr::mutate(origin_source = stringr::str_extract(origin_source, "[A-Z][A-Z0-9]+\\.[A-Z][A-Z0-9]+$"),
                  origin_source = stringr::str_split(origin_source, "\\.")) |>
    tidyr::unnest_wider(origin_source, names_sep = "_") |>
    dplyr::rename(domain = origin_source_1, variable = origin_source_2) |>
    # Remove any left-over dataset references
    dplyr::filter(!domain %in% c("SDTM", "ADM", "ADAM", "METADATA"))

  all_columns <- direct_columns |>
    dplyr::bind_rows(origin_columNs)

  # Find
  incomplete_source <- all_columns |>
    dplyr::filter(is.na(domain) | is.na(variable)) |>
    dplyr::pull(column) |>
    paste(collapse = ", ")

  if (incomplete_source != "") {
    warning("Warning in table ", table_name,
            ": Incomplete source/origin for variables: ", incomplete_source)
  }

  domain_variable <- all_columns |>
    # Keep only unique domain-variable pairs
    dplyr::distinct(domain, variable) |>
    # Transform dataframe into a list
    dplyr::group_by(domain) |>
    dplyr::summarise(variable = list(variable))

  referenced_domains <- domain_variable$variable |>
    purrr::set_names(domain_variable$domain)

  return(referenced_domains)
}

