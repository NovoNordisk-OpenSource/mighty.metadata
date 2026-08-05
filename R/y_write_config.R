#' Write a mighty object to YAML
#'
#' Methods for the [S7schema::write_config()] generic that serialize
#' [mighty_config] and [mighty_study] objects back to YAML files.
#'
#' @param x A [mighty_config] or [mighty_study] object.
#' @param path Directory to write to. If `NULL`, defaults to the source
#'   directory the object was loaded from.
#'
#' @returns Invisibly returns `x`.
#'
#' @seealso [mighty_config], [mighty_study]
#'
#' @name write_config
#' @export
#' @importFrom S7schema write_config
S7schema::write_config

#' @rdname write_config
S7::method(write_config, mighty_config) <- function(x, path = NULL) {
  if (!is.null(path)) {
    path <- match_yml(path = path, name = "_mighty")
  }
  write_config(S7::super(x, to = S7schema::S7schema), path = path)
}

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
    write_config(x = study@mighty, path = path)
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
