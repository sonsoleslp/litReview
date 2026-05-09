#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data !! :=
## usethis namespace: end
NULL

# Default column names used as function arguments (tidy eval defaults)
utils::globalVariables(c("StudyID", "Country", "Year",
                         "prop", "count", "flow", ".alluvium"))

# Register knit_print method for LaTeX output so it works in Rmd chunks
# with results = "asis" without needing cat()
.onLoad <- function(libname, pkgname) {
  if (requireNamespace("knitr", quietly = TRUE)) {
    knitr::knit_print  # force namespace load
    registerS3method("knit_print", "litreview_latex",
                     knit_print.litreview_latex,
                     envir = asNamespace("knitr"))
  }
}
