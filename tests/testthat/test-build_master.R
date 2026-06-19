# tests/testthat/test-build_master.R

simple_path <- system.file("extdata", "simple_survey.xlsx",       package = "surveymerge")
multi_path  <- system.file("extdata", "multi_repeat_survey.xlsx", package = "surveymerge")
nested_path <- system.file("extdata", "nested_survey.xlsx",       package = "surveymerge")

test_that("simple survey returns a single tibble", {
  sheets <- read_survey_export(simple_path)
  master <- build_master(sheets)
  expect_s3_class(master, "data.frame")
  # Must NOT be a list
  expect_false(is.list(master) && !is.data.frame(master))
})

test_that("simple survey master has same row count as repeat sheet (40 rows)", {
  sheets <- read_survey_export(simple_path)
  master <- build_master(sheets)
  expect_equal(nrow(master), nrow(sheets[["species"]]))
})

test_that("simple survey master contains parent column plot_id", {
  sheets <- read_survey_export(simple_path)
  master <- build_master(sheets)
  expect_true("plot_id" %in% colnames(master))
})

test_that("multi-repeat survey returns a named list of 2 tibbles", {
  sheets <- read_survey_export(multi_path)
  result <- build_master(sheets)
  expect_type(result, "list")
  expect_length(result, 2L)
  expect_named(result, c("members", "assets"))
})

test_that("each element of multi-repeat result is a data.frame", {
  sheets <- read_survey_export(multi_path)
  result <- build_master(sheets)
  purrr::walk(result, function(df) expect_s3_class(df, "data.frame"))
})

test_that("multi-repeat members tibble contains parent column village", {
  sheets <- read_survey_export(multi_path)
  result <- build_master(sheets)
  expect_true("village" %in% colnames(result[["members"]]))
})

test_that("nested survey returns a single flat tibble", {
  sheets <- read_survey_export(nested_path)
  master <- build_master(sheets)
  # nested has 2 repeat sheets -> list
  expect_type(master, "list")
  expect_length(master, 2L)
})

test_that("nested observation master contains grandparent column farm_id", {
  sheets <- read_survey_export(nested_path)
  result <- build_master(sheets)
  obs_master <- result[["observation"]]
  expect_true("farm_id" %in% colnames(obs_master))
})

test_that("observation master row count equals repeat sheet row count (45)", {
  sheets <- read_survey_export(nested_path)
  result <- build_master(sheets)
  expect_equal(nrow(result[["observation"]]), nrow(sheets[["observation"]]))
})

test_that("drop_internal = TRUE removes _submission_ columns from output", {
  sheets <- read_survey_export(simple_path)
  sheets[["species"]][["_submission__uuid"]] <- "x"
  master <- build_master(sheets, drop_internal = TRUE)
  expect_false(any(grepl("^_submission_", colnames(master))))
})

test_that("build_master accepts pre-computed structure argument", {
  sheets    <- read_survey_export(simple_path)
  structure <- detect_structure(sheets)
  master1   <- build_master(sheets)
  master2   <- build_master(sheets, structure = structure)
  expect_equal(nrow(master1), nrow(master2))
  expect_equal(ncol(master1), ncol(master2))
})
