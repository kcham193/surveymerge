# R/odkmerge-package.R

#' @keywords internal
"_PACKAGE"

## Suppress "no visible binding for global variable" R CMD check notes
## that arise from dplyr's non-standard evaluation.
utils::globalVariables(c(
  ".",
  ".join_key_"
))
