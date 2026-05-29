# Enrich a repeat sheet with columns from its parent sheet

Adds selected columns from the parent sheet into a repeat (child) sheet,
joining on the standard ODK index columns. The result is a
self-contained tibble that can be analysed without needing to reference
the parent sheet separately.

## Usage

``` r
enrich_repeat(
  sheets,
  repeat_sheet_name,
  parent_cols = NULL,
  drop_internal = TRUE,
  suffix = c("_repeat", "_parent")
)
```

## Arguments

- sheets:

  A named list of tibbles as returned by
  [`read_odk_export()`](https://kcham193.github.io/odkmerge/reference/read_odk_export.md).

- repeat_sheet_name:

  A length-1 character string. The name of the repeat sheet to enrich.
  Must be a key in `sheets`.

- parent_cols:

  A character vector of column names to bring across from the parent
  sheet. If `NULL` (the default), all non-internal columns are used
  (i.e. everything that does not start with `_submission_`).

- drop_internal:

  Logical. If `TRUE` (the default), columns starting with `_submission_`
  are removed from the repeat sheet before enrichment.

- suffix:

  A length-2 character vector of suffixes appended to disambiguate
  column names that exist in both sheets. Passed to
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).
  Default: `c("_repeat", "_parent")`.

## Value

A tibble: the repeat sheet with parent columns added on the right. Row
count is unchanged (left join).

## Examples

``` r
path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
sheets <- read_odk_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/simple_survey.xlsx: "survey" and "species".
enriched <- enrich_repeat(sheets, repeat_sheet_name = "species",
                           parent_cols = c("plot_id", "observer"))
#> ℹ Enriched "species": 40 rows, 2 columns added from "survey" (join key: "_parent_index" ↔ _index).
colnames(enriched)
#> [1] "_index"             "_parent_index"      "_parent_table_name"
#> [4] "species_name"       "cover_pct"          "height_m"          
#> [7] "plot_id"            "observer"          
```
