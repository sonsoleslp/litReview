# Summarize Frequency of Values in a Column

Splits multi-value cells, counts frequencies, and computes percentages.

## Usage

``` r
summarize_data(
  data,
  col,
  sep = "\r\n",
  study_id = StudyID,
  na.rm = TRUE,
  na_label = "Not reported",
  na_in_percent = TRUE,
  na_last = FALSE
)
```

## Arguments

- data:

  A data frame containing at least the columns specified by `col` and
  `study_id`.

- col:

  Column to summarize (quoted or unquoted).

- sep:

  Character. The separator used to split multi-value cells. Defaults to
  `"\r\n"`.

- study_id:

  Column containing study identifiers (quoted or unquoted). Defaults to
  `StudyID`.

- na.rm:

  Logical. If `TRUE` (default), rows with missing values (`NA` or empty
  strings) in `col` are dropped. If `FALSE`, they are kept and labelled
  with `na_label`.

- na_label:

  Character. Label used for missing values when `na.rm = FALSE`.
  Defaults to `"Not reported"`.

- na_in_percent:

  Logical. If `TRUE` (default), the denominator for percentages is the
  total number of rows (including missing). If `FALSE`, only non-missing
  rows are counted, so non-missing categories sum to \\\approx 100\\\\.

- na_last:

  Logical. If `TRUE`, the missing-value row (when `na.rm = FALSE`) is
  placed at the bottom of the result regardless of its frequency.
  Defaults to `FALSE` (sorted by frequency like all other rows).

## Value

A data frame with columns for the grouping variable, `Studies`
(comma-separated study IDs), `Frequency`, and `Percent` (numeric,
0–100).

## Examples

``` r
df <- data.frame(
  StudyID = c("S1", "S2", "S3", "S4"),
  Design = c("RCT", "Cohort", NA, "RCT"),
  stringsAsFactors = FALSE
)

# Drop NAs (default)
summarize_data(df, Design)
#> # A tibble: 2 × 4
#>   Design Studies Frequency Percent
#>   <chr>  <chr>       <int>   <dbl>
#> 1 Cohort S2              1      25
#> 2 RCT    S1, S4          2      50

# Keep NAs with a custom label
summarize_data(df, Design, na.rm = FALSE, na_label = "Missing")
#> # A tibble: 3 × 4
#>   Design  Studies Frequency Percent
#>   <chr>   <chr>       <int>   <dbl>
#> 1 Missing S3              1      25
#> 2 Cohort  S2              1      25
#> 3 RCT     S1, S4          2      50

# Percentages of non-missing only
summarize_data(df, Design, na_in_percent = FALSE)
#> # A tibble: 2 × 4
#>   Design Studies Frequency Percent
#>   <chr>  <chr>       <int>   <dbl>
#> 1 Cohort S2              1    33.3
#> 2 RCT    S1, S4          2    66.7
```
