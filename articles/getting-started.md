# Getting Started with odkmerge

## Introduction

Open Data Kit (ODK) and KoboToolbox are the most widely-used platforms
for mobile data collection in ecology, public health, agriculture, and
humanitarian research. Both platforms are built on the XLSForm standard,
which supports **repeat groups** — sections of a survey that can be
filled in multiple times per submission. A household survey might repeat
for each household member; a vegetation survey might repeat for each
step walked in a transect.

When you export your data to Excel, ODK and KoboToolbox split every
repeat group into its own sheet. A form with one repeat produces a
two-sheet workbook; a form with nested repeats can produce three or more
sheets. Each repeat sheet links back to its parent via two columns:
`_index` (in the parent) and `_parent_index` (in the repeat).

Joining these sheets back together manually is repetitive, error-prone,
and has to be redone every time you re-export your data. `odkmerge`
automates the entire workflow. It detects the sheet structure, resolves
the join keys, and returns flat, analysis-ready tibbles — for any ODK or
KoboToolbox export, regardless of form complexity.

The package handles three structural patterns:

- **Simple**: one parent sheet + one repeat sheet.
- **Multi-repeat**: one parent sheet + multiple sibling repeat sheets.
- **Nested**: a repeat sheet that is itself the parent of another repeat
  sheet.

------------------------------------------------------------------------

## Installation

``` r

# From GitHub (development version):
devtools::install_github("kcham193/odkmerge")

# From CRAN (once published):
install.packages("odkmerge")
```

------------------------------------------------------------------------

## Quick Start

For most users,
[`odk_merge()`](https://kcham193.github.io/odkmerge/reference/odk_merge.md)
is all you need:

``` r

path   <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
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

One function call. One flat tibble. Ready to analyse.

------------------------------------------------------------------------

## Understanding the Sheet Structure

Before diving deeper, it helps to understand what an ODK export looks
like.

When you export from KoboToolbox or ODK Central, you get an `.xlsx` file
with multiple sheets. The **parent sheet** (sometimes called the main or
survey sheet) has one row per submission. Each **repeat sheet** has one
row per repeated entry, and contains three special columns:

| Column | Sheet | Meaning |
|----|----|----|
| `_index` | every sheet | Row identifier within this sheet |
| `_parent_index` | repeat sheets only | The `_index` value of the parent row |
| `_parent_table_name` | repeat sheets only | The name of the parent sheet |

`odkmerge` uses these columns to automatically detect and join the
sheets.

------------------------------------------------------------------------

## Step-by-Step Workflow

For more control, you can run each step separately.

### Step 1 — Read the export

``` r

path   <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
sheets <- read_odk_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/simple_survey.xlsx: "survey" and "species".
names(sheets)
#> [1] "survey"  "species"
```

[`read_odk_export()`](https://kcham193.github.io/odkmerge/reference/read_odk_export.md)
returns a named list of tibbles, one per sheet. You can inspect any
sheet directly:

``` r

dplyr::glimpse(sheets[["survey"]])
#> Rows: 10
#> Columns: 7
#> $ `_index`           <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
#> $ plot_id            <chr> "P01", "P02", "P03", "P04", "P05", "P06", "P07", "P…
#> $ observer           <chr> "Carol", "Alice", "Bob", "Alice", "Carol", "Carol",…
#> $ survey_date        <chr> "2024-01-01", "2024-01-04", "2024-01-07", "2024-01-…
#> $ vegetation_type    <chr> "savanna", "wetland", "savanna", "savanna", "savann…
#> $ `_uuid`            <chr> "7abd1760-cc8c-457e-947d-6d6f7e5618d8", "0815be6a-c…
#> $ `_submission_time` <chr> "2024-01-01 08:00:00", "2024-01-01 09:00:00", "2024…
```

### Step 2 — Detect the structure

``` r

structure <- detect_structure(sheets)
print(structure)
#> 
#> -- ODK / KoboToolbox Sheet Structure --
#> Parent sheet: 'survey' 
#> Repeat sheet(s): 'species' 
#> 
#> Hierarchy:
#>  * survey 
#>    * species
```

[`detect_structure()`](https://kcham193.github.io/odkmerge/reference/detect_structure.md)
tells you which sheet is the parent, which are repeats, and how they
relate to each other.

### Step 3 — Build the master dataset

``` r

master <- build_master(sheets, structure = structure)
#> ✔ Built master for "species": 40 rows, 11 columns, 40 unique parent records.
dplyr::glimpse(master)
#> Rows: 40
#> Columns: 11
#> $ `_index`             <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15…
#> $ `_parent_index`      <dbl> 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5…
#> $ `_parent_table_name` <chr> "survey", "survey", "survey", "survey", "survey",…
#> $ species_name         <chr> "Combretum", "Combretum", "Panicum", "Acacia", "P…
#> $ cover_pct            <dbl> 42.9, 58.7, 21.5, 61.9, 30.5, 12.7, 68.6, 59.7, 1…
#> $ height_m             <dbl> 0.20, 2.84, 2.40, 0.72, 0.71, 1.58, 2.45, 2.19, 1…
#> $ plot_id              <chr> "P01", "P01", "P01", "P01", "P02", "P02", "P02", …
#> $ observer             <chr> "Carol", "Carol", "Carol", "Carol", "Alice", "Ali…
#> $ survey_date          <chr> "2024-01-01", "2024-01-01", "2024-01-01", "2024-0…
#> $ vegetation_type      <chr> "savanna", "savanna", "savanna", "savanna", "wetl…
#> $ `_uuid`              <chr> "7abd1760-cc8c-457e-947d-6d6f7e5618d8", "7abd1760…
```

Passing the pre-computed `structure` object avoids repeating the
detection step.

------------------------------------------------------------------------

## Handling Multiple Repeat Groups

Some forms have more than one repeat group at the same level — for
example, a household survey that collects both household members and
household assets as separate repeats.

``` r

path   <- system.file("extdata", "multi_repeat_survey.xlsx", package = "odkmerge")
sheets <- read_odk_export(path)
#> ✔ Read 3 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/multi_repeat_survey.xlsx: "household", "members", and "assets".
detect_structure(sheets)
#> 
#> -- ODK / KoboToolbox Sheet Structure --
#> Parent sheet: 'household' 
#> Repeat sheet(s): 'members', 'assets' 
#> 
#> Hierarchy:
#>  * household 
#>    * members 
#>    * assets
```

When there are multiple repeat sheets,
[`build_master()`](https://kcham193.github.io/odkmerge/reference/build_master.md)
returns a **named list of tibbles** — one per repeat group. Sibling
repeats have different row granularity (members vs. assets), so forcing
them into a single frame would not make sense.

``` r

result <- build_master(sheets)
#> ✔ Built master for "members": 26 rows, 9 columns, 26 unique parent records.
#> ✔ Built master for "assets": 20 rows, 8 columns, 20 unique parent records.
names(result)
#> [1] "members" "assets"
nrow(result[["members"]])
#> [1] 26
nrow(result[["assets"]])
#> [1] 20
```

Each tibble already includes all the parent-level columns:

``` r

colnames(result[["members"]])
#> [1] "_index"             "_parent_index"      "_parent_table_name"
#> [4] "member_name"        "age"                "gender"            
#> [7] "hh_id"              "village"            "_uuid"
```

------------------------------------------------------------------------

## Nested Repeats

A nested repeat is a repeat group inside another repeat group. In the
example below, a farm can have multiple fields, and each field can have
multiple observations — three levels deep.

``` r

path   <- system.file("extdata", "nested_survey.xlsx", package = "odkmerge")
sheets <- read_odk_export(path)
#> ✔ Read 3 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/nested_survey.xlsx: "farm", "field", and "observation".
detect_structure(sheets)
#> 
#> -- ODK / KoboToolbox Sheet Structure --
#> Parent sheet: 'farm' 
#> Repeat sheet(s): 'field', 'observation' 
#> 
#> Hierarchy:
#>  * farm 
#>    * field 
#>      * observation
```

[`build_master()`](https://kcham193.github.io/odkmerge/reference/build_master.md)
resolves the full chain recursively. The `observation` master will
contain columns from both `field` and `farm`:

``` r

result <- build_master(sheets)
#> ✔ Built master for "field": 15 rows, 8 columns, 15 unique parent records.
#> ✔ Built master for "observation": 45 rows, 13 columns, 45 unique parent records.
obs    <- result[["observation"]]
# Confirm grandparent column is present
"farm_id" %in% colnames(obs)
#> [1] TRUE
dplyr::glimpse(obs)
#> Rows: 45
#> Columns: 13
#> $ `_index`                    <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,…
#> $ `_parent_index`             <dbl> 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, …
#> $ `_parent_table_name_repeat` <chr> "field", "field", "field", "field", "field…
#> $ obs_date                    <chr> "2024-03-27", "2024-03-14", "2024-03-17", …
#> $ pest_present                <lgl> FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TR…
#> $ notes                       <chr> "severe", "mild stress", "mild stress", "N…
#> $ `_parent_index_parent`      <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, …
#> $ `_parent_table_name_parent` <chr> "farm", "farm", "farm", "farm", "farm", "f…
#> $ field_name                  <chr> "Field_1", "Field_1", "Field_1", "Field_2"…
#> $ crop                        <chr> "maize", "maize", "maize", "maize", "maize…
#> $ farm_id                     <chr> "F01", "F01", "F01", "F02", "F02", "F02", …
#> $ farm_size_ha                <dbl> 6.3, 6.3, 6.3, 19.4, 19.4, 19.4, 11.8, 11.…
#> $ `_uuid`                     <chr> "ab4efd5d-992a-4775-b689-dc5450784e9b", "a…
```

------------------------------------------------------------------------

## Selecting Parent Columns

If you only want specific parent columns added to a repeat sheet — not
all of them — use
[`enrich_repeat()`](https://kcham193.github.io/odkmerge/reference/enrich_repeat.md)
directly:

``` r

path   <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
sheets <- read_odk_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/simple_survey.xlsx: "survey" and "species".

enriched <- enrich_repeat(
  sheets,
  repeat_sheet_name = "species",
  parent_cols       = c("plot_id", "observer", "vegetation_type")
)
#> ℹ Enriched "species": 40 rows, 3 columns added from "survey" (join key: "_parent_index" ↔ "_index").

colnames(enriched)
#> [1] "_index"             "_parent_index"      "_parent_table_name"
#> [4] "species_name"       "cover_pct"          "height_m"          
#> [7] "plot_id"            "observer"           "vegetation_type"
```

This is useful when the parent sheet has dozens of columns and you only
need a few for your analysis.

------------------------------------------------------------------------

## Exporting Results

Once you have your flat dataset, exporting is straightforward:

``` r

# CSV
write.csv(master, "vegetation_master.csv", row.names = FALSE)

# Excel (single sheet)
writexl::write_xlsx(master, "vegetation_master.xlsx")

# Excel (multiple sheets — for multi-repeat results)
result <- odk_merge(path, verbose = FALSE)
if (is.data.frame(result)) {
  writexl::write_xlsx(result, "master.xlsx")
} else {
  writexl::write_xlsx(result, "master.xlsx")  # named list -> one sheet per repeat
}
```

------------------------------------------------------------------------

## FAQ

**Q: My form has a repeat but I only see one sheet in the export —
why?**

Some ODK deployments only export sheets that have at least one entry. If
all submissions skipped a repeat group, the sheet will be absent. Check
that at least one submission has data in the repeat group, then
re-export.

------------------------------------------------------------------------

**Q:
[`odk_merge()`](https://kcham193.github.io/odkmerge/reference/odk_merge.md)
returns a list instead of a single tibble — what do I do?**

A list is returned when there are multiple repeat sheets. Access
individual tibbles with `result[["sheet_name"]]`, or iterate with
[`purrr::map()`](https://purrr.tidyverse.org/reference/map.html). Use
[`detect_structure()`](https://kcham193.github.io/odkmerge/reference/detect_structure.md)
first to see your form’s structure.

------------------------------------------------------------------------

**Q: Column names are duplicated with `_repeat` and `_parent`
suffixes.**

This happens when the same column name exists in both the parent and
repeat sheet (e.g. both have a column called `date`). The suffix makes
the origin explicit. You can change the suffix with the `suffix`
argument: `odk_merge(path, suffix = c("_child", "_main"))`.

------------------------------------------------------------------------

**Q: Can I use this with KoboToolbox API exports (CSV format)?**

Currently `odkmerge` supports `.xlsx` exports only. CSV exports from
KoboToolbox have a slightly different structure. CSV support is planned
for a future version.

------------------------------------------------------------------------

**Q: `_submission_*` columns are cluttering my output — how do I remove
them?**

They are removed by default (`drop_internal = TRUE`). If they are
appearing, check that you are not passing `drop_internal = FALSE`. You
can also remove them after the fact with
`dplyr::select(master, -starts_with("_submission_"))`.

------------------------------------------------------------------------

**Q: My form has 4 or more levels of nesting — does odkmerge handle
that?**

Yes.
[`build_master()`](https://kcham193.github.io/odkmerge/reference/build_master.md)
walks up the ancestry chain recursively, so any depth of nesting is
supported as long as each sheet has valid `_parent_index` and
`_parent_table_name` columns.
