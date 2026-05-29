# tests/testthat/test-central-format.R
#
# Exercises the package against an ODK Central-style export (`KEY` /
# `PARENT_KEY` columns, plus Central's system columns).

central_path <- system.file(
  "extdata", "simple_survey_central.xlsx",
  package = "odkmerge"
)

# ---------------------------------------------------------------------------
# read_odk_export
# ---------------------------------------------------------------------------

test_that("read_odk_export reads a Central-format file", {
  sheets <- read_odk_export(central_path)
  expect_named(sheets, c("survey", "species"))
  expect_true("KEY" %in% colnames(sheets$survey))
  expect_true("PARENT_KEY" %in% colnames(sheets$species))
})

# ---------------------------------------------------------------------------
# detect_structure
# ---------------------------------------------------------------------------

test_that("detect_structure handles ODK Central column names", {
  sheets <- read_odk_export(central_path)
  result <- detect_structure(sheets)

  expect_s3_class(result, "odk_structure")
  expect_equal(result$parent_sheet, "survey")
  expect_equal(result$repeat_sheets, "species")
})

test_that("detect_structure picks KEY as the index column on Central", {
  sheets <- read_odk_export(central_path)
  result <- detect_structure(sheets)

  expect_equal(result$index_cols[["survey"]],  "KEY")
  expect_equal(result$index_cols[["species"]], "KEY")
  expect_equal(result$parent_index_cols[["species"]], "PARENT_KEY")
})

# ---------------------------------------------------------------------------
# odk_merge (full pipeline)
# ---------------------------------------------------------------------------

test_that("odk_merge flattens an ODK Central simple survey", {
  master <- odk_merge(central_path, verbose = FALSE)

  expect_s3_class(master, "data.frame")
  expect_gt(nrow(master), 0L)
  expect_true("plot_id" %in% colnames(master))
  expect_true("species_name" %in% colnames(master))
})

test_that("odk_merge drops ODK Central system columns by default", {
  master <- odk_merge(central_path, verbose = FALSE)

  central_sys <- c("SubmissionDate", "SubmitterID", "SubmitterName",
                   "AttachmentsPresent", "AttachmentsExpected",
                   "Status", "ReviewState", "DeviceID", "Edits",
                   "FormVersion")
  expect_length(intersect(central_sys, colnames(master)), 0L)
})

test_that("odk_merge retains system columns when drop_internal = FALSE", {
  master <- odk_merge(central_path, drop_internal = FALSE, verbose = FALSE)

  # At least one Central system column should survive when drop is disabled
  expect_true(any(c("SubmissionDate", "SubmitterID") %in% colnames(master)))
})

test_that("odk_merge row count equals the repeat-sheet row count (Central)", {
  master <- odk_merge(central_path, verbose = FALSE)
  sheets <- read_odk_export(central_path)
  expect_equal(nrow(master), nrow(sheets$species))
})

# ---------------------------------------------------------------------------
# enrich_repeat
# ---------------------------------------------------------------------------

test_that("enrich_repeat works against Central format", {
  sheets <- read_odk_export(central_path)
  enriched <- enrich_repeat(sheets, "species",
                            parent_cols = c("plot_id", "observer"))

  expect_s3_class(enriched, "data.frame")
  expect_equal(nrow(enriched), nrow(sheets$species))
  expect_true("plot_id"  %in% colnames(enriched))
  expect_true("observer" %in% colnames(enriched))
})
