# R/detect_structure.R

#' Detect the parent-child sheet structure of a survey export
#'
#' @description
#' Inspects a named list of tibbles (as returned by [read_survey_export()])
#' and identifies which sheets are parent sheets and which are repeat-group
#' sheets, together with the hierarchy that links them.
#'
#' Use this before any merge: it tells you which **units of analysis** are
#' actually present in your export. A simple form yields one parent and one
#' child level; a complex form can yield three or more levels (e.g. farm ->
#' field -> observation), each of which is a legitimate unit of analysis in
#' its own right.
#'
#' @param sheets A named list of tibbles as returned by [read_survey_export()].
#'
#' @return
#' An object of class `c("survey_structure", "odk_structure")` - a list with
#' the following components:
#' \describe{
#'   \item{`parent_sheet`}{Character. Name of the root/parent sheet.}
#'   \item{`repeat_sheets`}{Character vector of repeat sheet names. Empty
#'     (`character(0)`) if no repeats are present.}
#'   \item{`tree`}{A nested named list representing the parent->child
#'     hierarchy. E.g. `list(survey = "species")` for a simple structure,
#'     or `list(farm = list(field = "observation"))` for nested repeats.}
#'   \item{`index_cols`}{Named list mapping every sheet name to its index
#'     column name.}
#'   \item{`parent_index_cols`}{Named list mapping every repeat sheet to its
#'     parent-index column name.}
#' }
#'
#' The legacy `odk_structure` class is also attached so any user code that
#' dispatched on objects from the previous package version keeps working.
#'
#' @section What this means for analysis:
#' Each entry in `repeat_sheets` corresponds to a candidate **unit of
#' analysis**. For example, in a household survey with a `members` repeat,
#' "household-level" analysis lives in `parent_sheet`, while
#' "individual-level" analysis lives in the `members` repeat (typically
#' enriched with selected household columns, not the whole parent flattened
#' in). [build_master()] and [enrich_repeat()] let you assemble either.
#'
#' @examples
#' path      <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
#' sheets    <- read_survey_export(path)
#' structure <- detect_structure(sheets)
#' print(structure)
#'
#' @export
detect_structure <- function(sheets) {

  if (!is.list(sheets) || is.null(names(sheets))) {
    cli::cli_abort(c(
      "{.arg sheets} must be a named list.",
      ">" = "Use {.fn read_survey_export} to read your file first."
    ))
  }

  sheet_names <- names(sheets)

  # --- classify sheets as parent or repeat ----------------------------------
  is_repeat <- purrr::map_lgl(sheets, .is_repeat_sheet)
  repeat_names <- sheet_names[is_repeat]
  parent_names <- sheet_names[!is_repeat]

  if (length(repeat_names) == 0L) {
    warning(
      "No repeat sheets detected. All sheets lack a '_parent_index' column.",
      call. = FALSE
    )
  }

  if (length(parent_names) == 0L) {
    cli::cli_abort(c(
      "No parent sheet found - every sheet has a {.val _parent_index} column.",
      ">" = "Check that the file is a valid survey export."
    ))
  }

  # Use the first non-repeat sheet as the root parent
  root_parent <- parent_names[1L]

  # --- collect index columns ------------------------------------------------
  index_cols <- purrr::map(
    purrr::set_names(sheet_names),
    function(sn) .survey_index_col(sheets[[sn]])
  )

  parent_index_cols <- purrr::map(
    purrr::set_names(repeat_names),
    function(sn) .survey_parent_index_col(sheets[[sn]])
  )

  # --- build parent lookup: repeat sheet -> its direct parent sheet name ---
  # Uses _parent_table_name if present; otherwise infers by matching parent
  # index values to parent sheet index values.
  direct_parent <- purrr::map_chr(
    purrr::set_names(repeat_names),
    function(sn) {
      ptbl_col <- .survey_parent_table_col(sheets[[sn]])

      if (!is.null(ptbl_col)) {
        # Grab the first non-NA value from _parent_table_name
        vals <- unique(sheets[[sn]][[ptbl_col]])
        vals <- vals[!is.na(vals)]
        if (length(vals) >= 1L && vals[1L] %in% sheet_names) {
          return(vals[1L])
        }
      }

      # Fallback: find which sheet's _index values contain all _parent_index
      # values of this repeat sheet
      pidx_col <- parent_index_cols[[sn]]
      repeat_pidx <- unique(sheets[[sn]][[pidx_col]])

      for (candidate in sheet_names[sheet_names != sn]) {
        if (.survey_index_col(sheets[[candidate]]) %in% colnames(sheets[[candidate]])) {
          cidx <- sheets[[candidate]][[.survey_index_col(sheets[[candidate]])]]
          if (all(repeat_pidx %in% cidx)) {
            return(candidate)
          }
        }
      }

      # If nothing matches, default to root parent
      root_parent
    }
  )

  # --- build tree (recursive named list) ------------------------------------
  tree <- .build_tree(root_parent, direct_parent, repeat_names)

  structure(
    list(
      parent_sheet      = root_parent,
      repeat_sheets     = repeat_names,
      tree              = tree,
      index_cols        = index_cols,
      parent_index_cols = parent_index_cols,
      direct_parent     = direct_parent      # kept internally for build_master
    ),
    # The legacy `odk_structure` class is retained so any user code that
    # dispatches on objects from the previous package version keeps working.
    class = c("survey_structure", "odk_structure")
  )
}

# ---------------------------------------------------------------------------
# Internal: recursively build parent->child tree
# ---------------------------------------------------------------------------
#' @noRd
.build_tree <- function(node, direct_parent, repeat_names) {
  children <- names(direct_parent)[direct_parent == node]

  if (length(children) == 0L) {
    return(node)  # leaf node
  }

  kids <- purrr::map(
    purrr::set_names(children),
    function(ch) .build_tree(ch, direct_parent, repeat_names)
  )

  stats::setNames(list(kids), node)
}

# ---------------------------------------------------------------------------
# S3 print methods
# ---------------------------------------------------------------------------

#' Print a survey_structure object
#'
#' @description
#' Pretty-prints the parent-child hierarchy detected by [detect_structure()],
#' showing which sheet is the root and how the repeat groups nest beneath it.
#' Each level shown corresponds to a candidate **unit of analysis** in your
#' survey data.
#'
#' @param x A `survey_structure` object returned by [detect_structure()].
#' @param ... Ignored.
#'
#' @return The input object, invisibly. Called for its side effect of
#'   printing the structure to the console.
#'
#' @export
print.survey_structure <- function(x, ...) {
  cat("\n-- Survey Export Structure --\n")
  cat("Parent sheet:", shQuote(x$parent_sheet), "\n")

  if (length(x$repeat_sheets) == 0L) {
    cat("No repeat sheets found.\n")
    return(invisible(x))
  }

  cat("Repeat sheet(s):", paste(shQuote(x$repeat_sheets), collapse = ", "), "\n")
  cat("\nHierarchy (each level is a candidate unit of analysis):\n")
  .print_tree(x$tree, indent = 0L)
  invisible(x)
}

#' Print an odk_structure object (deprecated)
#'
#' Provided for backward compatibility with objects produced by the
#' previous `odkmerge` release. Delegates to [print.survey_structure()].
#'
#' @param x An `odk_structure` object.
#' @param ... Passed to [print.survey_structure()].
#'
#' @return The input object, invisibly.
#'
#' @export
print.odk_structure <- function(x, ...) {
  # If the modern class tag is present, dispatch to the new printer directly.
  if (inherits(x, "survey_structure")) {
    return(NextMethod())
  }
  # Otherwise: treat the legacy object as if it were a survey_structure.
  class(x) <- c("survey_structure", class(x))
  print.survey_structure(x, ...)
}

#' @noRd
.print_tree <- function(node, indent) {
  if (is.character(node)) {
    cat(strrep("  ", indent), "*", node, "\n")
    return(invisible(NULL))
  }

  # node is a list: names are parent nodes, values are children
  for (nm in names(node)) {
    cat(strrep("  ", indent), "*", nm, "\n")
    child <- node[[nm]]
    if (is.list(child)) {
      for (ch_nm in names(child)) {
        .print_tree(child[[ch_nm]], indent + 1L)
      }
    } else {
      .print_tree(child, indent + 1L)
    }
  }
}
