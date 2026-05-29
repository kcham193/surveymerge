# odkmerge (development version)

* feat: support **ODK Central** exports (`KEY` / `PARENT_KEY` column
  conventions) alongside the existing **KoboToolbox** support
  (`_index` / `_parent_index`). Detection in `R/utils.R` now accepts
  both naming schemes, and `drop_internal = TRUE` strips ODK Central
  system columns (`SubmissionDate`, `SubmitterID`, `SubmitterName`,
  `AttachmentsPresent`, `AttachmentsExpected`, `Status`, `ReviewState`,
  `DeviceID`, `Edits`, `FormVersion`) in addition to Kobo's
  `_submission_*` columns.
* fix: `enrich_repeat()` no longer hard-codes `_index` for the parent
  join key. It now resolves the parent's index column via
  `.odk_index_col()`, so it works against either format.
* New fixture: `inst/extdata/simple_survey_central.xlsx`. New test file:
  `tests/testthat/test-central-format.R`.

# odkmerge 0.1.0

* Initial release.
* `odk_merge()`: one-call wrapper that reads an ODK / KoboToolbox `.xlsx`
  export and returns flat, analysis-ready tibbles.
* `read_odk_export()`: reads every sheet of an export as a named list of
  tibbles.
* `detect_structure()`: classifies sheets as parent vs. repeat and builds
  the parent->child hierarchy; returns an `odk_structure` S3 object with a
  `print` method.
* `build_master()`: joins repeat sheets up to the root parent. Handles
  simple, multi-repeat (sibling), and nested-repeat structures.
* `enrich_repeat()`: adds selected parent columns into a single repeat
  sheet.
* Bundled fixture exports in `inst/extdata/`: `simple_survey.xlsx`,
  `multi_repeat_survey.xlsx`, `nested_survey.xlsx`.
* Getting-started vignette covering all three structural patterns.
