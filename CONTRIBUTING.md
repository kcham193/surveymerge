# Contributing to odkmerge

Thank you for your interest in contributing to `odkmerge`! This document
outlines how to propose a change.

## Fixing typos

Small typos or grammatical errors in documentation can be edited
directly through the GitHub web interface, provided the changes are made
in the **source** file:

- Fix a typo in roxygen comments inside `R/`, not the generated `.Rd`
  files in `man/`.
- Fix README content in `README.Rmd`, not in the rendered `README.md`.

## Bigger changes

If you want to make a bigger change, it’s a good idea to first file an
issue and make sure someone from the team agrees that it is needed.

### Pull request process

1.  Fork the package and clone onto your computer. If you haven’t done
    this before, we recommend using
    `usethis::create_from_github("kcham193/odkmerge", fork = TRUE)`.
2.  Install all development dependencies with
    `devtools::install_dev_deps()`, then make sure the package passes R
    CMD check by running `devtools::check()`. If it does not pass, ask
    for help before continuing.
3.  Create a Git branch for your pull request (PR). We recommend using
    `usethis::pr_init("brief-description-of-change")`.
4.  Make your changes, commit to git, and then create a PR by running
    `usethis::pr_push()`, and following the prompts in your browser. The
    title of your PR should briefly describe the change. The body should
    contain `Fixes #issue-number`.
5.  For user-facing changes, add a bullet to the top of `NEWS.md`
    (i.e. just below the first header). Follow the style described in
    <https://style.tidyverse.org/news.html>.

### Code style

- New code should follow the tidyverse [style
  guide](https://style.tidyverse.org). You can use the
  [styler](https://CRAN.R-project.org/package=styler) package to apply
  these styles automatically, but please don’t restyle code that has
  nothing to do with your PR.
- We use [roxygen2](https://cran.r-project.org/package=roxygen2), with
  [Markdown
  syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html),
  for documentation.
- We use [testthat](https://cran.r-project.org/package=testthat) for
  unit tests. Contributions with test cases included are easier to
  accept.

### CRAN-readiness

All PRs must pass `devtools::check()` with **0 errors, 0 warnings, and 0
notes**.

## Code of Conduct

Please note that the odkmerge project is released with a [Contributor
Code of
Conduct](https://kcham193.github.io/odkmerge/CODE_OF_CONDUCT.md). By
contributing to this project you agree to abide by its terms.
