# define_codelist() errors on duplicate codelist id

    Code
      define_codelist(cl, "NUM", "n", "n", "integer", code = 3)
    Condition
      Error in `cl_define()`:
      ! Codelist "NUM" already exists.

# define_codelist() errors when decode and code lengths differ

    Code
      define_codelist(mighty_codelists(), "X", "n", "n", "text", code = c("A", "B"),
      decode = "a")
    Condition
      Error in `cl_build_values()`:
      ! `decode` must have the same length as `code` (2), not 1.

# remove_codelist() errors on unknown id

    Code
      remove_codelist(mighty_codelists(), "NOPE")
    Condition
      Error in `abort_unknown_codelist()`:
      ! Codelist "NOPE" is not defined in the codelists metadata.

# update_codelist() rejects non codelist-level fields

    Code
      update_codelist(cl, "REGION", values = list())
    Condition
      Error in `cl_update()`:
      ! Only label, description and datatype can be updated.
      x Invalid field: values

# define_codelist_values() errors on unknown codelist

    Code
      define_codelist_values(mighty_codelists(), "NOPE", code = "X")
    Condition
      Error in `abort_unknown_codelist()`:
      ! Codelist "NOPE" is not defined in the codelists metadata.

# remove_codelist_value() errors on unknown code

    Code
      remove_codelist_value(cl, "AGEU", code = "NOPE")
    Condition
      Error in `cl_find_value()`:
      ! Code "NOPE" does not exist in codelist "AGEU".

# move_codelist_value() rejects invalid .pos

    Code
      move_codelist_value(cl, "AGEU", code = "A", .pos = 5)
    Condition
      Error in `cl_move_value()`:
      ! `.pos` must be a single integer between 1 and 3.

# update_codelist_value() rejects subset/restore entries

    Code
      update_codelist_value(cl, "AGEU", code = "YEARS", decode = "Y")
    Condition
      Error in `cl_update_value()`:
      ! Decode can only be updated for values or extend entries; "YEARS" is in subset.

# mighty_study() errors on unreferenced codelists

    Code
      subset_codelist_values(study, "UNUSED", code = "A")
    Condition
      Error in `check_codelist_references()`:
      ! Codelist "UNUSED" is not referenced by any column.
      i Reference the codelist in a column codelist field or remove it from '_codelists.yml'.

