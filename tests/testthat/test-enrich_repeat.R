# tests/testthat/test-enrich_repeat.R

simple_path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")

test_that("enriched repeat has more columns than original repeat", {
  sheets   <- read_odk_export(simple_path)
  original <- sheets[["species"]]
  enriched <- enrich_repeat(sheets, repeat_sheet_name = "species")
  expect_gt(ncol(enriched), ncol(original))
})

test_that("all original repeat rows are preserved (left join)", {
  sheets   <- read_odk_export(simple_path)
  original <- sheets[["species"]]
  enriched <- enrich_repeat(sheets, repeat_sheet_name = "species")
  expect_equal(nrow(enriched), nrow(original))
})

test_that("requested parent_cols appear in the enriched output", {
  sheets   <- read_odk_export(simple_path)
  enriched <- enrich_repeat(
    sheets,
    repeat_sheet_name = "species",
    parent_cols       = c("plot_id", "observer")
  )
  expect_true("plot_id"  %in% colnames(enriched))
  expect_true("observer" %in% colnames(enriched))
})

test_that("drop_internal = TRUE removes _submission_ columns", {
  # Add a fake submission column to the repeat sheet
  sheets <- read_odk_export(simple_path)
  sheets[["species"]][["_submission__uuid"]] <- "dummy"
  enriched <- enrich_repeat(sheets, repeat_sheet_name = "species",
                             drop_internal = TRUE)
  expect_false(any(grepl("^_submission_", colnames(enriched))))
})

test_that("drop_internal = FALSE keeps _submission_ columns", {
  sheets <- read_odk_export(simple_path)
  sheets[["species"]][["_submission__uuid"]] <- "dummy"
  enriched <- enrich_repeat(sheets, repeat_sheet_name = "species",
                             drop_internal = FALSE)
  expect_true("_submission__uuid" %in% colnames(enriched))
})

test_that("stops with error if repeat_sheet_name not in sheets", {
  sheets <- read_odk_export(simple_path)
  expect_error(
    enrich_repeat(sheets, repeat_sheet_name = "nonexistent"),
    regexp = "not found|nonexistent"
  )
})

test_that("stops with error if named sheet is not a repeat sheet", {
  sheets <- read_odk_export(simple_path)
  expect_error(
    enrich_repeat(sheets, repeat_sheet_name = "survey"),
    regexp = "_parent_index|not.*repeat"
  )
})

test_that("warns if requested parent_cols include missing columns", {
  sheets <- read_odk_export(simple_path)
  expect_warning(
    enrich_repeat(sheets, repeat_sheet_name = "species",
                  parent_cols = c("plot_id", "col_that_does_not_exist")),
    regexp = "Missing|not found"
  )
})
