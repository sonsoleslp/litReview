#' Create a Waffle Chart
#'
#' Summarizes a column and displays frequencies as a grid of colored squares.
#' Each square represents one occurrence. Returns a [ggplot2::ggplot] object.
#'
#' @param data A data frame with at least a study ID column and the column
#'   named by `col`.
#' @param col Column to visualize (quoted or unquoted).
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param colors Character vector. Fill colors cycled across categories.
#'   Defaults to [PALETTE].
#' @param ncol Integer. Number of columns in the grid. Defaults to `5`.
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
#' reviewWaffle(df, Design)
#'
#' @export
reviewWaffle <- function(data, col, sep = "\r\n", colors = PALETTE, ncol = 5,
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

  expanded <- summary_data[rep(seq_len(nrow(summary_data)), summary_data$Frequency), ]
  n <- nrow(expanded)
  expanded$x <- (seq_len(n) - 1) %% ncol + 1
  expanded$y <- (seq_len(n) - 1) %/% ncol + 1
  expanded[[col_name]] <- factor(expanded[[col_name]], levels = summary_data[[col_name]])

  tile_lw <- base_size / 8
  colors <- recycle_colors(colors, nlevels(expanded[[col_name]]))

  ggplot2::ggplot(expanded, ggplot2::aes(
    x = .data$x, y = .data$y, fill = !!col_sym
  )) +
    ggplot2::geom_tile(color = "white", linewidth = tile_lw) +
    ggplot2::scale_fill_manual(values = colors) +
    ggplot2::scale_y_reverse() +
    ggplot2::coord_equal() +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      axis.text  = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::labs(fill = col_name)
}
