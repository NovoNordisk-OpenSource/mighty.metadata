# remove_documents() errors on mighty_study when removing referenced document

    Code
      remove_documents(study, id = "COMMENT001")
    Condition
      Error in `abort_on_unknown_document_refs()`:
      ! Unknown document references detected.
      x Unknown document id "COMMENT001" referenced in domain ADAE column TRTEMFL.
      Add this id to '_documents.yml' or update the reference id in metadata.
      i Available document ids: "SUPPDOC001" and "METHOD001"

# mighty_documents print() summarizes document ids and entry count

    Code
      print(docs)
    Message
      <mighty_documents>
      Documents: 3 entries
      IDs: `SUPPDOC001`, `COMMENT001`, and `METHOD001`

# check_document_references() errors when domains reference document ids but no docs in _documents.yml

    Code
      study@documents <- mighty_documents()
    Condition
      Error in `abort_on_unknown_document_refs()`:
      ! Unknown document references detected.
      x Unknown document id "COMMENT001" referenced in domain ADAE column TRTEMFL.
      x Unknown document id "SUPPDOC001" referenced in domain ADVS.
      x Unknown document id "METHOD001" referenced in domain ADVS column AVAL.
      x Unknown document id "METHOD001" referenced in domain ADVS parameter BMI column AVAL.
      Add this id to '_documents.yml' or update the reference id in metadata.
      i No documents are currently defined in _documents.yml.

# check_document_references() errors when domains reference document ids not defined in _documents.yml

    Code
      validate(study)
    Condition
      Error in `abort_on_unknown_document_refs()`:
      ! Unknown document references detected.
      x Unknown document id "UNKNOWN" referenced in domain ADVS.
      x Unknown document id "NEXT" referenced in domain ADVS.
      Add this id to '_documents.yml' or update the reference id in metadata.
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

