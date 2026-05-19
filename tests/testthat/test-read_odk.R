# tests/testthat/test-read_odk.R

simple_path <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")

test_that("read_odk_export returns a list of length 2 for simple_survey", {
  sheets <- read_odk_export(simple_path)
  expect_type(sheets, "list")
  expect_length(sheets, 2L)
})

test_that("read_odk_export returns a named list matching sheet names", {
  sheets <- read_odk_export(simple_path)
  expect_named(sheets, c("survey", "species"))
})

test_that("each element of the returned list is a tibble / data.frame", {
  sheets <- read_odk_export(simple_path)
  purrr::walk(sheets, function(df) expect_s3_class(df, "data.frame"))
})

test_that("read_odk_export stops with error on non-existent file", {
  expect_error(
    read_odk_export("does_not_exist.xlsx"),
    regexp = "not exist|not found|File not found"
  )
})

test_that("read_odk_export stops with error on non-.xlsx file", {
  tmp <- tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)
  on.exit(unlink(tmp))
  expect_error(
    read_odk_export(tmp),
    regexp = "\\.xlsx"
  )
})

test_that("read_odk_export stops with error when file_path is not a string", {
  expect_error(read_odk_export(123), regexp = "character")
})

test_that("read_odk_export reads multi_repeat_survey.xlsx with 3 sheets", {
  path <- system.file("extdata", "multi_repeat_survey.xlsx", package = "odkmerge")
  sheets <- read_odk_export(path)
  expect_length(sheets, 3L)
  expect_named(sheets, c("household", "members", "assets"))
})
