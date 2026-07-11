#' Create a Summary Bar Chart
#'
#' Summarizes a column from literature review data and produces a horizontal
#' bar chart with frequency and percentage labels. Returns a standard
#' [ggplot2::ggplot] object that can be customized with `+`.
#'
#' @param data A data frame with at least a study ID column and the column
#'   named by `col`.
#' @param col Column to visualize (quoted or unquoted).
#' @param fill Character. Bar fill color. Defaults to `"#7BB0D1"`.
#' @param width Numeric. Bar width (0--1). Defaults to `0.5`.
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param studlabs Logical. If `TRUE`, draws study ID labels on bars using
#'   [ggfittext::geom_bar_text()]. Defaults to `FALSE`.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Defaults to `StudyID`.
#' @param label_space Numeric. Multiplier for x-axis headroom to fit labels.
#'   Defaults to `1.6`.
#' @param base_size Numeric. Base font size in points; controls proportional
#'   scaling of all text and elements. Defaults to `12`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param na_in_percent Logical. Include missing rows in the percentage
#'   denominator? Defaults to `TRUE`.
#' @param na_last Logical. If `TRUE`, place the missing-value category last
#'   regardless of its frequency. Defaults to `FALSE`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' df <- data.frame(
#'   StudyID = c("S1", "S2", "S3", "S4"),
#'   Design = c("RCT", "Cohort", "RCT", "Case-control"),
#'   stringsAsFactors = FALSE
#' )
#' reviewBar(df, Design)
#' reviewBar(df, Design, fill = "#59a14f") + ggplot2::labs(title = "Designs")
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_bar scale_x_continuous
#'   theme element_text element_blank element_rect margin labs
#'   coord_cartesian position_nudge rel
#' @importFrom ggtext geom_richtext
#' @export
reviewBar <- function(data, col, fill = "#7BB0D1", width = 0.6,
                      sep = "\r\n", studlabs = FALSE,
                      study_id = StudyID, label_space = 1.6,
                      base_size = 12, na.rm = TRUE,
                      na_label = "Not reported", na_in_percent = TRUE,
                      na_last = FALSE) {
  col_sym <- rlang::ensym(col)
  col_name <- rlang::as_name(col_sym)
  id_sym <- rlang::ensym(study_id)

  summary_data <- summarize_data(data, !!col_sym, sep = sep, study_id = !!id_sym,
                                  na.rm = na.rm, na_label = na_label,
                                  na_in_percent = na_in_percent,
                                  na_last = na_last)
  summary_data[[col_name]] <- factor(summary_data[[col_name]],
                                     levels = summary_data[[col_name]])
  summary_data$label <- paste0(
    "<b>", summary_data$Frequency, "</b> (",
    round(summary_data$Percent, 1), "%)"
  )

  max_x <- max(summary_data$Frequency) * label_space

  # Proportional sizes derived from base_size and number of categories
  n_cats <- nrow(summary_data)
  # A single ColorBrewer palette name expands to one colour per bar
  fill <- resolve_palette(fill, n_cats)
  label_size <- base_size / ggplot2::.pt
  circle_size <- base_size * 0.6 * min(1, 8 / n_cats)
  margin_r <- base_size * 1.5

  use_scale <- length(fill) > 1

  p <- ggplot2::ggplot(summary_data, ggplot2::aes(
    y = !!col_sym, x = .data$Frequency
  )) +
    ggplot2::geom_point(
      ggplot2::aes(x = .data$Frequency),
      size = circle_size, color = "#EAEAEA",
      position = ggplot2::position_nudge(x = -0.02)
    )

  if (use_scale) {
    p <- p +
      ggplot2::geom_bar(ggplot2::aes(fill = !!col_sym),
                        stat = "identity", width = width) +
      ggplot2::scale_fill_manual(values = fill)
  } else {
    p <- p +
      ggplot2::geom_bar(stat = "identity", width = width, fill = fill)
  }

  p <- p +
    ggtext::geom_richtext(
      ggplot2::aes(label = .data$label),
      hjust = -0.1, size = label_size, color = NA, fill = "transparent",
      text.colour = "black"
    ) +
    ggplot2::scale_x_continuous(
      expand = c(0, 0), limits = c(0, max_x), n.breaks = 7
    ) +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      axis.text.y        = ggplot2::element_text(face = "bold"),
      legend.position    = "none",
      panel.grid.major.y = ggplot2::element_blank(),
      plot.margin        = ggplot2::margin(base_size / 2, margin_r,
                                           base_size / 2, base_size / 2)
    ) +
    ggplot2::labs(x = "Number of studies", y = col_name) +
    ggplot2::coord_cartesian(clip = "on")

  if (isTRUE(studlabs)) {
    p <- p +
      ggfittext::geom_bar_text(
        ggplot2::aes(label = .data$Studies),
        reflow = TRUE,
        outside = TRUE,
        place = "left",
        colour = "black",
        min.size = 0,
        size = base_size * 0.7,
        padding.x = grid::unit(base_size * 0.04, "mm"),
        padding.y = grid::unit(base_size * 0.25, "mm")
      )
  }

  p
}
