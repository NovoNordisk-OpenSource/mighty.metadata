# mighty.metadata

A package for managing CDISC ADaM metadata in YAML format.

## Introduction

The `mighty.metadata` package provides tools for working with CDISC ADaM metadata in YAML format. It facilitates the extraction, transformation, and management of metadata for clinical trial analysis datasets, making it easier to maintain, version, and document ADaM specifications.

Key features:
- Extract metadata from standard sources
- Build structured ADaM metadata
- Generate YAML files with proper formatting
- Track domain references
- View metadata in HTML format

## Getting Started

### Installation

To install the development version from Azure DevOps:

```r
# Install from private Novo Nordisk repository
# Requires authentication and access to the BOS project
remotes::install_git(
  "https://dev.azure.com/novonordiskit/BOS/_git/mighty.metadata",
  credentials = git2r::cred_token()
)
```

### Dependencies

This package requires:
- R (>= 4.0.0)
- dplyr
- yaml
- htmltools
- NNremote
- NNaccess

## Usage

### Basic Workflow

```r
library(mighty.metadata)

# 1. Read master metadata
metadata <- read_master("adam", filename = "cst_adam_metadata_file.xlsx")

# 2. Build ADaM metadata structure
adam_metadata <- build_adam_metadata(metadata)

# 3. Write to YAML files
output_dir <- "metadata/adam"
write_adam_domain_yaml(
  domain_data = adam_metadata$ADAE,
  domain_name = "ADAE",
  output_dir = output_dir
)

# 4. View metadata in HTML
view_define_html(adam_metadata$ADAE)
```

### Working with Selected Datasets

You can select specific domains to work with using standard R list manipulation:

```r
# Filter to only keep selected domains
selected_domains <- c("ADSL", "ADAE", "ADVS")
filtered_metadata <- adam_metadata[selected_domains]

# Or remove unwanted domains
domains_to_remove <- c("ADQS", "ADPP")
filtered_metadata <- adam_metadata[!names(adam_metadata) %in% domains_to_remove]
```

### Writing Multiple Domains

To write multiple domains at once:

```r
# Write all domains to YAML files
output_dir <- "metadata/adam"

# Option 1: Using a loop
for (domain_name in names(adam_metadata)) {
  write_adam_domain_yaml(
    domain_data = adam_metadata[[domain_name]],
    domain_name = domain_name,
    output_dir = output_dir
  )
}

# Option 2: Using lapply for more concise code
yaml_files <- mapply(
  write_adam_domain_yaml,
  domain_data = adam_metadata,
  domain_name = names(adam_metadata),
  MoreArgs = list(output_dir = output_dir)
)
```

## Package Structure

The package is organized into several modules:

- **Standard Utilities**: Functions for accessing CDISC standard libraries
- **Domain References**: Tools for tracking references between domains
- **Metadata Building**: Functions to transform raw metadata into structured format
- **YAML Handling**: Tools for reading and writing YAML files
- **HTML Formatting**: Functions for viewing metadata in HTML format

## Documentation

For more detailed information, see the package vignettes:

- `vignette("mightymetadata")`: Main usage documentation
- `vignette("yaml-format")`: Details on YAML format structure
- `vignette("adam-metadata")`: Information about ADaM metadata concepts

## Contributing

This package is currently under development. Contributions are welcome through:

1. Reporting issues
2. Suggesting enhancements
3. Creating pull requests

Please contact the BOS team for guidance on contributing.

## License

MIT License, Copyright (c) Novo Nordisk A/S
TODO: Describe and show how to build your code and run the tests. 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)