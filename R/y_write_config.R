#' Write a mighty object to YAML
#'
#' Serializes [mighty_config], [study_config], and [mighty_study] objects back
#' to YAML files. [mighty_config] and [study_config] inherit the
#' [S7schema::write_config()] method of their parent class; [mighty_study] adds
#' a method that writes every domain plus `_mighty.yml` and `_study.yml`.
#'
#' @param x A [mighty_config], [study_config], or [mighty_study] object.
#' @param path Destination to write to. A file for [mighty_config] and
#'   [study_config], a directory for [mighty_study]. If `NULL`, defaults to the
#'   source the object was loaded from.
#'
#' @returns Invisibly returns `x`.
#'
#' @seealso [mighty_config], [study_config], [mighty_study]
#'
#' @name write_config
#' @export
#' @importFrom S7schema write_config
S7schema::write_config

#' @rdname write_config
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
    write_config(
      x = study@mighty,
      path = match_yml(path = path, name = "_mighty")
    )
  }
  if (!is.null(study@study)) {
    write_config(
      x = study@study,
      path = match_yml(path = path, name = "_study")
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
