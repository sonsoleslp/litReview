# Create a Year-Trend Bar Chart

Shows how the values in a column distribute across publication years as
a stacked bar chart. Returns a
[ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Usage

``` r
reviewTrend(
  data,
  col,
  year_col = Year,
  sep = "\r\n",
  colors = PALETTE,
  base_size = 12,
  na.rm = TRUE,
  na_label = "Not reported",
  labels = c("none", "count", "percent", "both", "studies"),
  study_id = StudyID
)
```

## Arguments

- data:

  A data frame with at least `StudyID` (or the column set by
  `study_id`), the column named by `col`, and a year column.

- col:

  Column to visualize (quoted or unquoted).

- year_col:

  Year column (quoted or unquoted). Defaults to `Year`.

- sep:

  Character. Separator for multi-value cells. Defaults to `"\r\n"`.

- colors:

  Character vector. Fill colors cycled across categories. Defaults to
  [PALETTE](https://sonsoles.me/litReview/reference/PALETTE.md).

- base_size:

  Numeric. Base font size in points. Defaults to `12`.

- na.rm:

  Logical. Drop missing values? Defaults to `TRUE`.

- na_label:

  Character. Label for missing values when `na.rm = FALSE`. Defaults to
  `"Not reported"`.

- labels:

  Character. What to display on each bar segment. One of `"none"`
  (default), `"count"`, `"percent"` (within-year), `"both"` (count and
  percent), or `"studies"` (comma-separated study IDs).

- study_id:

  Column containing study identifiers (quoted or unquoted). Used when
  `labels = "studies"`. Defaults to `StudyID`.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Examples

``` r
df <- data.frame(
  StudyID = c("S1", "S2", "S3", "S4"),
  Year    = c(2020, 2021, 2021, 2022),
  Design  = c("RCT", "Cohort", "RCT", "Case-control"),
  stringsAsFactors = FALSE
)
reviewTrend(df, Design)

reviewTrend(df, Design, labels = "count")

reviewTrend(df, Design, labels = "percent")

reviewTrend(df, Design, labels = "studies")

```
