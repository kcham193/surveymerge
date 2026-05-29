# Build a flat master dataset from ODK repeat-group sheets

Merges all repeat sheets with their parent sheet(s) to produce flat,
analysis-ready tibbles. Handles three structural patterns automatically:

- **Simple** (one repeat sheet): returns a single tibble.

- **Multi-repeat** (multiple sibling repeat sheets): returns a named
  list of tibbles, one per repeat sheet.

- **Nested repeats** (a repeat inside another repeat): recursively joins
  bottom-up and returns a single flat tibble per chain.

## Usage

``` r
build_master(
  sheets,
  structure = NULL,
  drop_internal = TRUE,
  suffix = c("_repeat", "_parent"),
  nest_sep = "__"
)
```

## Arguments

- sheets:

  A named list of tibbles as returned by
  [`read_odk_export()`](https://kcham193.github.io/odkmerge/reference/read_odk_export.md).

- structure:

  Optional. An `odk_structure` object from
  [`detect_structure()`](https://kcham193.github.io/odkmerge/reference/detect_structure.md).
  If `NULL` (the default),
  [`detect_structure()`](https://kcham193.github.io/odkmerge/reference/detect_structure.md)
  is called internally.

- drop_internal:

  Logical. If `TRUE` (the default), columns starting with `_submission_`
  are removed from repeat sheets before joining.

- suffix:

  A length-2 character vector of suffixes for column-name collisions.
  Default: `c("_repeat", "_parent")`.

- nest_sep:

  A length-1 character string used as separator when renaming columns
  that originate from an intermediate (non-root) level during nested
  joins. Default: `"__"`.

## Value

- A single tibble when there is exactly one repeat sheet.

- A named list of tibbles when there are multiple repeat sheets.

## Examples

``` r
path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
sheets <- read_odk_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/simple_survey.xlsx: "survey" and "species".
master <- build_master(sheets)
#> ✔ Built master for "species": 40 rows, 11 columns, 40 unique parent records.
nrow(master)   # 40 (number of species rows)
#> [1] 40
```
