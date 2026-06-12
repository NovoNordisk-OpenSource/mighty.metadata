# Mighty Documents

[`mighty_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.html)
creates an S7 object for storing document metadata. The class inherits
from
[`S7::class_list`](https://rconsortium.github.io/S7/reference/base_classes.html)
and represents the contents of `documents.yml` as a list of document
entries.

The object is validated on creation and when
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
is called. Validation includes:

- schema compliance with `inst/schema/documents.json`,

- uniqueness of document identifiers (`id`).

Writing to YAML is done via
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)
on a
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
object, where documents are saved to `documents.yml`.

## Arguments

- file:

  `character(1)` path to `documents.yml`.

- x:

  [`list()`](https://rdrr.io/r/base/list.html) of document entries.

## Value

An object of class `mighty_documents`.

## Examples
