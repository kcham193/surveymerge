# tests/testthat/test-survey_merge.R

simple_path <- system.file("extdata", "simple_survey.xlsx",       package = "surveymerge")
multi_path  <- system.file("extdata", "multi_repeat_survey.xlsx", package = "surveymerge")

test_that("survey_merge returns a tibble for simple_survey", {
  master <- survey_merge(simple_path)
  expect_s3_class(master, "data.frame")
})

test_that("survey_merge result contains parent column (plot_id) for simple survey", {
  master <- survey_merge(simple_path)
  expect_true("plot_id" %in% colnames(master))
})

test_that("survey_merge returns a named list for multi_repeat_survey", {
  result <- survey_merge(multi_path)
  expect_type(result, "list")
  expect_length(result, 2L)
})

test_that("verbose = FALSE suppresses all messages", {
  expect_silent(survey_merge(simple_path, verbose = FALSE))
})

test_that("survey_merge row count matches the repeat sheet for simple survey", {
  master  <- survey_merge(simple_path, verbose = FALSE)
  sheets  <- read_survey_export(simple_path)
  expect_equal(nrow(master), nrow(sheets[["species"]]))
})

test_that("survey_merge passes drop_internal through to build_master", {
  sheets <- read_survey_export(simple_path)
  sheets[["species"]][["_submission__uuid"]] <- "x"
  # Write to a temp file so survey_merge can read it
  tmp <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tmp))
  writexl::write_xlsx(sheets, tmp)
  master_drop <- survey_merge(tmp, drop_internal = TRUE,  verbose = FALSE)
  master_keep <- survey_merge(tmp, drop_internal = FALSE, verbose = FALSE)
  expect_false(any(grepl("^_submission_", colnames(master_drop))))
  expect_true(any(grepl("^_submission_", colnames(master_keep))))
})

test_that("survey_merge stops with error on missing file", {
  expect_error(survey_merge("no_such_file.xlsx"), regexp = "not exist|not found")
})
