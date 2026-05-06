#' Literature Review ggplot Theme
#'
#' A clean, manuscript-ready ggplot2 theme with white background, bold axis
#' titles, and bottom legend. All `litReview` plot functions use this theme
#' by default. The single `base_size` parameter controls the proportional
#' scaling of all text and spacing — increase for posters/slides, decrease
#' for multi-panel figures.
#'
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#'
#' @return A [ggplot2::theme] object.
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_litreview()
#'
#' # Larger for presentations
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_litreview(base_size = 18)
#'
#' @export
theme_litreview <- function(base_size = 12) {
  half <- base_size / 2

  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      text               = ggplot2::element_text(color = "black"),
      axis.title         = ggplot2::element_text(face = "bold",
                                                  size = ggplot2::rel(1)),
      axis.text          = ggplot2::element_text(color = "black",
                                                  size = ggplot2::rel(0.9)),
      legend.position    = "bottom",
      legend.text        = ggplot2::element_text(size = ggplot2::rel(0.85)),
      panel.grid.minor   = ggplot2::element_blank(),
      panel.background   = ggplot2::element_rect(fill = "white", color = NA),
      plot.background    = ggplot2::element_rect(fill = "white", color = NA),
      plot.title         = ggplot2::element_text(face = "bold",
                                                  size = ggplot2::rel(1.3)),
      plot.subtitle      = ggplot2::element_text(color = "grey40",
                                                  size = ggplot2::rel(1)),
      plot.margin        = ggplot2::margin(half, half, half, half)
    )
}
