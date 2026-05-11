#' @section Writing configuration:
#' Use `write_config(x, path)` to serialize a study back to YAML
#' files. Each domain is written as a separate file, plus
#' `_mighty.yml` and `_study.yml` when non-empty.
#'
#' If `path` is `NULL` (default), files are written to `x@path`.
#'
#' @param x A `mighty_study` object.
#' @param path `character(1)` or `NULL`. Directory to write to.
#'   Defaults to `x@path`.
#' @name mighty_study
#' @rdname mighty_study
S7::method(write_config, mighty_study) <- function(x, path = NULL) {
  write_mighty_study(x, path)
}

#' @noRd
write_mighty_study <- function(study, path) {
  validate(study)

  if (is.null(path)) {
    path <- study@path
  }

  if (length(study@mighty)) {
    write_yml(x = study@mighty, path = path, name = "_mighty")
  }
  if (length(study@study)) {
    write_yml(x = study@study, path = path, name = "_study")
  }

  for (i in seq_along(study)) {
    write_config(
      x = study[[i]],
      path = file.path(path, basename(study[[i]]@file))
    )
  }

  invisible(study)
}
