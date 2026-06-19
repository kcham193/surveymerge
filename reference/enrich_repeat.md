# Enrich a repeat sheet with selected columns from its parent

Adds chosen parent-level columns onto a repeat (child) sheet by joining
on the standard survey-export index columns. The result is a tibble at
the **grain of the repeat**, carrying just enough parent context to be
self-contained for analysis at that grain.

Use this when
[`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md)
would carry across more parent columns than you need, or when you want a
clear, intentional set of parent variables on each repeat row (rather
than the full parent flattened in).

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
  [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md).

- repeat_sheet_name:

  A length-1 character string. The name of the repeat sheet to enrich.
  Must be a key in `sheets`.

- parent_cols:

  A character vector of column names to bring across from the parent
  sheet. If `NULL` (the default), all non-internal parent columns are
  used. Pass an explicit vector to keep the output compact and tied to
  your analysis variables.

- drop_internal:

  Logical. If `TRUE` (the default), columns starting with `_submission_`
  are removed from the repeat sheet before enrichment.

- suffix:

  A length-2 character vector of suffixes appended to disambiguate
  column names that exist in both sheets. Passed to
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).
  Default: `c("_repeat", "_parent")`.

## Value

A tibble at the grain of the repeat sheet, with the requested parent
columns added on the right. Row count is unchanged (left join).

## What this means for analysis

`enrich_repeat()` is the right tool when your unit of analysis is the
repeat (e.g. one row per household member) but you need a small set of
household-level covariates (e.g. `village`, `wealth_quintile`) on each
row. Picking `parent_cols` deliberately keeps the dataset honest about
which variables are parent-level (and therefore repeated identically
across siblings) versus repeat-level.

## Examples

``` r
path     <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
sheets   <- read_survey_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/simple_survey.xlsx: "survey" and "species".
enriched <- enrich_repeat(sheets, repeat_sheet_name = "species",
                           parent_cols = c("plot_id", "observer"))
#> ℹ Enriched "species": 40 rows, 2 columns added from "survey" (join key: "_parent_index" ↔ "_index").
colnames(enriched)
#> [1] "_index"             "_parent_index"      "_parent_table_name"
#> [4] "species_name"       "cover_pct"          "height_m"          
#> [7] "plot_id"            "observer"          
```
