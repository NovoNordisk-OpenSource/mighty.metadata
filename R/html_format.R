# Functions for HTML formatting and viewing

#' Format table metadata as HTML table
#' @description Creates an HTML table representation of the table_metadata section from ADaM YAML metadata
#' @param table_metadata The table_metadata section from the YAML file
#' @return HTML string containing the formatted table
#' @export
format_table_metadata_html <- function(table_metadata) {
  # Set default values for missing fields
  dataset <- table_metadata$table %||% ""
  description <- table_metadata$label %||% ""
  class <- table_metadata$class %||% ""
  subclass <- table_metadata$subclass %||% ""
  structure <- table_metadata$structure %||% ""
  keys <- if(is.null(table_metadata$keys)) "" else paste(table_metadata$keys, collapse = ", ")
  comment <- table_metadata$comment %||% ""

  # Format class-subclass display
  class_display <- class
  if (!is.null(subclass) && subclass != "") {
    class_display <- paste0(class, " - ", subclass)
  }

  # Create HTML table
  html <- paste0('
  <table summary="Dataset Metadata">
    <caption>Dataset Metadata</caption>
    <tr class="header">
      <th scope="col">Dataset</th>
      <th scope="col">Description</th>
      <th scope="col">Class - SubClass</th>
      <th scope="col">Structure</th>
      <th scope="col">Purpose</th>
      <th scope="col">Keys</th>
      <th scope="col">Documentation</th>
      <th scope="col">Location</th>
    </tr>
    <tr>
      <td>', dataset, '</td>
      <td>', description, '</td>
      <td>', class_display, '</td>
      <td>', structure, '</td>
      <td>Analysis</td>
      <td>', keys, '</td>
      <td>', comment, '</td>
      <td></td>
    </tr>
  </table>')

  return(html)
}

#' Format column metadata as HTML table with value-level metadata support
#' @description Creates an HTML table representation of the column_metadata section from ADaM YAML metadata,
#' including value-level metadata where applicable
#' @param column_metadata The column_metadata section from the YAML file
#' @param value_metadata The value_metadata section from the YAML file (optional)
#' @return HTML string containing the formatted table
#' @export
format_column_metadata_html <- function(column_metadata, value_metadata = NULL) {
  # Start the HTML table
  html <- paste0('
  <table summary="Variables">
    <caption>Variables</caption>
    <tr class="header">
      <th scope="col">Variable</th>
      <th scope="col">Where Condition</th>
      <th scope="col">Label / Description</th>
      <th scope="col">Type</th>
      <th scope="col">Length or Display Format</th>
      <th scope="col">Controlled Terms or ISO Format</th>
      <th scope="col">Origin / Source / Method / Comment</th>
    </tr>')

  # Create a lookup for value-level metadata by column
  vlm_by_column <- list()
  if (!is.null(value_metadata)) {
    for (i in seq_along(value_metadata)) {
      vlm <- value_metadata[[i]]
      col_name <- vlm$column
      if (!is.null(col_name)) {
        if (is.null(vlm_by_column[[col_name]])) {
          vlm_by_column[[col_name]] <- list()
        }
        vlm_by_column[[col_name]] <- c(vlm_by_column[[col_name]], list(vlm))
      }
    }
  }

  # Process each column
  for (i in seq_along(column_metadata)) {
    col <- column_metadata[[i]]

    # Determine if this is a predecessor variable
    is_predecessor <- FALSE
    if (length(col) == 1 && !is.null(col$column) && grepl("^[A-Z]+\\.[A-Z]+", col$column)) {
      is_predecessor <- TRUE
    }

    # Determine if this is a renamed predecessor
    is_renamed_predecessor <- FALSE
    if (!is.null(col$source) && !is.null(col$column)) {
      is_renamed_predecessor <- TRUE
    }

    # Extract variable name
    var_name <- col$column %||% ""
    if (is_predecessor) {
      # For predecessors like DM.USUBJID, just show USUBJID
      var_name <- sub("^[A-Z]+\\.", "", var_name)
    }

    # Check if this column has VLM
    has_vlm <- !is.null(vlm_by_column[[col$column]])

    # Set row class for alternating colors
    row_class <- ifelse(i %% 2 == 0, "even", "odd")

    # Prepare other fields
    var_label <- col$label %||% ""
    if (is_predecessor || is_renamed_predecessor) {
      var_label <- "<em>Inherited from parent</em>"
    }

    # For controlled terms
    controlled_terms <- col$xmlcodelist %||% ""
    if (controlled_terms != "") {
      # Placeholder for future codelist lookup
      controlled_terms <- paste0(controlled_terms,
                                 '<div class="codelist-placeholder">(Codelist values will be displayed here)</div>')
    }

    # Origin/Source/Method/Comment field
    origin_method <- ""
    if (is_predecessor) {
      # For direct predecessors (DM.USUBJID)
      origin_method <- paste0("Predecessor: ", col$column)
    } else if (is_renamed_predecessor) {
      # For renamed predecessors
      origin_method <- paste0("Predecessor: ", col$source)
    } else if (!is.null(col$method)) {
      # For derived/assigned variables
      # Remove the leading pipe character if present
      method_text <- sub("^\\|\\s*", "", col$method)
      origin_method <- paste0('<div class="method-code">', method_text, '</div>')
    }

    # Add VLM indicator if this column has value-level metadata
    vlm_indicator <- ""
    if (has_vlm) {
      vlm_id <- paste0("vlm-", gsub("[^a-zA-Z0-9]", "-", col$column))
      vlm_indicator <- paste0(' <span class="valuelist-reference" onclick="toggleVLM(\'', vlm_id, '\')">VLM</span>')
    }

    # Add the row
    html <- paste0(html, '
    <tr class="tablerow', row_class, '">
      <td>', var_name, vlm_indicator, '</td>
      <td></td>
      <td>', var_label, '</td>
      <td>Data driven</td>
      <td>Data driven</td>
      <td>', controlled_terms, '</td>
      <td>', origin_method, '</td>
    </tr>')

    # Add VLM rows if they exist
    if (has_vlm) {
      vlm_list <- vlm_by_column[[col$column]]
      vlm_id <- paste0("vlm-", gsub("[^a-zA-Z0-9]", "-", col$column))

      for (j in seq_along(vlm_list)) {
        vlm <- vlm_list[[j]]

        # Get the where clause
        where_clause <- vlm$whereclause %||% ""

        # Get the method
        vlm_method <- ""
        if (!is.null(vlm$method)) {
          method_text <- sub("^\\|\\s*", "", vlm$method)
          vlm_method <- paste0('<div class="method-code">', method_text, '</div>')
        }

        # Add the VLM row
        html <- paste0(html, '
        <tr class="vlm ', vlm_id, '" style="display:none;">
          <td><div class="qval-indent">&#x27A4;</div></td>
          <td>', where_clause, '</td>
          <td>', var_label, '</td>
          <td>Data driven</td>
          <td>Data driven</td>
          <td>', controlled_terms, '</td>
          <td>', vlm_method, '</td>
        </tr>')
      }
    }
  }

  # Close the table
  html <- paste0(html, '
  </table>')

  return(html)
}

#' Create a Define-HTML view from ADaM metadata YAML file
#' @description Converts a dataset-level YAML metadata file into an HTML representation
#' similar to Define-XML, displaying it in the RStudio viewer or browser.
#' @param yaml_file Path to the YAML metadata file
#' @param output_file Optional path for the HTML output file. If NULL, a temporary file is used.
#' @param open Whether to open the HTML file in the viewer (TRUE) or just return the path (FALSE)
#' @return Path to the generated HTML file
#' @export
#' @examples
#' # view_define_html("path/to/adsl_metadata.yaml")
view_define_html <- function(yaml_file, output_file = NULL, open = TRUE) {
  # Check if yaml file exists
  if (!file.exists(yaml_file)) {
    stop("YAML file not found: ", yaml_file)
  }

  # Load required packages
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("Package 'yaml' is required. Please install it.")
  }

  # Read the YAML file
  metadata <- yaml::read_yaml(yaml_file)

  # Create output file path if not provided
  if (is.null(output_file)) {
    output_file <- tempfile(fileext = ".html")
  }

  # Extract dataset name from the metadata
  dataset_name <- metadata$table_metadata$table

  # Create HTML content
  html_content <- paste0('
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
  <meta http-equiv="Content-Script-Type" content="text/javascript"/>
  <meta http-equiv="Content-Style-Type" content="text/css"/>
  <title>Define View: ', dataset_name, '</title>
  <style>
    :root {
      --bg-color: #f5f5f5;
      --text-color: #333;
      --main-bg: white;
      --table-header-bg: #2c3e50;
      --table-header-text: white;
      --table-border: #ddd;
      --row-odd: #f9f9f9;
      --row-even: #f2f2f2;
      --code-bg: #f9f9f9;
      --vlm-bg: #e8f4f8;
      --button-bg: #2c3e50;
      --button-text: white;
      --button-hover: #1a252f;
      --shadow-color: rgba(0,0,0,0.1);
      --method-border: #2c3e50;
    }

    [data-theme="dark"] {
      --bg-color: #121212;
      --text-color: #e0e0e0;
      --main-bg: #1e1e1e;
      --table-header-bg: #1a1a2e;
      --table-header-text: #e0e0e0;
      --table-border: #444;
      --row-odd: #2a2a2a;
      --row-even: #333333;
      --code-bg: #2d2d2d;
      --vlm-bg: #1a2a33;
      --button-bg: #1a1a2e;
      --button-text: #e0e0e0;
      --button-hover: #2c3e50;
      --shadow-color: rgba(0,0,0,0.3);
      --method-border: #4a6b8a;
    }

    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      color: var(--text-color);
      background-color: var(--bg-color);
      transition: background-color 0.3s ease, color 0.3s ease;
    }
    #main {
      margin: 20px;
      background-color: var(--main-bg);
      padding: 20px;
      border-radius: 5px;
      box-shadow: 0 0 10px var(--shadow-color);
      transition: background-color 0.3s ease, box-shadow 0.3s ease;
    }
    .study-metadata {
      margin-bottom: 20px;
    }
    dl.study-metadata {
      width: 95%;
      padding: 5px 0px;
    }
    dl.study-metadata dt {
      clear: left;
      float: left;
      width: 200px;
      margin: 0;
      padding: 5px 5px 5px 0px;
      font-weight: bold;
    }
    dl.study-metadata dd {
      margin-left: 210px;
      padding: 5px;
      font-weight: normal;
      min-height: 20px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 20px;
    }
    table caption {
      text-align: left;
      font-weight: bold;
      font-size: 1.2em;
      margin-bottom: 10px;
      color: var(--text-color);
    }
    table th {
      background-color: var(--table-header-bg);
      color: var(--table-header-text);
      text-align: left;
      padding: 8px;
    }
    table td {
      border: 1px solid var(--table-border);
      padding: 8px;
      vertical-align: top;
    }
    tr.tablerowodd {
      background-color: var(--row-odd);
    }
    tr.tableroweven {
      background-color: var(--row-even);
    }
    .method-code {
      white-space: pre-wrap;
      font-family: monospace;
      background-color: var(--code-bg);
      padding: 5px;
      border-left: 3px solid var(--method-border);
    }
    .vlm {
      background-color: var(--vlm-bg);
    }
    .qval-indent {
      margin-left: 20px;
    }
    .codelist-placeholder {
      font-style: italic;
      color: #777;
      font-size: 0.9em;
    }
    .valuelist-reference {
      vertical-align: super;
      font-size: 0.8em;
      padding-left: 5px;
      cursor: pointer;
      color: var(--text-color);
      font-weight: bold;
      background-color: var(--vlm-bg);
      border-radius: 3px;
      padding: 2px 4px;
    }
    .buttons {
      margin: 10px 0;
      display: flex;
      align-items: center;
    }
    button {
      background-color: var(--button-bg);
      color: var(--button-text);
      border: none;
      padding: 5px 10px;
      margin-right: 10px;
      border-radius: 3px;
      cursor: pointer;
      transition: background-color 0.3s ease;
    }
    button:hover {
      background-color: var(--button-hover);
    }
    .theme-switch-wrapper {
      display: flex;
      align-items: center;
      margin-left: auto;
    }
    .theme-switch {
      display: inline-block;
      height: 24px;
      position: relative;
      width: 48px;
    }
    .theme-switch input {
      display: none;
    }
    .slider {
      background-color: #ccc;
      bottom: 0;
      cursor: pointer;
      left: 0;
      position: absolute;
      right: 0;
      top: 0;
      transition: .4s;
      border-radius: 24px;
    }
    .slider:before {
      background-color: white;
      bottom: 4px;
      content: "";
      height: 16px;
      left: 4px;
      position: absolute;
      transition: .4s;
      width: 16px;
      border-radius: 50%;
    }
    input:checked + .slider {
      background-color: #2c3e50;
    }
    input:checked + .slider:before {
      transform: translateX(24px);
    }
    .theme-switch-wrapper span {
      margin-right: 10px;
      font-size: 0.9em;
    }
  </style>
  <script>
    function toggleVLM(id) {
      var rows = document.getElementsByClassName(id);
      for (var i = 0; i < rows.length; i++) {
        rows[i].style.display = rows[i].style.display === "none" ? "table-row" : "none";
      }
    }

    function expandAllVLM() {
      var vlmRows = document.getElementsByClassName("vlm");
      for (var i = 0; i < vlmRows.length; i++) {
        vlmRows[i].style.display = "table-row";
      }
    }

    function collapseAllVLM() {
      var vlmRows = document.getElementsByClassName("vlm");
      for (var i = 0; i < vlmRows.length; i++) {
        vlmRows[i].style.display = "none";
      }
    }

    // Dark mode toggle functionality
    function toggleDarkMode() {
      const currentTheme = document.documentElement.getAttribute("data-theme");
      const newTheme = currentTheme === "dark" ? "light" : "dark";

      document.documentElement.setAttribute("data-theme", newTheme);
      localStorage.setItem("theme", newTheme);
    }

    // Set initial theme based on user preference or localStorage
    document.addEventListener("DOMContentLoaded", function() {
      const savedTheme = localStorage.getItem("theme");
      const prefersDark = window.matchMedia &&
                          window.matchMedia("(prefers-color-scheme: dark)").matches;

      if (savedTheme) {
        document.documentElement.setAttribute("data-theme", savedTheme);
        document.getElementById("theme-toggle").checked = (savedTheme === "dark");
      } else if (prefersDark) {
        document.documentElement.setAttribute("data-theme", "dark");
        document.getElementById("theme-toggle").checked = true;
      }
    });
  </script>
</head>
<body>
  <div id="main">
    <h1>', dataset_name, ' Dataset</h1>

    <!-- Dataset Metadata -->
    <div class="containerbox">
      ', format_table_metadata_html(metadata$table_metadata), '
    </div>

    <!-- VLM Controls -->
    <div class="buttons">
      <button onclick="expandAllVLM()">Expand All VLM</button>
      <button onclick="collapseAllVLM()">Collapse All VLM</button>

      <!-- Dark Mode Toggle -->
      <div class="theme-switch-wrapper">
        <span>Dark Mode</span>
        <label class="theme-switch" for="theme-toggle">
          <input type="checkbox" id="theme-toggle" onclick="toggleDarkMode()" />
          <span class="slider"></span>
        </label>
      </div>
    </div>

    <!-- Variables Table -->
    <div class="containerbox">
      ', format_column_metadata_html(metadata$column_metadata, metadata$value_metadata), '
    </div>
  </div>
</body>
</html>')

  # Write the HTML file
  writeLines(html_content, output_file)

  # Open in viewer if requested
  if (open) {
    if (interactive()) {
      if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
        rstudioapi::viewer(output_file)
      } else {
        utils::browseURL(output_file)
      }
    }
  }

  # Return the path to the HTML file
  return(output_file)
}
