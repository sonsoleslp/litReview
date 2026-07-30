# Launch the litReview Shiny App

Opens an interactive Shiny application for uploading literature review
data and creating summary plots. The app provides a notebook-style
interface where plots are added as cards that can be individually
downloaded or exported together as a ZIP file.

## Usage

``` r
run_app(...)
```

## Arguments

- ...:

  Arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), such
  as `port` or `launch.browser`.

## Value

Called for its side-effect (launches the app). Returns the value of
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html)
invisibly.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
