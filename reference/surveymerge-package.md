# surveymerge: work with relational survey exports and repeat groups

`surveymerge` helps analysts make sense of XLSForm-based survey exports
(ODK Central, KoboToolbox, and other compatible platforms) that contain
repeat groups and nested repeat groups.

The package is **not** about reflexively flattening every sheet into one
table. Repeat groups exist because surveys are inherently relational: a
household has members, a farm has fields, a clinic visit has lab
measurements. Forcing all of those levels into a single wide row is
often statistically inappropriate. `surveymerge` instead helps you:

- Inspect the parent-child structure of an export.

- Build datasets that match the **unit of analysis** you actually care
  about (household-level, individual-level, visit-level, event-level,
  ...).

- Bring parent context into child rows when needed, without losing
  information about the relationship.

## Where to start

- [`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md) -
  the one-call wrapper that returns one dataset per repeat group, with
  all ancestor columns joined in.

- [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md)
  /
  [`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md)
  /
  [`build_master()`](https://kcham193.github.io/surveymerge/reference/build_master.md)
  /
  [`enrich_repeat()`](https://kcham193.github.io/surveymerge/reference/enrich_repeat.md) -
  the step-by-step workflow when you need finer control over which level
  you assemble.

## See also

Useful links:

- <https://github.com/kcham193/surveymerge>

- <https://kcham193.github.io/surveymerge/>

- Report bugs at <https://github.com/kcham193/surveymerge/issues>

## Author

**Maintainer**: Kasim Chambulilo <kassimchambulilo@gmail.com>

Authors:

- Kasim Chambulilo <kassimchambulilo@gmail.com>
