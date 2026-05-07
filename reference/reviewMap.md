# Create a World Map of Study Counts

Counts the number of studies per country and shades a world map
accordingly. Common country name aliases (e.g. `"United States"` -\>
`"USA"`, `"United Kingdom"` -\> `"UK"`) are resolved automatically.
Returns a
[ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Usage

``` r
reviewMap(
  data,
  country_col = Country,
  sep = "\r\n",
  fill = "#7BB0D1",
  base_size = 12,
  na.rm = TRUE
)
```

## Arguments

- data:

  A data frame with at least the column named by `country_col`.

- country_col:

  Country column (quoted or unquoted). Defaults to `Country`.

- sep:

  Character. Separator for multi-value cells. Defaults to `"\r\n"`.

- fill:

  Character. High-end color for the gradient. Defaults to `"#7BB0D1"`.

- base_size:

  Numeric. Base font size in points. Defaults to `12`.

- na.rm:

  Logical. Drop missing values? Defaults to `TRUE`.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Examples

``` r
df <- data.frame(
  StudyID = c("S1", "S2", "S3"),
  Country = c("Spain", "Spain", "Germany"),
  stringsAsFactors = FALSE
)
reviewMap(df)

```
