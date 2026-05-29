# Changelog

## odkmerge 0.1.0

- Initial release.
- [`odk_merge()`](https://kcham193.github.io/odkmerge/reference/odk_merge.md):
  one-call wrapper that reads an ODK / KoboToolbox `.xlsx` export and
  returns flat, analysis-ready tibbles.
- [`read_odk_export()`](https://kcham193.github.io/odkmerge/reference/read_odk_export.md):
  reads every sheet of an export as a named list of tibbles.
- [`detect_structure()`](https://kcham193.github.io/odkmerge/reference/detect_structure.md):
  classifies sheets as parent vs. repeat and builds the parent-\>child
  hierarchy; returns an `odk_structure` S3 object with a `print` method.
- [`build_master()`](https://kcham193.github.io/odkmerge/reference/build_master.md):
  joins repeat sheets up to the root parent. Handles simple,
  multi-repeat (sibling), and nested-repeat structures.
- [`enrich_repeat()`](https://kcham193.github.io/odkmerge/reference/enrich_repeat.md):
  adds selected parent columns into a single repeat sheet.
- Bundled fixture exports in `inst/extdata/`: `simple_survey.xlsx`,
  `multi_repeat_survey.xlsx`, `nested_survey.xlsx`.
- Getting-started vignette covering all three structural patterns.
