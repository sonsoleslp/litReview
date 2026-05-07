# Create a Treemap

Displays category frequencies as nested rectangles whose area is
proportional to the count. Optionally color by a second column for a
hierarchical view. Requires the treemapify package.

## Usage

``` r
reviewTreemap(
  data,
  col,
  color_by = NULL,
  sep = "\r\n",
  colors = PALETTE,
  base_size = 12,
  na.rm = TRUE,
  na_label = "Not reported",
  study_id = StudyID,
  studlabs = FALSE,
  border_col = "white"
)
```

## Arguments

- data:

  A data frame.

- col:

  Column whose values define the rectangles (quoted or unquoted).

- color_by:

  Optional second column (quoted or unquoted) used to fill the
  rectangles. When supplied the treemap is grouped hierarchically by
  `color_by`, with `col` nested inside. When `NULL` (default),
  rectangles are colored by `col` itself.

- sep:

  Character. Separator for multi-value cells. Defaults to `"\r\n"`.

- colors:

  Character vector. Fill colors, cycled or matched by name. Defaults to
  [PALETTE](https://sonsoles.me/litReview/reference/PALETTE.md).

- base_size:

  Numeric. Base font size in points. Defaults to `12`.

- na.rm:

  Logical. Drop missing values? Defaults to `TRUE`.

- na_label:

  Character. Label for missing values when `na.rm = FALSE`. Defaults to
  `"Not reported"`.

- study_id:

  Column containing study identifiers (quoted or unquoted). Defaults to
  `StudyID`.

- studlabs:

  Logical. If `TRUE`, show study IDs inside each rectangle. Defaults to
  `FALSE`.

- border_col:

  Character. Color of rectangle borders. Defaults to `"white"`.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- data.frame(
  StudyID = paste0("S", 1:8),
  Design  = c("RCT", "Cohort", "RCT", "RCT", "Cohort", "RCT", "Cohort", "RCT"),
  Quality = c("High", "Low", "High", "Low", "Low", "High", "Low", "High"),
  stringsAsFactors = FALSE
)
reviewTreemap(df, Design)
reviewTreemap(df, Design, color_by = Quality)
} # }
```
