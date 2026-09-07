# Write a mighty object to YAML

Serializes
[mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md),
[study_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md),
and
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
objects back to YAML files.
[mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
and
[study_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md)
inherit the
[`S7schema::write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)
method of their parent class;
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
adds a method that writes every domain plus `_mighty.yml` and
`_study.yml`.

## Usage

``` r
write_config(x, path = NULL)

## S7 method for class <mighty.metadata::mighty_study>
write_config(x, path = NULL)
```

## Arguments

- x:

  A
  [mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md),
  [study_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md),
  or
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  object.

- path:

  Destination to write to. A file for
  [mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
  and
  [study_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md),
  a directory for
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md).
  If `NULL`, defaults to the source the object was loaded from.

## Value

Invisibly returns `x`.

## See also

[mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md),
[study_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md),
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
