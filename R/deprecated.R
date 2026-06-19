# R/deprecated.R
# Backward-compatible aliases for functions renamed in the odkmerge ->
# surveymerge transition (v0.2.0). Each wrapper emits a one-time
# deprecation warning, then forwards every argument to the new function.

# Track which deprecation warnings we have already emitted in this session,
# so users see each message once and not on every call inside a loop.
.surveymerge_deprecation_state <- new.env(parent = emptyenv())

#' @noRd
.warn_deprecated_once <- function(old, new) {
  key <- paste0(old, "->", new)
  if (isTRUE(.surveymerge_deprecation_state[[key]])) return(invisible())
  .surveymerge_deprecation_state[[key]] <- TRUE
  warning(
    sprintf(
      "`%s()` is deprecated as of surveymerge 0.2.0. Please use `%s()` instead.",
      old, new
    ),
    call. = FALSE
  )
}

#' Merge a survey export (deprecated; use `survey_merge()`)
#'
#' @description
#' `r lifecycle <- "Deprecated since surveymerge 0.2.0."`
#' `r lifecycle`
#'
#' Backward-compatible alias for [survey_merge()] retained from the
#' previous `odkmerge` release. New code should call [survey_merge()]
#' directly.
#'
#' @inheritParams survey_merge
#'
#' @return The same value as [survey_merge()].
#'
#' @examples
#' path <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
#' suppressWarnings(master <- odk_merge(path, verbose = FALSE))
#' head(master)
#'
#' @export
odk_merge <- function(file_path,
                       drop_internal = TRUE,
                       col_types     = NULL,
                       suffix        = c("_repeat", "_parent"),
                       verbose       = TRUE,
                       ...) {
  .warn_deprecated_once("odk_merge", "survey_merge")
  survey_merge(
    file_path     = file_path,
    drop_internal = drop_internal,
    col_types     = col_types,
    suffix        = suffix,
    verbose       = verbose,
    ...
  )
}

#' Read a survey export (deprecated; use `read_survey_export()`)
#'
#' @description
#' Backward-compatible alias for [read_survey_export()] retained from
#' the previous `odkmerge` release. New code should call
#' [read_survey_export()] directly.
#'
#' @inheritParams read_survey_export
#'
#' @return The same value as [read_survey_export()].
#'
#' @examples
#' path <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
#' suppressWarnings(sheets <- read_odk_export(path))
#' names(sheets)
#'
#' @export
read_odk_export <- function(file_path, col_types = NULL, ...) {
  .warn_deprecated_once("read_odk_export", "read_survey_export")
  read_survey_export(file_path = file_path, col_types = col_types, ...)
}
