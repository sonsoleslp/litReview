# Literature Review ggplot Theme

A clean, manuscript-ready ggplot2 theme with white background, bold axis
titles, and bottom legend. All `litReview` plot functions use this theme
by default. The single `base_size` parameter controls the proportional
scaling of all text and spacing — increase for posters/slides, decrease
for multi-panel figures.

## Usage

``` r
theme_litreview(base_size = 12)
```

## Arguments

- base_size:

  Numeric. Base font size in points. Defaults to `12`.

## Value

A [ggplot2::theme](https://ggplot2.tidyverse.org/reference/theme.html)
object.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_litreview()


# Larger for presentations
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_litreview(base_size = 18)

```
