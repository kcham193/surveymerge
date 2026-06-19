# Print a survey_structure object

Pretty-prints the parent-child hierarchy detected by
[`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md),
showing which sheet is the root and how the repeat groups nest beneath
it. Each level shown corresponds to a candidate **unit of analysis** in
your survey data.

## Usage

``` r
# S3 method for class 'survey_structure'
print(x, ...)
```

## Arguments

- x:

  A `survey_structure` object returned by
  [`detect_structure()`](https://kcham193.github.io/surveymerge/reference/detect_structure.md).

- ...:

  Ignored.

## Value

The input object, invisibly. Called for its side effect of printing the
structure to the console.
