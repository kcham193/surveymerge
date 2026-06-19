# R/read_survey.R

#' Read a relational survey export (XLSForm `.xlsx`)
#'
#' @description
#' Reads every sheet from an `.xlsx` export produced by an XLSForm-based
#' survey platform (ODK Central, KoboToolbox, or any tool that follows the
#' same conventions) and returns them as a named list of tibbles. This list
#' is the entry point for all the other `surveymerge` functions.
#'
#' The function does **not** make any decision about how the sheets relate
#' to one another or which one is your unit of analysis - that is what
#' [detect_structure()] and [build_master()] are for. It simply gives you
#' faithful, per-sheet access to the export.
#'
#' @param file_path A length-1 character string giving the path to the
#'   `.xlsx` file.
#' @param col_types A character vector passed to [readxl::read_excel()] to
#'   control column-type parsing. Applied identically to every sheet. Set
#'   `NULL` (the default) to let `readxl` guess types automatically.
#' @param ... Additional arguments passed to [readxl::read_excel()] for each
#'   sheet (e.g. `na`, `trim_ws`).
#'
#' @return
#' A named list of tibbles, one per sheet. Names match the sheet names in
#' the source file. Each tibble preserves the original columns, including
#' the `_index` / `_parent_index` (KoboToolbox) or `KEY` / `PARENT_KEY`
#' (ODK Central) columns that downstream functions use to reconstruct
#' parent-child relationships.
#'
#' @section What this means for analysis:
#' The returned list represents the raw relational structure of your
#' survey. Each sheet has its own grain (one row per household, one row
#' per member, one row per visit, ...). Treat it as a *family of related
#' tables*, not a single dataset.
#'
#' @examples
#' path   <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
#' sheets <- read_survey_export(path)
#' names(sheets)   # "survey" "species"
#'
#' @export
read_survey_export <- function(file_path, col_types = NULL, ...) {

  # --- validate input -------------------------------------------------------
  if (!is.character(file_path) || length(file_path) != 1L) {
    cli::cli_abort(c(
      "{.arg file_path} must be a single character string.",
      "x" = "Got an object of class {.cls {class(file_path)}} with length {length(file_path)}."
    ))
  }

  if (!file.exists(file_path)) {
    cli::cli_abort(c(
      "File not found.",
      "x" = "{.path {file_path}} does not exist.",
      ">" = "Check the path and try again."
    ))
  }

  if (!grepl("\\.xlsx$", file_path, ignore.case = TRUE)) {
    cli::cli_abort(c(
      "Only {.val .xlsx} files are supported.",
      "x" = "{.path {file_path}} does not end with {.val .xlsx}.",
      ">" = "Export your survey data as an Excel (.xlsx) file."
    ))
  }

  # --- read all sheets ------------------------------------------------------
  sheet_names <- readxl::excel_sheets(file_path)

  sheets <- purrr::map(
    purrr::set_names(sheet_names),
    function(sn) {
      readxl::read_excel(
        path      = file_path,
        sheet     = sn,
        col_types = col_types,
        ...
      )
    }
  )

  cli::cli_alert_success(
    "Read {length(sheets)} sheet{?s} from {.path {file_path}}: \\
     {.val {sheet_names}}."
  )

  sheets
}
