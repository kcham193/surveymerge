# R/enrich_repeat.R

#' Enrich a repeat sheet with columns from its parent sheet
#'
#' @description
#' Adds selected columns from the parent sheet into a repeat (child) sheet,
#' joining on the standard ODK index columns. The result is a self-contained
#' tibble that can be analysed without needing to reference the parent sheet
#' separately.
#'
#' @param sheets A named list of tibbles as returned by [read_odk_export()].
#' @param repeat_sheet_name A length-1 character string. The name of the repeat
#'   sheet to enrich. Must be a key in `sheets`.
#' @param parent_cols A character vector of column names to bring across from
#'   the parent sheet. If `NULL` (the default), all non-internal columns are
#'   used (i.e. everything that does not start with `_submission_`).
#' @param drop_internal Logical. If `TRUE` (the default), columns starting with
#'   `_submission_` are removed from the repeat sheet before enrichment.
#' @param suffix A length-2 character vector of suffixes appended to
#'   disambiguate column names that exist in both sheets. Passed to
#'   [dplyr::left_join()]. Default: `c("_repeat", "_parent")`.
#'
#' @return A tibble: the repeat sheet with parent columns added on the right.
#'   Row count is unchanged (left join).
#'
#' @examples
#' path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
#' sheets <- read_odk_export(path)
#' enriched <- enrich_repeat(sheets, repeat_sheet_name = "species",
#'                            parent_cols = c("plot_id", "observer"))
#' colnames(enriched)
#'
#' @export
enrich_repeat <- function(sheets,
                           repeat_sheet_name,
                           parent_cols   = NULL,
                           drop_internal = TRUE,
                           suffix        = c("_repeat", "_parent")) {

  # --- validate inputs ------------------------------------------------------
  if (!is.list(sheets) || is.null(names(sheets))) {
    cli::cli_abort(c(
      "{.arg sheets} must be a named list.",
      ">" = "Use {.fn read_odk_export} to read your file first."
    ))
  }

  if (!is.character(repeat_sheet_name) || length(repeat_sheet_name) != 1L) {
    cli::cli_abort("{.arg repeat_sheet_name} must be a single character string.")
  }

  if (!repeat_sheet_name %in% names(sheets)) {
    cli::cli_abort(c(
      "Sheet {.val {repeat_sheet_name}} not found.",
      "x" = "Available sheets: {.val {names(sheets)}}.",
      ">" = "Check the spelling of {.arg repeat_sheet_name}."
    ))
  }

  repeat_df <- sheets[[repeat_sheet_name]]

  if (!.is_repeat_sheet(repeat_df)) {
    cli::cli_abort(c(
      "{.val {repeat_sheet_name}} does not appear to be a repeat sheet.",
      "x" = "It has no {.val _parent_index} column.",
      ">" = "Use {.fn detect_structure} to identify which sheets are repeats."
    ))
  }

  # --- find parent sheet ----------------------------------------------------
  structure_info <- detect_structure(sheets)
  parent_name    <- structure_info$direct_parent[[repeat_sheet_name]]
  parent_df      <- sheets[[parent_name]]

  # Resolve the parent's index column (Kobo: `_index`, Central: `KEY`)
  parent_index_col <- .odk_index_col(parent_df)

  # --- select parent columns ------------------------------------------------
  if (is.null(parent_cols)) {
    # All non-submission columns from the parent
    parent_cols <- setdiff(
      colnames(.drop_submission_cols(parent_df)),
      character(0)
    )
  } else {
    missing_cols <- setdiff(parent_cols, colnames(parent_df))
    if (length(missing_cols) > 0L) {
      cli::cli_warn(c(
        "Some requested {.arg parent_cols} were not found in {.val {parent_name}}.",
        "!" = "Missing: {.val {missing_cols}}.",
        "i" = "These columns will be ignored."
      ))
      parent_cols <- intersect(parent_cols, colnames(parent_df))
    }
  }

  # Ensure the parent's index column is included for the join key
  parent_cols <- union(parent_index_col, parent_cols)

  parent_slim <- parent_df[, parent_cols, drop = FALSE]

  # Rename the parent's index column to a temp key to avoid collision
  # with the repeat sheet's own index column (which may have the same name
  # in Kobo's `_index` vs `_index` situation).
  colnames(parent_slim)[colnames(parent_slim) == parent_index_col] <- ".join_key_"

  # --- optionally drop submission cols from repeat --------------------------
  if (drop_internal) repeat_df <- .drop_submission_cols(repeat_df)

  # --- join -----------------------------------------------------------------
  pidx_col     <- .odk_parent_index_col(repeat_df)
  cols_before  <- ncol(repeat_df)

  enriched <- dplyr::left_join(
    repeat_df,
    parent_slim,
    by     = stats::setNames(".join_key_", pidx_col),
    suffix = suffix
  )

  cols_added <- ncol(enriched) - cols_before

  cli::cli_alert_info(
    "Enriched {.val {repeat_sheet_name}}: \\
     {nrow(enriched)} row{?s}, \\
     {cols_added} column{?s} added from {.val {parent_name}} \\
     (join key: {.val {pidx_col}} \u2194 {.val {parent_index_col}})."
  )

  enriched
}
