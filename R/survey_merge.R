# R/survey_merge.R

#' Read and assemble analysis-ready datasets from a survey export
#'
#' @description
#' The one-call wrapper for `surveymerge`. Reads an `.xlsx` export, detects
#' the parent-child sheet structure, and returns a dataset (or one dataset
#' per repeat group) at the appropriate **unit of analysis**.
#'
#' Internally this function runs:
#' [read_survey_export()] -> [detect_structure()] -> [build_master()].
#'
#' For more control over any step - especially the choice of which repeat
#' grain to use and which parent columns to carry across - call those
#' functions individually, or use [enrich_repeat()].
#'
#' @param file_path A length-1 character string giving the path to the
#'   `.xlsx` file exported from ODK Central, KoboToolbox, or another
#'   XLSForm-based survey platform.
#' @param drop_internal Logical. If `TRUE` (the default), columns starting
#'   with `_submission_` (KoboToolbox) and ODK Central's system columns
#'   are removed before merging.
#' @param col_types A character vector passed to [readxl::read_excel()] to
#'   control column-type parsing. `NULL` (default) lets `readxl` guess.
#' @param suffix A length-2 character vector of suffixes appended to
#'   disambiguate column names that appear in more than one sheet.
#'   Default: `c("_repeat", "_parent")`.
#' @param verbose Logical. If `FALSE`, all informational messages are
#'   suppressed. Default: `TRUE`.
#' @param ... Additional arguments forwarded to [readxl::read_excel()].
#'
#' @return
#' - A single tibble when the file contains exactly one repeat sheet
#'   (one row per repeat record, with parent columns attached).
#' - A named list of tibbles when the file contains multiple repeat sheets
#'   - **one tibble per unit of analysis**. Sibling repeats live at
#'   different grains, so they are kept as separate tibbles rather than
#'   blindly stacked together.
#'
#' @section What this means for analysis:
#' The output is shaped by the *structure* of your survey, not by an
#' assumption about your analysis. Before using the result, pick the
#' tibble whose grain matches your research question:
#'
#' - Household-level descriptive statistics -> use the parent sheet
#'   directly (`read_survey_export(path)[[structure$parent_sheet]]`) or
#'   [enrich_repeat()] with parent-level aggregates.
#' - Individual / member-level analysis -> use the `members` tibble.
#' - Visit / event-level analysis -> use the corresponding leaf-grain
#'   tibble.
#'
#' Pooling tibbles across grains inflates record counts; the package
#' deliberately does not do this for you.
#'
#' @examples
#' path   <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
#' master <- survey_merge(path)
#' head(master)
#'
#' @export
survey_merge <- function(file_path,
                          drop_internal = TRUE,
                          col_types     = NULL,
                          suffix        = c("_repeat", "_parent"),
                          verbose       = TRUE,
                          ...) {

  run <- function() {
    sheets    <- read_survey_export(file_path, col_types = col_types, ...)
    structure <- detect_structure(sheets)
    build_master(
      sheets        = sheets,
      structure     = structure,
      drop_internal = drop_internal,
      suffix        = suffix
    )
  }

  if (isTRUE(verbose)) {
    run()
  } else {
    suppressMessages(run())
  }
}
