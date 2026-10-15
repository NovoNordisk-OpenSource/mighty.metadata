# validate_mighty_codelists() detects duplicate ids

    Code
      new_cl(list(id = "A", subset = list(list(code = "X"))), list(id = "A", restore = list(
        list(code = "Y"))))
    Condition
      Error in `check_unique_codelist_ids()`:
      ! Duplicate codelist id entries found: "A"

# validate_mighty_codelists() detects duplicate codes across groups

    Code
      new_cl(list(id = "A", subset = list(list(code = "X")), restore = list(list(
        code = "X"))))
    Condition
      Error in `check_unique_codes()`:
      ! Duplicate code values in codelist "A": "X"

# validate_mighty_codelists() rejects values combined with subset

    Code
      new_cl(list(id = "A", label = "a", description = "a", datatype = "text",
        values = list(list(code = "X")), subset = list(list(code = "Y"))))
    Condition
      Error in `check_codelist_groups()`:
      ! Codelist "A" cannot combine values with subset or restore.
      i values defines a non-standard codelist, while subset and restore modify a standard controlled terminology codelist.

# validate_mighty_codelists() rejects values combined with restore

    Code
      new_cl(list(id = "A", label = "a", description = "a", datatype = "text",
        values = list(list(code = "X")), restore = list(list(code = "Y"))))
    Condition
      Error in `check_codelist_groups()`:
      ! Codelist "A" cannot combine values with subset or restore.
      i values defines a non-standard codelist, while subset and restore modify a standard controlled terminology codelist.

# validate_mighty_codelists() rejects mixed decodes in extend

    Code
      new_cl(list(id = "A", extend = list(list(code = "X", decode = "x"), list(code = "Y"))))
    Condition
      Error in `check_consistent_decodes()`:
      ! Either all or none of the extend entries in codelist "A" must have a decode.

# validate_mighty_codelists() rejects mixed decodes in values

    Code
      new_cl(list(id = "A", label = "a", description = "a", datatype = "text",
        values = list(list(code = "X"), list(code = "Y", decode = "y"))))
    Condition
      Error in `check_consistent_decodes()`:
      ! Either all or none of the values entries in codelist "A" must have a decode.

# mighty_codelists print() summarizes codelists

    Code
      print(cl)
    Message
      <mighty_codelists>
      Codelists: 3 entries
      IDs: `REGION`, `AGEU`, and `LOC`

