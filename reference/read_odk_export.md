# Read an ODK or KoboToolbox Excel export

Reads every sheet from an `.xlsx` file produced by Open Data Kit (ODK)
or KoboToolbox and returns them as a named list of tibbles. The list is
the entry point for all other `odkmerge` functions.

## Usage

``` r
read_odk_export(file_path, col_types = NULL, ...)
```

## Arguments

- file_path:

  A length-1 character string giving the path to the `.xlsx` file.

- col_types:

  A character vector passed to
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
  to control column type parsing. Applied identically to every sheet.
  Set `NULL` (the default) to let `readxl` guess types automatically.

- ...:

  Additional arguments passed to
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
  for each sheet (e.g. `na`, `trim_ws`).

## Value

A named list of tibbles, one per sheet. Names match the sheet names in
the source file.

## Examples

``` r
path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
sheets <- read_odk_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/simple_survey.xlsx: "survey" and "species".
names(sheets)   # "survey" "species"
#> [1] "survey"  "species"
```
