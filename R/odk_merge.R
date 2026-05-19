# R/odk_merge.R

#' Merge an ODK or KoboToolbox export into a flat dataset
#'
#' @description
#' The main entry point for `odkmerge`. Reads an `.xlsx` export, detects the
#' repeat-group structure, and returns a flat, analysis-ready dataset — all in
#' one call.
#'
#' Internally this function runs:
#' [read_odk_export()] → [detect_structure()] → [build_master()].
#'
#' For more control over any step, call those functions individually.
#'
#' @param file_path A length-1 character string giving the path to the `.xlsx`
#'   file exported from ODK or KoboToolbox.
#' @param drop_internal Logical. If `TRUE` (the default), columns starting with
#'   `_submission_` are removed from repeat sheets before merging.
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
#' - A single tibble when the file contains exactly one repeat sheet.
#' - A named list of tibbles when the file contains multiple repeat sheets
#'   (one tibble per repeat group).
#'
#' @examples
#' path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
#' master <- odk_merge(path)
#' head(master)
#'
#' @export
odk_merge <- function(file_path,
                       drop_internal = TRUE,
                       col_types     = NULL,
                       suffix        = c("_repeat", "_parent"),
                       verbose       = TRUE,
                       ...) {

  run <- function() {
    sheets    <- read_odk_export(file_path, col_types = col_types, ...)
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
