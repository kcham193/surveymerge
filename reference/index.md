# Package index

## Main entry point

A one-call wrapper that reads an export, detects its parent-child
structure, and assembles datasets at the unit of analysis implied by
each repeat group.

- [`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md)
  : Read and assemble analysis-ready datasets from a survey export

## Step-by-step workflow

Use these when you need finer control over how repeat groups are joined
and which columns are carried across.

- [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md)
  :

  Read a relational survey export (XLSForm `.xlsx`)

- [`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
  : Detect the parent-child sheet structure of a survey export

- [`print(`*`<survey_structure>`*`)`](https://kcham193.github.io/surveymerge/reference/print.survey_structure.md)
  : Print a survey_structure object

- [`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md)
  : Build analysis-ready datasets from repeat-group sheets

- [`enrich_repeat()`](https://kcham193.github.io/surveymerge/reference/enrich_repeat.md)
  : Enrich a repeat sheet with selected columns from its parent

## Deprecated

Older names retained from the previous `odkmerge` release. They still
work but emit a deprecation warning on first use.

- [`odk_merge()`](https://kcham193.github.io/surveymerge/reference/odk_merge.md)
  :

  Merge a survey export (deprecated; use
  [`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md))

- [`read_odk_export()`](https://kcham193.github.io/surveymerge/reference/read_odk_export.md)
  :

  Read a survey export (deprecated; use
  [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md))

- [`print(`*`<odk_structure>`*`)`](https://kcham193.github.io/surveymerge/reference/print.odk_structure.md)
  : Print an odk_structure object (deprecated)

## Package overview

- [`surveymerge`](https://kcham193.github.io/surveymerge/reference/surveymerge-package.md)
  [`surveymerge-package`](https://kcham193.github.io/surveymerge/reference/surveymerge-package.md)
  : surveymerge: work with relational survey exports and repeat groups
