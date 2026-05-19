# data-raw/make_test_data.R
# Generates synthetic .xlsx test fixtures for odkmerge package tests.
# Run this script once to populate inst/extdata/.
# Requires: openxlsx

library(openxlsx)
set.seed(42)

out_dir <- "inst/extdata"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

rand_uuid <- function(n) {
  vapply(seq_len(n), function(i) {
    paste0(
      paste(sample(c(letters[1:6], 0:9), 8, replace = TRUE), collapse = ""), "-",
      paste(sample(c(letters[1:6], 0:9), 4, replace = TRUE), collapse = ""), "-",
      paste(sample(c(letters[1:6], 0:9), 4, replace = TRUE), collapse = ""), "-",
      paste(sample(c(letters[1:6], 0:9), 12, replace = TRUE), collapse = "")
    )
  }, character(1))
}

# ---------------------------------------------------------------------------
# 1. simple_survey.xlsx  (1 parent + 1 repeat)
# ---------------------------------------------------------------------------

survey <- data.frame(
  `_index`           = 1:10,
  plot_id            = sprintf("P%02d", 1:10),
  observer           = sample(c("Alice", "Bob", "Carol"), 10, replace = TRUE),
  survey_date        = as.Date("2024-01-01") + (0:9) * 3,
  vegetation_type    = sample(c("savanna", "forest", "wetland"), 10, replace = TRUE),
  `_uuid`            = rand_uuid(10),
  `_submission_time` = as.POSIXct("2024-01-01 08:00:00") + (0:9) * 3600,
  check.names        = FALSE,
  stringsAsFactors   = FALSE
)

# ~4 species rows per parent
parent_idx <- rep(1:10, each = 4)
species <- data.frame(
  `_index`             = seq_along(parent_idx),
  `_parent_index`      = parent_idx,
  `_parent_table_name` = "survey",
  species_name         = sample(c("Acacia", "Combretum", "Themeda", "Panicum",
                                   "Setaria", "Digitaria"), length(parent_idx),
                                replace = TRUE),
  cover_pct            = round(runif(length(parent_idx), 5, 80), 1),
  height_m             = round(runif(length(parent_idx), 0.1, 4.0), 2),
  check.names          = FALSE,
  stringsAsFactors     = FALSE
)

wb1 <- createWorkbook()
addWorksheet(wb1, "survey")
addWorksheet(wb1, "species")
writeData(wb1, "survey",  survey)
writeData(wb1, "species", species)
saveWorkbook(wb1, file.path(out_dir, "simple_survey.xlsx"), overwrite = TRUE)
message("simple_survey.xlsx written")

# ---------------------------------------------------------------------------
# 2. multi_repeat_survey.xlsx  (1 parent + 2 sibling repeats)
# ---------------------------------------------------------------------------

household <- data.frame(
  `_index`  = 1:8,
  hh_id     = sprintf("HH%03d", 1:8),
  village   = sample(c("Arusha", "Moshi", "Dodoma", "Iringa"), 8, replace = TRUE),
  `_uuid`   = rand_uuid(8),
  check.names      = FALSE,
  stringsAsFactors = FALSE
)

# members: ~3-4 per household (30 total)
mem_parent <- c(rep(1:8, each = 3), sample(1:8, 6, replace = TRUE))
mem_parent <- sort(mem_parent)[1:30]
members <- data.frame(
  `_index`             = 1:30,
  `_parent_index`      = mem_parent,
  `_parent_table_name` = "household",
  member_name          = paste0("Member_", 1:30),
  age                  = sample(5:75, 30, replace = TRUE),
  gender               = sample(c("M", "F"), 30, replace = TRUE),
  check.names          = FALSE,
  stringsAsFactors     = FALSE
)

# assets: ~2-3 per household (20 total)
asset_parent <- sort(rep(1:8, each = 2)[1:16])
asset_parent <- c(asset_parent, sample(1:8, 4, replace = TRUE))
asset_parent <- sort(asset_parent)[1:20]
assets <- data.frame(
  `_index`             = 1:20,
  `_parent_index`      = asset_parent,
  `_parent_table_name` = "household",
  asset_type           = sample(c("land", "livestock", "equipment", "vehicle"),
                                20, replace = TRUE),
  asset_value          = round(runif(20, 100, 5000), 0),
  check.names          = FALSE,
  stringsAsFactors     = FALSE
)

wb2 <- createWorkbook()
addWorksheet(wb2, "household")
addWorksheet(wb2, "members")
addWorksheet(wb2, "assets")
writeData(wb2, "household", household)
writeData(wb2, "members",   members)
writeData(wb2, "assets",    assets)
saveWorkbook(wb2, file.path(out_dir, "multi_repeat_survey.xlsx"), overwrite = TRUE)
message("multi_repeat_survey.xlsx written")

# ---------------------------------------------------------------------------
# 3. nested_survey.xlsx  (farm -> field -> observation)
# ---------------------------------------------------------------------------

farm <- data.frame(
  `_index`      = 1:5,
  farm_id       = sprintf("F%02d", 1:5),
  farm_size_ha  = round(runif(5, 0.5, 20), 1),
  `_uuid`       = rand_uuid(5),
  check.names   = FALSE,
  stringsAsFactors = FALSE
)

# 3 fields per farm = 15 rows
field_parent <- rep(1:5, each = 3)
field <- data.frame(
  `_index`             = 1:15,
  `_parent_index`      = field_parent,
  `_parent_table_name` = "farm",
  field_name           = paste0("Field_", 1:15),
  crop                 = sample(c("maize", "beans", "rice", "sorghum"),
                                15, replace = TRUE),
  check.names          = FALSE,
  stringsAsFactors     = FALSE
)

# 3 observations per field = 45 rows
obs_parent <- rep(1:15, each = 3)
observation <- data.frame(
  `_index`             = 1:45,
  `_parent_index`      = obs_parent,
  `_parent_table_name` = "field",
  obs_date             = as.Date("2024-03-01") + sample(0:60, 45, replace = TRUE),
  pest_present         = sample(c(TRUE, FALSE), 45, replace = TRUE),
  notes                = sample(c("healthy", "mild stress", "severe", "NA"),
                                45, replace = TRUE),
  check.names          = FALSE,
  stringsAsFactors     = FALSE
)

wb3 <- createWorkbook()
addWorksheet(wb3, "farm")
addWorksheet(wb3, "field")
addWorksheet(wb3, "observation")
writeData(wb3, "farm",        farm)
writeData(wb3, "field",       field)
writeData(wb3, "observation", observation)
saveWorkbook(wb3, file.path(out_dir, "nested_survey.xlsx"), overwrite = TRUE)
message("nested_survey.xlsx written")

message("\nAll test fixtures created in ", out_dir)
