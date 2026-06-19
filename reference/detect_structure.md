# Detect the parent-child sheet structure of a survey export

Inspects a named list of tibbles (as returned by
[`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md))
and identifies which sheets are parent sheets and which are repeat-group
sheets, together with the hierarchy that links them.

Use this before any merge: it tells you which **units of analysis** are
actually present in your export. A simple form yields one parent and one
child level; a complex form can yield three or more levels (e.g. farm
-\> field -\> observation), each of which is a legitimate unit of
analysis in its own right.

## Usage

``` r
detect_structure(sheets)
```

## Arguments

- sheets:

  A named list of tibbles as returned by
  [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md).

## Value

An object of class `c("survey_structure", "odk_structure")` - a list
with the following components:

- `parent_sheet`:

  Character. Name of the root/parent sheet.

- `repeat_sheets`:

  Character vector of repeat sheet names. Empty (`character(0)`) if no
  repeats are present.

- `tree`:

  A nested named list representing the parent-\>child hierarchy. E.g.
  `list(survey = "species")` for a simple structure, or
  `list(farm = list(field = "observation"))` for nested repeats.

- `index_cols`:

  Named list mapping every sheet name to its index column name.

- `parent_index_cols`:

  Named list mapping every repeat sheet to its parent-index column name.

The legacy `odk_structure` class is also attached so any user code that
dispatched on objects from the previous package version keeps working.

## What this means for analysis

Each entry in `repeat_sheets` corresponds to a candidate **unit of
analysis**. For example, in a household survey with a `members` repeat,
"household-level" analysis lives in `parent_sheet`, while
"individual-level" analysis lives in the `members` repeat (typically
enriched with selected household columns, not the whole parent flattened
in).
[`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md)
and
[`enrich_repeat()`](https://kcham193.github.io/surveymerge/reference/enrich_repeat.md)
let you assemble either.

## Examples

``` r
path      <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
sheets    <- read_survey_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/surveymerge/extdata/simple_survey.xlsx: "survey" and "species".
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
