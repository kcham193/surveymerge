# odkmerge

<!-- badges: start -->
[![R-CMD-check](https://github.com/yourusername/odkmerge/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/yourusername/odkmerge/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/odkmerge)](https://CRAN.R-project.org/package=odkmerge)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)
[![Codecov](https://codecov.io/gh/yourusername/odkmerge/branch/main/graph/badge.svg)](https://app.codecov.io/gh/yourusername/odkmerge)
<!-- badges: end -->

**Merge and flatten ODK and KoboToolbox repeat-group exports in one line of R.**

ODK and KoboToolbox export repeat-group data as separate sheets in an `.xlsx`
file. Joining them back together manually is tedious and error-prone.
`odkmerge` detects the sheet structure automatically and produces flat,
analysis-ready tibbles — for any form, regardless of complexity.

## How It Works

```
┌─────────────────────┐     ┌─────────────────────┐
│   survey (parent)   │     │   species (repeat)   │
│  _index │ plot_id   │     │ _index│_parent_index │
│    1    │  P01      │     │   1   │      1       │
│    2    │  P02      │     │   2   │      1       │
│   ...   │  ...      │     │   3   │      2       │
└─────────────────────┘     └─────────────────────┘
            │                          │
            └──────── odkmerge ────────┘
                          │
                          ▼
        ┌──────────────────────────────────────┐
        │         master dataset               │
        │ _parent_index │ plot_id │ species    │
        │      1        │  P01    │ Acacia     │
        │      1        │  P01    │ Combretum  │
        │      2        │  P02    │ Themeda    │
        └──────────────────────────────────────┘
```

## Installation

```r
# GitHub (development version):
devtools::install_github("kcham193/odkmerge")

# CRAN (once published):
install.packages("odkmerge")
```

## Quick Example

```r
library(odkmerge)

path   <- system.file("extdata", "simple_survey.xlsx", package = "odkmerge")
master <- odk_merge(path)
head(master)
```

For multi-repeat or nested forms, `odk_merge()` returns a named list of tibbles
— one per repeat group.

## Step-by-step control

```r
# 1. Read all sheets
sheets <- read_odk_export("my_kobo_export.xlsx")

# 2. Inspect the structure
detect_structure(sheets)

# 3. Build the flat master
master <- build_master(sheets)

# 4. Or enrich just one repeat sheet with selected parent columns
enriched <- enrich_repeat(sheets, "members",
                           parent_cols = c("hh_id", "village"))
```

## Learn More

See the [Getting Started vignette](vignettes/getting-started.Rmd) for full
documentation including multi-repeat and nested repeat examples.

## Contributing

Contributions are welcome! Please open an issue to discuss your idea before
submitting a pull request. All contributions must pass `devtools::check()` with
0 errors, 0 warnings, and 0 notes.

## License

MIT © Your Name
