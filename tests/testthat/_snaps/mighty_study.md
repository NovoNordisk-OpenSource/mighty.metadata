# mighty_study()

    Code
      print(study)
    Message
      <mighty_study/list/S7_object>
      @ mighty: <mighty_config>
      @ study: <study_config>
      @ documents: 3 entries
      $ ADAE: <mighty_domain>
      $ ADSL: <mighty_domain>
      $ ADVS: <mighty_domain>

# mighty_study() without _study.yml has NULL @study

    Code
      print(study)
    Message
      <mighty_study/list/S7_object>
      @ mighty: <mighty_config>
      $ ADSL: <mighty_domain>

# validate_datasets() error on incorrect file name

    Code
      validate_datasets(files)
    Condition
      Error in `validate_datasets()`:
      ! Incorrect file name detected: _test.yaml in (path: 'example'). Dataset file names are expected to start with "AD" or "MD" (case-insensitive). Please change the file name or remove file from specifications directory.

