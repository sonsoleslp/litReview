#' Default Color Palette
#'
#' A character vector of 8 hex colors for use in literature review plots.
#'
#' @details Anywhere a `colors` (or palette-style `fill`) argument accepts this
#'   vector, you may instead pass the **name of an RColorBrewer palette**
#'   (e.g. `"Set2"`, `"Dark2"`, `"Blues"`); it is expanded to the number of
#'   categories needed. For the heatmap and map fills, a sequential/diverging
#'   ColorBrewer name (e.g. `"Blues"`, `"RdYlBu"`) switches to
#'   [ggplot2::scale_fill_distiller()]. Using a ColorBrewer name requires the
#'   \pkg{RColorBrewer} package.
#'
#' @seealso [RColorBrewer::brewer.pal()]
#'
#' @examples
#' PALETTE
#' # A ColorBrewer palette name works wherever `colors` is accepted:
#' if (requireNamespace("RColorBrewer", quietly = TRUE)) {
#'   reviewWaffle(studies, Design, colors = "Set2")
#' }
#'
#' @export
PALETTE <- c(
  "#ff9da7", "#76b7b2", "#f16769", "#b07aa1",
  "#edc948", "#59a14f", "#7ea9c7", "#F28E2B"
)
