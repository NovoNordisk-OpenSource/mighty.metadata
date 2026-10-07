# define_codelist() works without decodes and errors on duplicates

    Code
      define_codelist(cl, "NUM", "n", "n", "integer", code = 3)
    Condition
      Error in `cl_define()`:
      ! Codelist "NUM" already exists.

---

    Code
      define_codelist(cl, "X", "n", "n", "text", code = c("A", "B"), decode = "a")
    Condition
      Error in `cl_build_values()`:
      ! `decode` must have the same length as `code` (2), not 1.

# remove_codelist() removes a codelist

    Code
      remove_codelist(cl, "NOPE")
    Condition
      Error in `abort_unknown_codelist()`:
      ! Codelist "NOPE" does not exist.

# update_codelist() updates only codelist-level fields

    Code
      update_codelist(cl, "REGION", values = list())
    Condition
      Error in `cl_update()`:
      ! Only label, description and datatype can be updated.
      x Invalid field: values

# define_codelist_values() appends to existing codelist

    Code
      define_codelist_values(cl, "NOPE", code = "X")
    Condition
      Error in `abort_unknown_codelist()`:
      ! Codelist "NOPE" does not exist.

# remove_codelist_value() removes from the right group

    Code
      remove_codelist_value(cl, "AGEU", code = "NOPE")
    Condition
      Error in `cl_find_value()`:
      ! Code "NOPE" does not exist in codelist "AGEU".

# move_codelist_value() moves within group

    Code
      move_codelist_value(cl, "AGEU", code = "DAYS", .pos = 5)
    Condition
      Error in `cl_move_value()`:
      ! `.pos` must be a single integer between 1 and 2.

# update_codelist_value() works for values and extend only

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

