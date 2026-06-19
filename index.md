# surveymerge

**Navigate survey relationships. Build analysis-ready datasets.**

`surveymerge` is an R package for working with relational survey exports
that contain repeat groups and nested repeat groups, as produced by
XLSForm-based platforms such as **ODK Central** and **KoboToolbox**.

Rather than reflexively flattening every sheet into one wide table, it
helps you:

- Inspect the parent-child structure of an export.
- Identify the **units of analysis** that exist in your survey
  (household, individual, visit, observation, event, …).
- Build analysis-ready datasets *at the appropriate unit of analysis*,
  with parent context joined in only where it makes statistical sense.
- Preserve the relational structure when you need it; collapse it when
  you don’t.

Both major export conventions are auto-detected:

|                 | Row identifier | Parent reference |
|-----------------|----------------|------------------|
| **KoboToolbox** | `_index`       | `_parent_index`  |
| **ODK Central** | `KEY`          | `PARENT_KEY`     |

System columns (`_submission_*` on Kobo; `SubmissionDate`,
`SubmitterID`, `Status`, etc. on Central) are stripped by default so the
resulting dataset is analysis-ready.

## Understanding units of analysis

A survey export usually carries data at more than one level. Consider a
household survey with two repeats:

``` R
┌────────────────────────────┐
│        household           │   <- 1 row per household
│  hh_id  village  ...       │      (parent sheet)
└──────────┬─────────────────┘
           │
           ├───────────────────┐
           │                   │
┌──────────▼──────────┐  ┌─────▼──────────┐
│       members       │  │     assets      │   <- 1 row per member /
│ member_name age ... │  │ asset_type ...  │      1 row per asset
└─────────────────────┘  └─────────────────┘      (repeat sheets)
```

That export has **three legitimate units of analysis**:

| Unit of analysis | Where it lives | Example questions |
|----|----|----|
| Household | `household` sheet | What fraction of households own livestock? |
| Individual / member | `members` sheet (+ selected hh columns) | What is the age distribution of members? |
| Asset / event | `assets` sheet (+ selected hh columns) | Which asset types are most common? |

Flattening all three into a single table would inflate household counts
(a household with five members would be counted five times), distort
ratios, and turn parent-level variables into pseudo-repeated measures.
`surveymerge` deliberately keeps the grains separate so you can pick the
one that matches your question.

## How it works

For each repeat sheet in your export,
[`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md)
walks up the parent chain and produces a tibble at *that repeat’s*
grain, with ancestor columns attached:

``` R
┌─────────────────────┐     ┌─────────────────────┐
│   survey (parent)   │     │   species (repeat)  │
│  _index │ plot_id   │     │ _index│_parent_index│
│    1    │  P01      │     │   1   │      1      │
│    2    │  P02      │     │   2   │      1      │
│   ...   │  ...      │     │   3   │      2      │
└─────────────────────┘     └─────────────────────┘
            │                          │
            └────── surveymerge ───────┘
                          │
                          ▼
        ┌──────────────────────────────────────┐
        │   dataset at the SPECIES grain       │
        │ _parent_index │ plot_id │ species    │
        │      1        │  P01    │ Acacia     │
        │      1        │  P01    │ Combretum  │
        │      2        │  P02    │ Themeda    │
        └──────────────────────────────────────┘
```

One row per repeat record, with parent context joined in.

## Installation

``` r

# GitHub (development version):
# install.packages("devtools")
devtools::install_github("kcham193/surveymerge")

# CRAN (once published):
install.packages("surveymerge")
```

## Quick example

``` r

library(surveymerge)

path   <- system.file("extdata", "simple_survey.xlsx", package = "surveymerge")
master <- survey_merge(path, verbose = FALSE)
head(master)
#> # A tibble: 6 × 11
#>   `_index` `_parent_index` `_parent_table_name` species_name cover_pct height_m
#>      <dbl>           <dbl> <chr>                <chr>            <dbl>    <dbl>
#> 1        1               1 survey               Combretum         42.9     0.2 
#> 2        2               1 survey               Combretum         58.7     2.84
#> 3        3               1 survey               Panicum           21.5     2.4 
#> 4        4               1 survey               Acacia            61.9     0.72
#> 5        5               2 survey               Panicum           30.5     0.71
#> 6        6               2 survey               Themeda           12.7     1.58
#> # ℹ 5 more variables: plot_id <chr>, observer <chr>, survey_date <chr>,
#> #   vegetation_type <chr>, `_uuid` <chr>
```

For multi-repeat or nested forms,
[`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md)
returns a *named list* of tibbles - one per repeat group - because
sibling repeats live at different grains and shouldn’t be silently
stacked together.

## Step-by-step control

``` r

# 1. Read all sheets (preserves relational structure)
sheets <- read_survey_export("my_export.xlsx")

# 2. Inspect the structure to see which units of analysis exist
detect_structure(sheets)

# 3. Build a dataset at a repeat grain
master <- build_master(sheets)

# 4. Or attach only the parent columns you actually need
enriched <- enrich_repeat(sheets, "members",
                          parent_cols = c("hh_id", "village"))
```

## Migration from `odkmerge`

If you used the previous `odkmerge` 0.1.0 release, your scripts still
work:
[`odk_merge()`](https://kcham193.github.io/surveymerge/reference/odk_merge.md)
and
[`read_odk_export()`](https://kcham193.github.io/surveymerge/reference/read_odk_export.md)
are kept as deprecated aliases that forward to the new names. Update
them at your own pace:

| Old (deprecated) | New |
|----|----|
| [`odk_merge()`](https://kcham193.github.io/surveymerge/reference/odk_merge.md) | [`survey_merge()`](https://kcham193.github.io/surveymerge/reference/survey_merge.md) |
| [`read_odk_export()`](https://kcham193.github.io/surveymerge/reference/read_odk_export.md) | [`read_survey_export()`](https://kcham193.github.io/surveymerge/reference/read_survey_export.md) |
| class `odk_structure` | class `survey_structure` |

## Learn more

See the [Getting Started
vignette](https://kcham193.github.io/surveymerge/articles/getting-started.html)
for a deeper walkthrough, including multi-repeat and nested examples and
a longer discussion of units of analysis.

## Code of Conduct

Please note that the `surveymerge` project is released with a
[Contributor Code of
Conduct](https://github.com/kcham193/surveymerge/blob/master/.github/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.

## Contributing

Contributions are welcome! See
[CONTRIBUTING.md](https://github.com/kcham193/surveymerge/blob/master/.github/CONTRIBUTING.md)
for guidelines. All contributions must pass `devtools::check()` with 0
errors, 0 warnings, and 0 notes.

## License

MIT (c) Kasim Chambulilo
