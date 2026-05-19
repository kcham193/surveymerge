# R/build_master.R

#' Build a flat master dataset from ODK repeat-group sheets
#'
#' @description
#' Merges all repeat sheets with their parent sheet(s) to produce flat,
#' analysis-ready tibbles. Handles three structural patterns automatically:
#'
#' - **Simple** (one repeat sheet): returns a single tibble.
#' - **Multi-repeat** (multiple sibling repeat sheets): returns a named list
#'   of tibbles, one per repeat sheet.
#' - **Nested repeats** (a repeat inside another repeat): recursively joins
#'   bottom-up and returns a single flat tibble per chain.
#'
#' @param sheets A named list of tibbles as returned by [read_odk_export()].
#' @param structure Optional. An `odk_structure` object from
#'   [detect_structure()]. If `NULL` (the default), `detect_structure()` is
#'   called internally.
#' @param drop_internal Logical. If `TRUE` (the default), columns starting with
#'   `_submission_` are removed from repeat sheets before joining.
#' @param suffix A length-2 character vector of suffixes for column-name
#'   collisions. Default: `c("_repeat", "_parent")`.
#' @param nest_sep A length-1 character string used as separator when renaming
#'   columns that originate from an intermediate (non-root) level during nested
#'   joins. Default: `"__"`.
#'
#' @return
#' - A single tibble when there is exactly one repeat sheet.
#' - A named list of tibbles when there are multiple repeat sheets.
#'
#' @examples
#' path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
#' sheets <- read_odk_export(path)
#' master <- build_master(sheets)
#' nrow(master)   # 40 (number of species rows)
#'
#' @export
build_master <- function(sheets,
                          structure     = NULL,
                          drop_internal = TRUE,
                          suffix        = c("_repeat", "_parent"),
                          nest_sep      = "__") {

  # --- validate inputs ------------------------------------------------------
  if (!is.list(sheets) || is.null(names(sheets))) {
    cli::cli_abort(c(
      "{.arg sheets} must be a named list.",
      ">" = "Use {.fn read_odk_export} to read your file first."
    ))
  }

  if (is.null(structure)) {
    structure <- detect_structure(sheets)
  }

  if (length(structure$repeat_sheets) == 0L) {
    cli::cli_alert_warning("No repeat sheets found. Returning the parent sheet unchanged.")
    return(sheets[[structure$parent_sheet]])
  }

  # --- build one flat frame per repeat sheet --------------------------------
  # We process every repeat sheet, joining it upward through its ancestry
  # until we reach the root parent.
  results <- purrr::map(
    purrr::set_names(structure$repeat_sheets),
    function(sn) {
      .join_to_root(
        repeat_name   = sn,
        sheets        = sheets,
        structure     = structure,
        drop_internal = drop_internal,
        suffix        = suffix,
        nest_sep      = nest_sep
      )
    }
  )

  # --- return single tibble or named list -----------------------------------
  if (length(results) == 1L) {
    return(results[[1L]])
  }

  results
}


# ---------------------------------------------------------------------------
# Internal: join one repeat sheet all the way up to the root parent
# ---------------------------------------------------------------------------
#' @noRd
.join_to_root <- function(repeat_name, sheets, structure,
                           drop_internal, suffix, nest_sep) {

  repeat_df <- sheets[[repeat_name]]

  if (drop_internal) repeat_df <- .drop_submission_cols(repeat_df)

  # Walk up the ancestry chain until we reach the root
  current_df   <- repeat_df
  current_name <- repeat_name
  visited      <- character(0)

  repeat {
    parent_name <- structure$direct_parent[[current_name]]

    if (is.null(parent_name)) break  # already at root

    parent_df <- sheets[[parent_name]]
    if (drop_internal) parent_df <- .drop_submission_cols(parent_df)

    pidx_col <- .odk_parent_index_col(current_df)
    pindex   <- .odk_index_col(parent_df)

    # Rename parent _index to a temp join key to avoid collision
    join_key <- paste0(".join_", parent_name, "_")
    colnames(parent_df)[colnames(parent_df) == pindex] <- join_key

    current_df <- dplyr::left_join(
      current_df,
      parent_df,
      by     = stats::setNames(join_key, pidx_col),
      suffix = suffix
    )

    visited      <- c(visited, current_name)
    current_name <- parent_name

    # Stop when we've reached the root parent
    if (current_name == structure$parent_sheet) break
  }

  n_unique_parents <- tryCatch(
    dplyr::n_distinct(current_df[[structure$index_cols[[structure$parent_sheet]]]],
                      na.rm = TRUE),
    error = function(e) NA_integer_
  )

  cli::cli_alert_success(
    "Built master for {.val {repeat_name}}: \\
     {nrow(current_df)} row{?s}, \\
     {ncol(current_df)} column{?s}, \\
     {n_unique_parents} unique parent record{?s}."
  )

  current_df
}
