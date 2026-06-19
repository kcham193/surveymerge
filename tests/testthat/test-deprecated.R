# tests/testthat/test-deprecated.R
#
# Verifies that the legacy odkmerge function names still work in
# surveymerge 0.2.0 and emit a one-time deprecation warning.

simple_path <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")

test_that("odk_merge() still produces the same result as survey_merge()", {
  expected <- survey_merge(simple_path, verbose = FALSE)
  got      <- suppressWarnings(odk_merge(simple_path, verbose = FALSE))
  expect_equal(nrow(got), nrow(expected))
  expect_equal(ncol(got), ncol(expected))
})

test_that("read_odk_export() still produces the same result as read_survey_export()", {
  expected <- read_survey_export(simple_path)
  got      <- suppressWarnings(read_odk_export(simple_path))
  expect_equal(names(got), names(expected))
  expect_equal(nrow(got[[1]]), nrow(expected[[1]]))
})

test_that("odk_merge() emits a deprecation warning on first use in a session", {
  # Reset the per-session "warned-once" flag for this test
  if (exists(".surveymerge_deprecation_state",
             envir = asNamespace("surveymerge"))) {
    rm(list = ls(envir = asNamespace("surveymerge")$.surveymerge_deprecation_state),
       envir = asNamespace("surveymerge")$.surveymerge_deprecation_state)
  }
  expect_warning(
    odk_merge(simple_path, verbose = FALSE),
    regexp = "deprecated"
  )
})

test_that("read_odk_export() emits a deprecation warning on first use in a session", {
  if (exists(".surveymerge_deprecation_state",
             envir = asNamespace("surveymerge"))) {
    rm(list = ls(envir = asNamespace("surveymerge")$.surveymerge_deprecation_state),
       envir = asNamespace("surveymerge")$.surveymerge_deprecation_state)
  }
  expect_warning(
    read_odk_export(simple_path),
    regexp = "deprecated"
  )
})
