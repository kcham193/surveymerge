# Changelog

## surveymerge 0.2.0

This is the rebranded and repositioned successor of `odkmerge` 0.1.0.
The underlying join engine is unchanged; the package name, public
function names, and documentation have been updated.

### Breaking changes (with backward-compatible aliases)

- The package has been renamed from **odkmerge** to **surveymerge** to
  avoid trademark concerns and reflect a broader positioning around
  relational survey exports rather than ODK specifically.
- [`odk_merge()`](https://kcham193.github.io/surveymerge/reference/odk_merge.md)
  is now
  [`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md).
  The old name still works but emits a one-time deprecation warning and
  will be removed in a future release.
- [`read_odk_export()`](https://kcham193.github.io/surveymerge/reference/read_odk_export.md)
  is now
  [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md),
  with the same back-compatible alias and deprecation warning.
- The S3 class on the object returned by
  [`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
  is now `survey_structure` (the `odk_structure` class tag is also
  attached so any user code that dispatches on the old class keeps
  working).

### Repositioning

- The package is no longer described as a tool that simply *flattens*
  every sheet into one table. The new framing in the README, vignette,
  and function documentation emphasises that the correct output of a
  merge depends on the intended **unit of analysis** (household,
  individual, visit, event, etc.) and that users should pick or assemble
  datasets accordingly.
- A new conceptual section, *Understanding units of analysis*, has been
  added to the README and the getting-started vignette.

### No functional changes

- All input/output behaviour of the join engine is preserved.
- All existing test fixtures continue to be shipped.
- All four functions
  ([`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md),
  [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md),
  [`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md),
  [`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md),
  [`enrich_repeat()`](https://kcham193.github.io/surveymerge/reference/enrich_repeat.md))
  accept the same arguments and return the same shapes as in 0.1.0.
