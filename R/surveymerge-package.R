# R/surveymerge-package.R

#' surveymerge: work with relational survey exports and repeat groups
#'
#' @description
#' `surveymerge` helps analysts make sense of XLSForm-based survey exports
#' (ODK Central, KoboToolbox, and other compatible platforms) that contain
#' repeat groups and nested repeat groups.
#'
#' The package is **not** about reflexively flattening every sheet into one
#' table. Repeat groups exist because surveys are inherently relational:
#' a household has members, a farm has fields, a clinic visit has lab
#' measurements. Forcing all of those levels into a single wide row is
#' often statistically inappropriate. `surveymerge` instead helps you:
#'
#' - Inspect the parent-child structure of an export.
#' - Build datasets that match the **unit of analysis** you actually care
#'   about (household-level, individual-level, visit-level, event-level, ...).
#' - Bring parent context into child rows when needed, without losing
#'   information about the relationship.
#'
#' @section Where to start:
#'
#' * [survey_merge()] - the one-call wrapper that returns one dataset per
#'   repeat group, with all ancestor columns joined in.
#' * [read_survey_export()] / [detect_structure()] / [build_master()] /
#'   [enrich_repeat()] - the step-by-step workflow when you need finer
#'   control over which level you assemble.
#'
#' @keywords internal
"_PACKAGE"

## Suppress "no visible binding for global variable" R CMD check notes
## that arise from dplyr's non-standard evaluation.
utils::globalVariables(c(
  ".",
  ".join_key_"
))
