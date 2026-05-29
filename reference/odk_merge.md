# Merge an ODK or KoboToolbox export into a flat dataset

The main entry point for `odkmerge`. Reads an `.xlsx` export, detects
the repeat-group structure, and returns a flat, analysis-ready dataset —
all in one call.

Internally this function runs:
[`read_odk_export()`](https://kcham193.github.io/odkmerge/reference/read_odk_export.md)
→
[`detect_structure()`](https://kcham193.github.io/odkmerge/reference/detect_structure.md)
→
[`build_master()`](https://kcham193.github.io/odkmerge/reference/build_master.md).

For more control over any step, call those functions individually.

## Usage

``` r
odk_merge(
  file_path,
  drop_internal = TRUE,
  col_types = NULL,
  suffix = c("_repeat", "_parent"),
  verbose = TRUE,
  ...
)
```

## Arguments

- file_path:

  A length-1 character string giving the path to the `.xlsx` file
  exported from ODK or KoboToolbox.

- drop_internal:

  Logical. If `TRUE` (the default), columns starting with `_submission_`
  are removed from repeat sheets before merging.

- col_types:

  A character vector passed to
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
  to control column-type parsing. `NULL` (default) lets `readxl` guess.

- suffix:

  A length-2 character vector of suffixes appended to disambiguate
  column names that appear in more than one sheet. Default:
  `c("_repeat", "_parent")`.

- verbose:

  Logical. If `FALSE`, all informational messages are suppressed.
  Default: `TRUE`.

- ...:

  Additional arguments forwarded to
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).

## Value

- A single tibble when the file contains exactly one repeat sheet.

- A named list of tibbles when the file contains multiple repeat sheets
  (one tibble per repeat group).

## Examples

``` r
path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
master <- odk_merge(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/simple_survey.xlsx: "survey" and "species".
#> ✔ Built master for "species": 40 rows, 11 columns, 40 unique parent records.
head(master)
#> # A tibble: 6 × 11
#>   `_index` `_parent_index` `_parent_table_name` species_name cover_pct height_m
#>      <dbl>           <dbl> <chr>                <chr>            <dbl>    <dbl>
#> 1        1               1 survey               Combretum         42.9     0.2 
#> 2        2               1 survey               Combretum         58.7     2.84
#> 3        3               1 survey               Panicum           21.5     2.4 
#> 4        4               1 survey               Acacia            61.9     0.72
#> 5        5               2 survey               Panicum           30.5     0.71
#> 6        6               2 survey               Themeda           12.7     1.58
#> # ℹ 5 more variables: plot_id <chr>, observer <chr>, survey_date <chr>,
#> #   vegetation_type <chr>, `_uuid` <chr>
```
