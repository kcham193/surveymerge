# R/utils.R
# Internal helper functions. None of these are exported.
# All start with `.` per convention for private package functions.

# ---------------------------------------------------------------------------
# .odk_index_col
# ---------------------------------------------------------------------------
#' @noRd
.odk_index_col <- function(df) {
  nms <- colnames(df)

  # Prefer exact match first
  if ("_index" %in% nms) return("_index")

  # Fall back to case-insensitive match
  hit <- nms[tolower(nms) == "index"]
  if (length(hit) == 1L) return(hit)

  cli::cli_abort(c(
    "Cannot find an index column in this sheet.",
    "x" = "Expected a column named {.val _index}.",
    "i" = "Columns present: {.val {nms}}.",
    ">" = "Check that the file is a valid ODK/KoboToolbox export."
  ))
}

# ---------------------------------------------------------------------------
# .odk_parent_index_col
# ---------------------------------------------------------------------------
#' @noRd
.odk_parent_index_col <- function(df) {
  nms <- colnames(df)

  if ("_parent_index" %in% nms) return("_parent_index")

  cli::cli_abort(c(
    "Cannot find a parent-index column in this sheet.",
    "x" = "Expected a column named {.val _parent_index}.",
    "i" = "Columns present: {.val {nms}}.",
    ">" = "This sheet may not be a repeat sheet. Use {.fn detect_structure} to inspect the file."
  ))
}

# ---------------------------------------------------------------------------
# .odk_parent_table_col
# ---------------------------------------------------------------------------
#' @noRd
.odk_parent_table_col <- function(df) {
  nms <- colnames(df)
  if ("_parent_table_name" %in% nms) return("_parent_table_name")
  NULL  # absence is not an error; caller handles NULL gracefully
}

# ---------------------------------------------------------------------------
# .is_repeat_sheet
# ---------------------------------------------------------------------------
#' @noRd
.is_repeat_sheet <- function(df) {
  "_parent_index" %in% colnames(df)
}

# ---------------------------------------------------------------------------
# .drop_submission_cols
# ---------------------------------------------------------------------------
#' @noRd
.drop_submission_cols <- function(df) {
  drop <- grep("^_submission_", colnames(df), value = TRUE)
  if (length(drop) == 0L) return(df)
  df[, setdiff(colnames(df), drop), drop = FALSE]
}

# ---------------------------------------------------------------------------
# .safe_suffix
# ---------------------------------------------------------------------------
#' @noRd
.safe_suffix <- function(name, suffix, existing_names) {
  # Only append suffix when the name would collide with something already there
  if (name %in% existing_names) paste0(name, suffix) else name
}
