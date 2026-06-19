# Read a relational survey export (XLSForm `.xlsx`)

Reads every sheet from an `.xlsx` export produced by an XLSForm-based
survey platform (ODK Central, KoboToolbox, or any tool that follows the
same conventions) and returns them as a named list of tibbles. This list
is the entry point for all the other `surveymerge` functions.

The function does **not** make any decision about how the sheets relate
to one another or which one is your unit of analysis - that is what
[`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
and
[`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md)
are for. It simply gives you faithful, per-sheet access to the export.

## Usage

``` r
read_survey_export(file_path, col_types = NULL, ...)
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

A named list of tibbles, one per sheet. Names match the sheet names in
the source file. Each tibble preserves the original columns, including
the `_index` / `_parent_index` (KoboToolbox) or `KEY` / `PARENT_KEY`
(ODK Central) columns that downstream functions use to reconstruct
parent-child relationships.

## What this means for analysis

The returned list represents the raw relational structure of your
survey. Each sheet has its own grain (one row per household, one row per
member, one row per visit, ...). Treat it as a *family of related
tables*, not a single dataset.

## Examples

``` r
path   <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
sheets <- read_survey_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/simple_survey.xlsx: "survey" and "species".
names(sheets)   # "survey" "species"
#> [1] "survey"  "species"
```
