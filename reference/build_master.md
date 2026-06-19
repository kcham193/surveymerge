# Build analysis-ready datasets from repeat-group sheets

For each repeat sheet in a survey export, `build_master()` walks up the
parent chain and assembles a tibble at the **grain of that repeat**,
with all relevant ancestor columns joined in. The number of rows in each
resulting tibble matches the number of rows in the underlying repeat
sheet - so each output is already aligned to a specific unit of
analysis.

Three structural patterns are supported:

- **Simple** (one repeat sheet): returns a single tibble at the grain of
  that repeat (e.g. one row per species observation, with plot-level
  columns attached).

- **Multi-repeat** (multiple sibling repeat sheets): returns a named
  list of tibbles, one per repeat sheet. Sibling repeats live at
  *different* grains (e.g. household members vs. household assets), so
  they are kept in separate tibbles rather than forced into one.

- **Nested repeats** (a repeat inside another repeat): each leaf repeat
  is recursively joined up to the root parent, returning a flat tibble
  at the leaf grain that still contains grandparent columns.

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
  [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md).

- structure:

  Optional. A `survey_structure` object from
  [`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md).
  If `NULL` (the default),
  [`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
  is called internally.

- drop_internal:

  Logical. If `TRUE` (the default), columns starting with `_submission_`
  (KoboToolbox) and ODK Central's system columns (`SubmissionDate`,
  `SubmitterID`, etc.) are removed before joining.

- suffix:

  A length-2 character vector of suffixes for column-name collisions.
  Default: `c("_repeat", "_parent")`.

- nest_sep:

  A length-1 character string used as separator when renaming columns
  that originate from an intermediate (non-root) level during nested
  joins. Default: `"__"`.

## Value

- A single tibble when there is exactly one repeat sheet, at the grain
  of that repeat.

- A named list of tibbles when there are multiple repeat sheets, each at
  the grain of its own repeat.

## What this means for analysis

The output of `build_master()` is **not** "the dataset" - it is a
dataset *per repeat grain*. Picking which one to use depends on your
research question:

- To analyse outcomes at the **household** level, work from the parent
  sheet directly (`sheets[[structure$parent_sheet]]`), perhaps with
  [`enrich_repeat()`](https://kcham193.github.io/surveymerge/reference/enrich_repeat.md)
  aggregates joined in.

- To analyse outcomes at the **individual / member** level, use the
  `members`-grain tibble from this function.

- To analyse outcomes at the **visit** or **observation** level, use the
  leaf-grain tibble from this function.

Stacking grains naively (e.g. concatenating member-level and
household-level rows) inflates counts and distorts estimates. The
separate tibbles are an intentional safeguard against that.

## Examples

``` r
path   <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
sheets <- read_survey_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/simple_survey.xlsx: "survey" and "species".
master <- build_master(sheets)
#> ✔ Built dataset for "species": 40 rows, 11 columns, 40 unique parent records.
nrow(master)   # equals nrow(sheets$species): one row per species observation
#> [1] 40
```
