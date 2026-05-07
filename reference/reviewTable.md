# Create a Summary Table

Summarizes a column from literature review data and returns a formatted
[`gt::gt()`](https://gt.rstudio.com/reference/gt.html) table showing
each category, its associated study IDs, frequency, and percentage.

## Usage

``` r
reviewTable(
  data,
  col,
  sep = "\r\n",
  study_id = StudyID,
  latex = FALSE,
  cite = FALSE,
  na.rm = TRUE,
  na_label = "Not reported",
  na_in_percent = TRUE,
  na_last = FALSE
)
```

## Arguments

- data:

  A data frame with at least a study ID column and the column named by
  `col`.

- col:

  Column to summarize (quoted or unquoted).

- sep:

  Character. Separator for multi-value cells. Defaults to `"\r\n"`.

- study_id:

  Column containing study identifiers (quoted or unquoted). Defaults to
  `StudyID`.

- latex:

  Logical. If `TRUE`, returns the table as LaTeX code via
  [`gt::as_latex()`](https://gt.rstudio.com/reference/as_latex.html)
  instead of a [`gt::gt()`](https://gt.rstudio.com/reference/gt.html)
  object. Defaults to `FALSE`.

- cite:

  Logical. If `TRUE`, treats values in `study_id` as BibTeX reference
  keys and wraps the per-row study list in `\\cite{...}`. Defaults to
  `FALSE`.

- na.rm:

  Logical. Drop missing values? Defaults to `TRUE`.

- na_label:

  Character. Label for missing values when `na.rm = FALSE`. Defaults to
  `"Not reported"`.

- na_in_percent:

  Logical. Include missing rows in the percentage denominator? Defaults
  to `TRUE`.

- na_last:

  Logical. If `TRUE`, place the missing-value category last regardless
  of its frequency. Defaults to `FALSE`.

## Value

A [`gt::gt()`](https://gt.rstudio.com/reference/gt.html) table, or a
LaTeX character object if `latex = TRUE`.

## Examples

``` r
df <- data.frame(
  StudyID = c("S1", "S2", "S3", "S4"),
  Design = c("RCT", "Cohort", "RCT", "Case-control"),
  stringsAsFactors = FALSE
)
reviewTable(df, Design)


  

Design
```
