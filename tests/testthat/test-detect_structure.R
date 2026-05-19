# tests/testthat/test-detect_structure.R

simple_path <- system.file("extdata", "simple_survey.xlsx",       package = "odkmerge")
multi_path  <- system.file("extdata", "multi_repeat_survey.xlsx", package = "odkmerge")
nested_path <- system.file("extdata", "nested_survey.xlsx",       package = "odkmerge")

test_that("detect_structure returns an odk_structure object", {
  sheets <- read_odk_export(simple_path)
  result <- detect_structure(sheets)
  expect_s3_class(result, "odk_structure")
})

test_that("detects 'survey' as parent and 'species' as repeat (simple)", {
  sheets <- read_odk_export(simple_path)
  result <- detect_structure(sheets)
  expect_equal(result$parent_sheet, "survey")
  expect_equal(result$repeat_sheets, "species")
})

test_that("detects 2 repeat sheets for multi_repeat_survey", {
  sheets <- read_odk_export(multi_path)
  result <- detect_structure(sheets)
  expect_equal(result$parent_sheet, "household")
  expect_length(result$repeat_sheets, 2L)
  expect_setequal(result$repeat_sheets, c("members", "assets"))
})

test_that("detects 3-level nested structure for nested_survey", {
  sheets <- read_odk_export(nested_path)
  result <- detect_structure(sheets)
  expect_equal(result$parent_sheet, "farm")
  expect_length(result$repeat_sheets, 2L)
  # field is child of farm; observation is child of field
  expect_equal(result$direct_parent[["field"]],       "farm")
  expect_equal(result$direct_parent[["observation"]], "field")
})

test_that("index_cols maps every sheet to a column name", {
  sheets <- read_odk_export(simple_path)
  result <- detect_structure(sheets)
  expect_named(result$index_cols, names(sheets))
  purrr::walk(result$index_cols, function(v) expect_type(v, "character"))
})

test_that("parent_index_cols is present for repeat sheets only", {
  sheets <- read_odk_export(simple_path)
  result <- detect_structure(sheets)
  expect_named(result$parent_index_cols, "species")
})

test_that("print.odk_structure runs without error", {
  sheets <- read_odk_export(simple_path)
  result <- detect_structure(sheets)
  expect_output(print(result))
})

test_that("detect_structure warns when no repeat sheets found", {
  # Build a sheets list with no repeats
  sheets <- read_odk_export(simple_path)
  parent_only <- sheets["survey"]
  expect_warning(
    detect_structure(parent_only),
    regexp = "No repeat"
  )
})
