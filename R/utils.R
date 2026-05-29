# R/utils.R
# Internal helper functions. None of these are exported.
# All start with `.` per convention for private package functions.
#
# Two export conventions are supported:
#   * KoboToolbox  : `_index`, `_parent_index`, `_parent_table_name`,
#                    `_submission_*` columns.
#   * ODK Central  : `KEY`, `PARENT_KEY`, plus submission/metadata columns
#                    like `SubmitterID`, `SubmissionDate`, `Status`, ...
#
# Provenance of the ODK Central column names
# -------------------------------------------
# The literal header strings (`KEY`, `PARENT_KEY`, `SubmissionDate`,
# `SubmitterID`, `SubmitterName`, `AttachmentsPresent`,
# `AttachmentsExpected`, `Status`, `ReviewState`, `DeviceID`, `Edits`,
# `FormVersion`) are taken directly from ODK Central's Briefcase-style
# CSV/XLSX exporter:
#
#   https://github.com/getodk/central-backend/blob/master/lib/data/briefcase.js
#
# Each of those names is `header.push('...')`-ed in that file. The
# row-identifier column is `KEY`, the parent-reference column in a
# repeat sheet is `PARENT_KEY`, and the 10 system columns above are
# the per-submission metadata that Central appends to the root sheet.
# Note: ODK Central does NOT emit `instanceID` / `meta-instanceID` as
# column headers -- the submission UUID is encoded as the value of the
# `KEY` column itself.

# ---------------------------------------------------------------------------
# Constants: known system column names for each format
# ---------------------------------------------------------------------------
#' @noRd
.odk_index_candidates <- function() {
  c("_index", "KEY")
}

#' @noRd
.odk_parent_index_candidates <- function() {
  c("_parent_index", "PARENT_KEY")
}

#' @noRd
.odk_parent_table_candidates <- function() {
  # Kobo writes the parent sheet name into this column.
  # ODK Central does not have a direct equivalent; we infer parent linkage
  # from index values when this column is absent.
  c("_parent_table_name")
}

#' @noRd
.odk_central_submission_cols <- function() {
  # System columns added by ODK Central to the main (parent) sheet.
  c(
    "SubmissionDate", "SubmitterID", "SubmitterName",
    "AttachmentsPresent", "AttachmentsExpected",
    "Status", "ReviewState", "DeviceID", "Edits",
    "FormVersion"
  )
}

# ---------------------------------------------------------------------------
# .odk_index_col -- finds the row-identifier column
# ---------------------------------------------------------------------------
#' @noRd
.odk_index_col <- function(df) {
  nms <- colnames(df)

  # Exact match first (handles both conventions)
  for (cand in .odk_index_candidates()) {
    if (cand %in% nms) return(cand)
  }

  # Case-insensitive fallback for slight variations (`index`, `Key`, etc.)
  lower <- tolower(nms)
  for (cand in c("index", "key")) {
    hit <- nms[lower == cand]
    if (length(hit) == 1L) return(hit)
  }

  cli::cli_abort(c(
    "Cannot find an index column in this sheet.",
    "x" = "Expected one of {.val _index} (KoboToolbox) or {.val KEY} (ODK Central).",
    "i" = "Columns present: {.val {nms}}.",
    ">" = "Check that the file is a valid ODK Central or KoboToolbox export."
  ))
}

# ---------------------------------------------------------------------------
# .odk_parent_index_col -- finds the parent-reference column in a repeat
# ---------------------------------------------------------------------------
#' @noRd
.odk_parent_index_col <- function(df) {
  nms <- colnames(df)

  for (cand in .odk_parent_index_candidates()) {
    if (cand %in% nms) return(cand)
  }

  cli::cli_abort(c(
    "Cannot find a parent-index column in this sheet.",
    "x" = "Expected one of {.val _parent_index} (KoboToolbox) or {.val PARENT_KEY} (ODK Central).",
    "i" = "Columns present: {.val {nms}}.",
    ">" = "This sheet may not be a repeat sheet. Use {.fn detect_structure} to inspect the file."
  ))
}

# ---------------------------------------------------------------------------
# .odk_parent_table_col -- optional column naming the parent sheet
# ---------------------------------------------------------------------------
#' @noRd
.odk_parent_table_col <- function(df) {
  nms <- colnames(df)
  for (cand in .odk_parent_table_candidates()) {
    if (cand %in% nms) return(cand)
  }
  NULL  # absence is not an error; caller handles NULL gracefully
}

# ---------------------------------------------------------------------------
# .is_repeat_sheet -- a sheet is a repeat iff it carries a parent-index col
# ---------------------------------------------------------------------------
#' @noRd
.is_repeat_sheet <- function(df) {
  any(.odk_parent_index_candidates() %in% colnames(df))
}

# ---------------------------------------------------------------------------
# .detect_format -- classify a sheet's column convention
# ---------------------------------------------------------------------------
# Returns "kobo", "central", or "unknown".
#' @noRd
.detect_format <- function(df) {
  nms <- colnames(df)
  has_kobo    <- any(c("_index", "_parent_index") %in% nms)
  has_central <- any(c("KEY", "PARENT_KEY") %in% nms)
  if (has_kobo && !has_central)    return("kobo")
  if (has_central && !has_kobo)    return("central")
  if (has_kobo && has_central)     return("kobo")     # Kobo wins on mixed
  "unknown"
}

# ---------------------------------------------------------------------------
# .drop_submission_cols -- strip system/submission metadata columns
# ---------------------------------------------------------------------------
#' @noRd
.drop_submission_cols <- function(df) {
  nms <- colnames(df)

  # Kobo: anything matching ^_submission_
  kobo_drop <- grep("^_submission_", nms, value = TRUE)

  # Central: explicit list of known system columns
  central_drop <- intersect(.odk_central_submission_cols(), nms)

  drop <- unique(c(kobo_drop, central_drop))
  if (length(drop) == 0L) return(df)
  df[, setdiff(nms, drop), drop = FALSE]
}

# ---------------------------------------------------------------------------
# .safe_suffix -- append suffix only when there is a name collision
# ---------------------------------------------------------------------------
#' @noRd
.safe_suffix <- function(name, suffix, existing_names) {
  if (name %in% existing_names) paste0(name, suffix) else name
}
