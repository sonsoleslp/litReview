#' Create a Donut or Pie Chart
#'
#' Summarizes a column and displays frequencies as a donut (default) or pie
#' chart with count and percentage labels. Returns a [ggplot2::ggplot] object.
#'
#' @param data A data frame with at least a study ID column and the column
#'   named by `col`.
#' @param col Column to visualize (quoted or unquoted).
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param colors Character vector. Fill colors cycled across categories.
#'   Defaults to [PALETTE].
#' @param donut Logical. If `TRUE` (default), renders a donut chart. If
#'   `FALSE`, renders a filled pie chart.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Defaults to `StudyID`.
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
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
#' reviewPie(df, Design)
#' reviewPie(df, Design, donut = FALSE)
#'
#' @export
reviewPie <- function(data, col, sep = "\r\n", colors = PALETTE, donut = TRUE,
                      study_id = StudyID, base_size = 12, na.rm = TRUE,
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
                                     levels = rev(summary_data[[col_name]]))
  summary_data$label <- paste0(summary_data$Frequency, " (", summary_data$Percent, "%)")

  label_size <- base_size * 0.85 / ggplot2::.pt
  colors <- recycle_colors(colors, nlevels(summary_data[[col_name]]))

  p <- ggplot2::ggplot(
    summary_data,
    ggplot2::aes(x = 2, y = .data$Frequency, fill = !!col_sym)
  ) +
    ggplot2::geom_bar(stat = "identity", width = 1, color = "white") +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$label),
      position = ggplot2::position_stack(vjust = 0.5),
      size = label_size, color = "black"
    ) +
    ggplot2::coord_polar(theta = "y") +
    ggplot2::scale_fill_manual(values = colors) +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      axis.text  = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::labs(fill = col_name)

  if (donut) {
    p <- p + ggplot2::xlim(0.5, 2.5)
  }

  p
}
