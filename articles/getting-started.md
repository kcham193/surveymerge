# Getting Started with surveymerge

## Introduction

XLSForm-based platforms such as **ODK Central** and **KoboToolbox** are
the most widely-used tools for mobile data collection in ecology, public
health, agriculture, and humanitarian research. Their forms support
**repeat groups** - sections of a survey that can be filled in multiple
times per submission. A household survey might repeat for each member; a
vegetation survey might repeat for each step walked along a transect.

When you export your data to Excel, every repeat group lands in its own
sheet, linked back to the parent via index columns. Re-joining those
sheets by hand is repetitive and error-prone - but joining them blindly
into one wide table can be statistically misleading.

`surveymerge` automates the relational plumbing **and** keeps the grain
structure of your data explicit, so you can build analysis-ready
datasets at the unit of analysis you actually care about.

The package handles three structural patterns:

- **Simple**: one parent sheet + one repeat sheet.
- **Multi-repeat**: one parent sheet + multiple sibling repeat sheets.
- **Nested**: a repeat sheet that is itself the parent of another repeat
  sheet.

------------------------------------------------------------------------

## Understanding units of analysis

Before showing the code, it is worth pausing on the most important idea
in this package: **a survey export is not one dataset, it is several**.

A typical household survey export can contain:

- **Household-level** data - one row per household. Lives in the parent
  sheet (`household`).
- **Member-level** data - one row per member. Lives in a `members`
  repeat sheet.
- **Visit-level** data - one row per visit. Lives in a `visits` repeat
  (if your form has revisits).
- **Observation-level** data - one row per measurement. Lives even
  deeper in nested repeats.

Each of those is a legitimate **unit of analysis**:

| Unit of analysis | Example research question | Where the data lives |
|----|----|----|
| Household | What fraction of households own livestock? | parent sheet |
| Member | What is the age distribution of household members? | `members` repeat (+ selected hh columns) |
| Asset | Which assets are most common? | `assets` repeat |
| Visit | How long between baseline and follow-up visits? | `visits` repeat |
| Observation | What is the average leaf cover per measurement? | nested observation repeat |

A common mistake is to “flatten” all of these into a single wide table.
That looks tidy, but it inflates row counts (a household with five
members is now five rows), distorts means and proportions, and turns
parent-level variables into pseudo-repeated measures. `surveymerge`
gives you one tibble per grain so you can pick the right one.

------------------------------------------------------------------------

## Installation

``` r

# From GitHub (development version):
devtools::install_github("kcham193/surveymerge")

# From CRAN (once published):
install.packages("surveymerge")
```

------------------------------------------------------------------------

## Quick start

For most users,
[`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md)
is all you need:

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

One function call. One tibble. Aligned to the species grain (one row per
recorded species), with plot-level columns attached.

------------------------------------------------------------------------

## Understanding the sheet structure

When you export from KoboToolbox or ODK Central, you get an `.xlsx` file
with multiple sheets. The **parent sheet** has one row per submission.
Each **repeat sheet** has one row per repeated entry, and is linked to
its parent via special columns:

| Column | Sheet | Meaning |
|----|----|----|
| `_index` / `KEY` | every sheet | Row identifier within this sheet |
| `_parent_index` / `PARENT_KEY` | repeat sheets only | The `_index` value of the parent row |
| `_parent_table_name` | repeat sheets only | Name of the parent sheet (Kobo only) |

`surveymerge` uses these columns to detect and join sheets
automatically, across both the KoboToolbox and ODK Central export
conventions.

------------------------------------------------------------------------

## Step-by-step workflow

For more control, you can run each step separately.

### Step 1 - Read the export

``` r

path   <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
sheets <- read_survey_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/simple_survey.xlsx: "survey" and "species".
names(sheets)
#> [1] "survey"  "species"
```

[`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md)
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

### Step 2 - Detect the structure

``` r

structure <- detect_structure(sheets)
print(structure)
#> 
#> -- Survey Export Structure --
#> Parent sheet: 'survey' 
#> Repeat sheet(s): 'species' 
#> 
#> Hierarchy (each level is a candidate unit of analysis):
#>  * survey 
#>    * species
```

[`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
tells you which sheet is the parent, which are repeats, and how they
relate - i.e. which units of analysis your export contains.

### Step 3 - Build a dataset at the right grain

``` r

master <- build_master(sheets, structure = structure)
#> ✔ Built dataset for "species": 40 rows, 11 columns, 40 unique parent records.
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

## Handling multiple repeat groups

Some forms have more than one repeat group at the same level - for
example, a household survey that collects both household members and
household assets as separate repeats.

``` r

path   <- system.file("extdata", "multi_repeat_survey.xlsx", package = "surveymerge")
sheets <- read_survey_export(path)
#> ✔ Read 3 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/multi_repeat_survey.xlsx: "household", "members", and "assets".
detect_structure(sheets)
#> 
#> -- Survey Export Structure --
#> Parent sheet: 'household' 
#> Repeat sheet(s): 'members', 'assets' 
#> 
#> Hierarchy (each level is a candidate unit of analysis):
#>  * household 
#>    * members 
#>    * assets
```

When there are multiple repeat sheets,
[`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md)
returns a **named list of tibbles** - one per repeat group. Sibling
repeats live at *different* grains (members vs. assets), so forcing them
into a single frame would conflate units of analysis.

``` r

result <- build_master(sheets)
#> ✔ Built dataset for "members": 26 rows, 9 columns, 26 unique parent records.
#> ✔ Built dataset for "assets": 20 rows, 8 columns, 20 unique parent records.
names(result)
#> [1] "members" "assets"
nrow(result[["members"]])
#> [1] 26
nrow(result[["assets"]])
#> [1] 20
```

Each tibble already includes the parent-level columns that make it
self-contained at its grain:

``` r

colnames(result[["members"]])
#> [1] "_index"             "_parent_index"      "_parent_table_name"
#> [4] "member_name"        "age"                "gender"            
#> [7] "hh_id"              "village"            "_uuid"
```

Use `result[["members"]]` for member-level analysis,
`result[["assets"]]` for asset-level analysis, and the parent sheet
directly for household-level analysis.

------------------------------------------------------------------------

## Nested repeats

A nested repeat is a repeat group inside another repeat group. In the
example below, a farm has multiple fields, and each field has multiple
observations - three levels deep.

``` r

path   <- system.file("extdata", "nested_survey.xlsx", package = "surveymerge")
sheets <- read_survey_export(path)
#> ✔ Read 3 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/nested_survey.xlsx: "farm", "field", and "observation".
detect_structure(sheets)
#> 
#> -- Survey Export Structure --
#> Parent sheet: 'farm' 
#> Repeat sheet(s): 'field', 'observation' 
#> 
#> Hierarchy (each level is a candidate unit of analysis):
#>  * farm 
#>    * field 
#>      * observation
```

[`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md)
resolves the full chain recursively. The `observation` master will
contain columns from both `field` and `farm`:

``` r

result <- build_master(sheets)
#> ✔ Built dataset for "field": 15 rows, 8 columns, 15 unique parent records.
#> ✔ Built dataset for "observation": 45 rows, 13 columns, 45 unique parent records.
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

The observation tibble has one row per observation - the natural grain
for observation-level analysis, with farm- and field-level context
joined in.

------------------------------------------------------------------------

## Choosing parent columns deliberately

If you only want specific parent columns added to a repeat sheet - not
the whole parent flattened in - use
[`enrich_repeat()`](https://kcham193.github.io/surveymerge/reference/enrich_repeat.md):

``` r

path   <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
sheets <- read_survey_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/simple_survey.xlsx: "survey" and "species".

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
need a few covariates for the analysis at the repeat grain. It also
makes your script self-documenting about *which* parent variables you
intentionally carried across.

------------------------------------------------------------------------

## Migration from `odkmerge`

If you previously used `odkmerge` 0.1.0:

- [`odk_merge()`](https://kcham193.github.io/surveymerge/reference/odk_merge.md)
  still works but is deprecated; use
  [`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md).
- [`read_odk_export()`](https://kcham193.github.io/surveymerge/reference/read_odk_export.md)
  still works but is deprecated; use
  [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md).
- [`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
  now returns an object of class `survey_structure` (and still carries
  the legacy `odk_structure` class for back-compat).

Each deprecated call emits a one-time warning per session.

------------------------------------------------------------------------

## Exporting results

Once you have a dataset at the grain you want, exporting is
straightforward:

``` r

# CSV
write.csv(master, "vegetation_master.csv", row.names = FALSE)

# Excel (single sheet)
writexl::write_xlsx(master, "vegetation_master.xlsx")

# Excel (multiple sheets - for multi-repeat results)
result <- survey_merge(path, verbose = FALSE)
if (is.data.frame(result)) {
  writexl::write_xlsx(result, "master.xlsx")
} else {
  writexl::write_xlsx(result, "master.xlsx")  # named list -> one sheet per repeat
}
```

------------------------------------------------------------------------

## FAQ

**Q: My form has a repeat but I only see one sheet in the export -
why?**

Some deployments only export sheets that have at least one entry. If all
submissions skipped a repeat group, the sheet will be absent. Check that
at least one submission has data in the repeat group, then re-export.

------------------------------------------------------------------------

**Q:
[`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md)
returns a list instead of a single tibble - what do I do?**

A list is returned when the export contains multiple repeat groups -
because each repeat lives at its own unit of analysis. Pick the tibble
that matches your research question (e.g. `result[["members"]]` for
member-level analysis). Use
[`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
first to see what your form contains.

------------------------------------------------------------------------

**Q: Column names are duplicated with `_repeat` and `_parent`
suffixes.**

This happens when the same column name exists in both the parent and
repeat sheet (e.g. both have a column called `date`). The suffix makes
the origin explicit. You can change the suffix with the `suffix`
argument: `survey_merge(path, suffix = c("_child", "_main"))`.

------------------------------------------------------------------------

**Q: Can I use this with CSV exports?**

Currently `surveymerge` supports `.xlsx` exports only. CSV support is
planned for a future version.

------------------------------------------------------------------------

**Q: `_submission_*` columns are cluttering my output - how do I remove
them?**

They are removed by default (`drop_internal = TRUE`). If they are
appearing, check that you are not passing `drop_internal = FALSE`. You
can also remove them after the fact with
`dplyr::select(master, -starts_with("_submission_"))`.

------------------------------------------------------------------------

**Q: My form has 4 or more levels of nesting - does surveymerge handle
that?**

Yes.
[`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md)
walks up the ancestry chain recursively, so any depth of nesting is
supported as long as each sheet has valid `_parent_index` and (on Kobo)
`_parent_table_name` columns.
