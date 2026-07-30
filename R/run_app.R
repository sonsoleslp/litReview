#' Launch the litReview Shiny App
#'
#' Opens an interactive Shiny application for uploading literature review
#' data and creating summary plots. The app provides a notebook-style
#' interface where plots are added as cards that can be individually
#' downloaded or exported together as a ZIP file.
#'
#' @param ... Arguments passed to [shiny::runApp()], such as `port` or
#'   `launch.browser`.
#'
#' @return Called for its side-effect (launches the app). Returns the value
#'   of [shiny::runApp()] invisibly.
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#'
#' @export
run_app <- function(...) {
  rlang::check_installed(
    c("shiny", "bslib"),
    reason = "to run the litReview Shiny app"
  )
  app_dir <- system.file("shiny", "litReview", package = "litReview")
  if (app_dir == "") {
    cli::cli_abort(
      "Could not find the Shiny app directory. Try reinstalling {.pkg litReview}."
    )
  }
  shiny::runApp(app_dir, ...)
}
