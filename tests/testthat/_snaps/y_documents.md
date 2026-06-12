# check_document_references() errors for unknown ids

    Code
      validate(study)
    Condition
      Error in `abort_on_unknown_document_refs()`:
      ! Unknown document references detected.
      x Unknown document id "UNKNOWN" referenced in domain ADVS.
      x Unknown document id "NEXT" referenced in domain ADVS.
      Add this id to 'documents.yml' or update the reference id in metadata.
      i Available document ids: "SUPPDOC001", "COMMENT001", and "METHOD001"

# check_document_references() errors for METHOD on non-Derived

    Code
      validate(study)
    Condition
      Error in `abort_on_invalid_method_refs()`:
      ! Invalid METHOD document references detected.
      x METHOD document "METHOD001" referenced in domain ADVS column STUDYID has origin "<missing>". METHOD is allowed only when origin is exactly "Derived".

# check_document_references() warns for COMMENT with missing text

    Code
      validate(study)
    Condition
      Warning:
      Missing comment text for COMMENT document references.
      ! COMMENT document "COMMENT001" referenced in domain ADAE column TRTEMFL has empty or missing comment text. Add non-empty comment in this metadata location.

