#' @section Write Config:
#' Use `write_config()` to serialize a `mighty_config()` object back to a
#' `_mighty.yml` file.
#'
#' Supply `path` to write to a specific directory; defaults to the directory
#' the object was loaded from.
#' @name mighty_config
#' @rdname mighty_config
S7::method(write_config, mighty_config) <- function(x, path = NULL) {
  if (!is.null(path)) {
    path <- match_yml(path = path, name = "_mighty")
  }
  write_config(S7::super(x, to = S7schema::S7schema), path = path)
}

#' @section Write Study Metadata:
#' Use `write_config()` to serialize a `mighty_study()` object back to YAML
#' files. Each domain is written as a separate file, plus
#' `_mighty.yml` and `_study.yml` when non-empty.
#'
#' If `path` is `NULL` (default), files are written to `x@path`.
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

  if (!is.null(study@mighty)) {
    write_config(x = study@mighty, path = path)
  }
  if (length(study@study)) {
    write_yml(x = study@study, path = path, name = "_study")
  }
  if (length(study@documents)) {
    write_yml(
      x = S7::S7_data(study@documents),
      path = path,
      name = "documents"
    )
  }

  for (i in seq_along(study)) {
    write_config(
      x = study[[i]],
      path = file.path(path, basename(study[[i]]@file))
    )
  }

  invisible(study)
}
