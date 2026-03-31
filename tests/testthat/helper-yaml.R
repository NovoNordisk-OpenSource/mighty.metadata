# Helper to write type-safe yaml from base list similar to S7schema::write_config
write_safe_yaml <- function(x, path) {
  cat(
    result = S7schema::to_yaml(x),
    file = path,
    sep = ""
  )

  invisible(path)
}
