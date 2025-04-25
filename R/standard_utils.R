# Functions for standard paths and master file lookup

#' Path to the CDISC standards libraries
#' @description Returns the file path to the CDISC standards libraries
#' @param ... \character Additional path elements
#' @return A file path
#' @export
standard_path <- function(...) {
  file.path(
    NNremote::pDrive(),
    "general",
    "Standard_Program_Library",
    "cstGlobalLibrary",
    "v1.7",
    "standards",
    ...
  )
}

#' Lookup available CDISC standard versions
#' @description Returns a list of available versions for a specific CDISC standard
#' @param standard \character The standard to look up
#' @return A list of files
#' @export
master_lookup <- function(standard) {
  # Check that standard is one of the available standards
  stds <- c("adam","definexml","sdtm","ct","datasetjson","cdash")
  if (!standard %in% stds) {
    stop("Standard must be one of: ", paste(stds, collapse = ", "))
  }

  list.files(
    path = standard_path(),
    pattern = standard
  )
}

#' Read master metadata file
#' @description Reads a CDISC standard metadata file from the standard library
#' @param standard Standard name
#' @param version Version string
#' @param filename Filename
#' @return Metadata as read from file
#' @export
read_master <- function(standard,
                        version = tail(master_lookup(standard), 1),
                        filename = NULL) {
  # Check if filename is NULL before proceeding
  if (is.null(filename)) {
    stop("Please provide a filename")
  }

  # Validate that the file exists
  masterpath <- file.path(standard_path(version), "metadata", filename)
  if (!file.exists(masterpath)) {
    stop("File not found: ", masterpath)
  }

  # Try-catch for robust error handling
  tryCatch({
    metadata <- NNaccess::read_xlsx2(file = masterpath)
    return(metadata)
  }, error = function(e) {
    stop("Error reading metadata file: ", e$message)
  })
}