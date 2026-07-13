# Create a Co-occurrence Heatmap

Counts how many studies share each combination of values in two columns
and displays the result as a tile heatmap. Returns a
[ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Usage

``` r
reviewOverlap(
  data,
  col1,
  col2,
  sep = "\r\n",
  fill = "#7BB0D1",
  base_size = 12,
  na.rm = TRUE,
  na_label = "Not reported",
  studlabs = FALSE,
  study_id = StudyID,
  label_wrap = 15
)
```

## Arguments

- data:

  A data frame with at least the columns named by `col1` and `col2`.

- col1:

  First column (quoted or unquoted), mapped to the x-axis.

- col2:

  Second column (quoted or unquoted), mapped to the y-axis.

- sep:

  Character. Separator for multi-value cells. Defaults to `"\r\n"`.

- fill:

  Character. High-end color for the gradient. Defaults to `"#7BB0D1"`.

- base_size:

  Numeric. Base font size in points. Defaults to `12`.

- na.rm:

  Logical. Drop missing values? Defaults to `TRUE`.

- na_label:

  Character. Label for missing values when `na.rm = FALSE`. Defaults to
  `"Not reported"`.

- studlabs:

  Logical. If `TRUE`, show comma-separated study IDs inside each tile
  instead of (or below) the count. Defaults to `FALSE`.

- study_id:

  Column containing study identifiers (quoted or unquoted). Used when
  `studlabs = TRUE`. Defaults to `StudyID`.

- label_wrap:

  Integer. Wrap axis tick labels longer than this many characters onto
  multiple lines. Set to `NULL` or `Inf` to disable. Defaults to `15`.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Examples

``` r
df <- data.frame(
  StudyID = c("S1", "S2", "S3", "S4"),
  Design  = c("RCT", "Cohort", "RCT", "Case-control"),
  Country = c("UK", "UK", "Spain", "Spain"),
  stringsAsFactors = FALSE
)
reviewOverlap(df, Design, Country)

reviewOverlap(df, Design, Country, studlabs = TRUE)

```
