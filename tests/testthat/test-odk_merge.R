# tests/testthat/test-odk_merge.R

simple_path <- system.file("extdata", "simple_survey.xlsx",       package = "odkmerge")
multi_path  <- system.file("extdata", "multi_repeat_survey.xlsx", package = "odkmerge")

test_that("odk_merge returns a tibble for simple_survey", {
  master <- odk_merge(simple_path)
  expect_s3_class(master, "data.frame")
})

test_that("odk_merge result contains parent column (plot_id) for simple survey", {
  master <- odk_merge(simple_path)
  expect_true("plot_id" %in% colnames(master))
})

test_that("odk_merge returns a named list for multi_repeat_survey", {
  result <- odk_merge(multi_path)
  expect_type(result, "list")
  expect_length(result, 2L)
})

test_that("verbose = FALSE suppresses all messages", {
  expect_silent(odk_merge(simple_path, verbose = FALSE))
})

test_that("odk_merge row count matches the repeat sheet for simple survey", {
  master  <- odk_merge(simple_path, verbose = FALSE)
  sheets  <- read_odk_export(simple_path)
  expect_equal(nrow(master), nrow(sheets[["species"]]))
})

test_that("odk_merge passes drop_internal through to build_master", {
  sheets <- read_odk_export(simple_path)
  sheets[["species"]][["_submission__uuid"]] <- "x"
  # Write to a temp file so odk_merge can read it
  tmp <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tmp))
  writexl::write_xlsx(sheets, tmp)
  master_drop <- odk_merge(tmp, drop_internal = TRUE,  verbose = FALSE)
  master_keep <- odk_merge(tmp, drop_internal = FALSE, verbose = FALSE)
  expect_false(any(grepl("^_submission_", colnames(master_drop))))
  expect_true(any(grepl("^_submission_", colnames(master_keep))))
})

test_that("odk_merge stops with error on missing file", {
  expect_error(odk_merge("no_such_file.xlsx"), regexp = "not exist|not found")
})
