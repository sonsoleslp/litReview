# Create an Alluvial (Sankey) Plot

Shows co-occurrence and flow between categories across multiple columns.
Each study traces a path through the strata. Requires the ggalluvial
package.

## Usage

``` r
reviewAlluvial(
  data,
  cols,
  sep = "\r\n",
  study_id = StudyID,
  colors = PALETTE,
  base_size = 12,
  na.rm = TRUE,
  na_label = "Not reported",
  labels = c("none", "prop", "count", "both"),
  flow_labels = FALSE,
  flow_alpha = 0.25,
  stratum_width = 0.5,
  axis_labels = NULL
)
```

## Arguments

- data:

  A data frame.

- cols:

  Character vector of column names to use as axes (left to right).

- sep:

  Character. Separator for multi-value cells. Defaults to `"\r\n"`. When
  a column contains multi-value cells, each combination generates a
  separate alluvium.

- study_id:

  Column containing study identifiers (quoted or unquoted). Defaults to
  `StudyID`.

- colors:

  Character vector. Fill colors for strata, cycled or matched by name.
  Defaults to
  [PALETTE](https://sonsoles.me/litReview/reference/PALETTE.md).

- base_size:

  Numeric. Base font size in points. Defaults to `12`.

- na.rm:

  Logical. Drop rows with missing values? Defaults to `TRUE`.

- na_label:

  Character. Label for missing values when `na.rm = FALSE`. Defaults to
  `"Not reported"`.

- labels:

  Character. What to show on each stratum. One of `"none"` (default),
  `"prop"` (proportion within axis), `"count"`, or `"both"` (count and
  proportion).

- flow_labels:

  Logical. If `TRUE`, show counts on the flows between strata. Defaults
  to `FALSE`.

- flow_alpha:

  Numeric. Transparency of flows (0–1). Defaults to `0.25`.

- stratum_width:

  Numeric. Width of stratum bars. Defaults to `0.5`.

- axis_labels:

  Character vector of custom axis labels (same length as `cols`), or
  `NULL` to use the column names. Defaults to `NULL`.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- data.frame(
  StudyID  = paste0("S", 1:6),
  Design   = c("RCT", "Cohort", "RCT", "RCT", "Cohort", "RCT"),
  Quality  = c("High", "Low", "High", "Low", "Low", "High"),
  Outcome  = c("Positive", "Negative", "Positive", "Negative",
               "Positive", "Positive"),
  stringsAsFactors = FALSE
)
reviewAlluvial(df, c("Design", "Quality", "Outcome"))
} # }
```
