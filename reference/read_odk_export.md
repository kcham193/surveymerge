# Read a survey export (deprecated; use `read_survey_export()`)

Backward-compatible alias for
[`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md)
retained from the previous `odkmerge` release. New code should call
[`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md)
directly.

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
  to control column-type parsing. Applied identically to every sheet.
  Set `NULL` (the default) to let `readxl` guess types automatically.

- ...:

  Additional arguments passed to
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
  for each sheet (e.g. `na`, `trim_ws`).

## Value

The same value as
[`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md).

## Examples

``` r
path <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
suppressWarnings(sheets <- read_odk_export(path))
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/simple_survey.xlsx: "survey" and "species".
names(sheets)
#> [1] "survey"  "species"
```
