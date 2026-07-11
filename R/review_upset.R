#' Create an UpSet Plot of Value Combinations
#'
#' Visualizes how the values of a multi-value column co-occur across studies.
#' Each study contributes the *set* of distinct values it reports; the plot
#' shows the size of each observed combination (intersection) as a bar, with a
#' dot matrix beneath indicating which values make up that combination. This
#' scales past the pairwise [reviewOverlap()] when three or more values can
#' co-occur. Returns a standard [ggplot2::ggplot] object.
#'
#' Requires the \pkg{ggupset} package.
#'
#' @param data A data frame with at least the columns named by `col` and
#'   `study_id`.
#' @param col Multi-value column to analyze (quoted or unquoted).
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   One combination is formed per study. Defaults to `StudyID`.
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param n_intersections Integer. Maximum number of combinations (bars) to
#'   display, keeping the largest. Defaults to `15`.
#' @param sort_by Character. Order bars by `"freq"` (intersection size,
#'   default) or `"degree"` (number of values in the combination).
#' @param fill Character. Bar and matrix-dot color. Defaults to `"#7BB0D1"`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' df <- data.frame(
#'   StudyID = paste0("S", 1:5),
#'   Outcome = c("Pain", "Pain\nFunction", "Function",
#'               "Pain\nFunction\nQoL", "QoL"),
#'   stringsAsFactors = FALSE
#' )
#' if (requireNamespace("ggupset", quietly = TRUE)) {
#'   reviewUpset(df, Outcome, sep = "\n")
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_bar geom_text after_stat
#'   scale_y_continuous expansion theme element_blank labs
#' @export
reviewUpset <- function(data, col, sep = "\r\n", study_id = StudyID,
                        base_size = 12, na.rm = TRUE,
                        na_label = "Not reported", n_intersections = 15,
                        sort_by = c("freq", "degree"), fill = "#7BB0D1") {
  rlang::check_installed("ggupset", reason = "to draw UpSet plots")
  sort_by  <- match.arg(sort_by)
  col_sym  <- rlang::ensym(col)
  col_name <- rlang::as_name(col_sym)
  id_sym   <- rlang::ensym(study_id)
  id_name  <- rlang::as_name(id_sym)

  validate_inputs(data, col_name, id_name)

  long <- data |>
    split_col(col_name, sep) |>
    handle_na(col_name, na.rm = na.rm, na_label = na_label)

  # One row per study, holding the set of distinct values it reports.
  sets_df <- long |>
    dplyr::group_by(!!id_sym) |>
    dplyr::summarise(Sets = list(sort(unique(!!col_sym))), .groups = "drop")
  sets_df <- sets_df[lengths(sets_df$Sets) > 0, , drop = FALSE]

  if (nrow(sets_df) == 0L)
    cli::cli_abort("No non-missing values in {.val {col_name}} to plot.")

  text_size  <- base_size * 0.72 / ggplot2::.pt
  point_size <- base_size * 0.28

  ggplot2::ggplot(sets_df, ggplot2::aes(x = .data$Sets)) +
    ggplot2::geom_bar(fill = fill, width = 0.7) +
    ggplot2::geom_text(
      stat = "count",
      ggplot2::aes(label = ggplot2::after_stat(count)),
      vjust = -0.4, size = text_size, fontface = "bold", color = "black") +
    ggupset::scale_x_upset(order_by = sort_by,
                           n_intersections = n_intersections) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.12))) +
    ggplot2::labs(x = NULL, y = "Number of studies") +
    theme_litreview(base_size = base_size) +
    ggupset::theme_combmatrix(
      combmatrix.panel.point.color.fill = fill,
      combmatrix.panel.point.size       = point_size,
      combmatrix.label.text = ggplot2::element_text(color = "black",
                                                    size = base_size * 0.85)) +
    ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
}
