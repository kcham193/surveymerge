# Detect the parent-child sheet structure of an ODK export

Inspects a named list of tibbles (as returned by
[`read_odk_export()`](https://kcham193.github.io/odkmerge/reference/read_odk_export.md))
and identifies which sheets are parent (main) sheets and which are
repeat-group sheets. Returns a structured object describing the
hierarchy, which can be passed to
[`build_master()`](https://kcham193.github.io/odkmerge/reference/build_master.md)
or
[`enrich_repeat()`](https://kcham193.github.io/odkmerge/reference/enrich_repeat.md).

## Usage

``` r
detect_structure(sheets)
```

## Arguments

- sheets:

  A named list of tibbles as returned by
  [`read_odk_export()`](https://kcham193.github.io/odkmerge/reference/read_odk_export.md).

## Value

An object of class `"odk_structure"` - a list with the following
components:

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

## Examples

``` r
path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
sheets <- read_odk_export(path)
#> ✔ Read 2 sheets from /home/runner/work/_temp/Library/odkmerge/extdata/simple_survey.xlsx: "survey" and "species".
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
