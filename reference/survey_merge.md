# Read and assemble analysis-ready datasets from a survey export

The one-call wrapper for `surveymerge`. Reads an `.xlsx` export, detects
the parent-child sheet structure, and returns a dataset (or one dataset
per repeat group) at the appropriate **unit of analysis**.

Internally this function runs:
[`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md)
-\>
[`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
-\>
[`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md).

For more control over any step - especially the choice of which repeat
grain to use and which parent columns to carry across - call those
functions individually, or use
[`enrich_repeat()`](https://kcham193.github.io/surveymerge/reference/enrich_repeat.md).

## Usage

``` r
survey_merge(
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
  exported from ODK Central, KoboToolbox, or another XLSForm-based
  survey platform.

- drop_internal:

  Logical. If `TRUE` (the default), columns starting with `_submission_`
  (KoboToolbox) and ODK Central's system columns are removed before
  merging.

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

- A single tibble when the file contains exactly one repeat sheet (one
  row per repeat record, with parent columns attached).

- A named list of tibbles when the file contains multiple repeat sheets

  - **one tibble per unit of analysis**. Sibling repeats live at
    different grains, so they are kept as separate tibbles rather than
    blindly stacked together.

## What this means for analysis

The output is shaped by the *structure* of your survey, not by an
assumption about your analysis. Before using the result, pick the tibble
whose grain matches your research question:

- Household-level descriptive statistics -\> use the parent sheet
  directly (`read_survey_export(path)[[structure$parent_sheet]]`) or
  [`enrich_repeat()`](https://kcham193.github.io/surveymerge/reference/enrich_repeat.md)
  with parent-level aggregates.

- Individual / member-level analysis -\> use the `members` tibble.

- Visit / event-level analysis -\> use the corresponding leaf-grain
  tibble.

Pooling tibbles across grains inflates record counts; the package
deliberately does not do this for you.

## Examples

``` r
path   <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
master <- survey_merge(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/simple_survey.xlsx: "survey" and "species".
#> ✔ Built dataset for "species": 40 rows, 11 columns, 40 unique parent records.
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
