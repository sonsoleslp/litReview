#' Create a Treemap
#'
#' Displays category frequencies as nested rectangles whose area is
#' proportional to the count. Optionally color by a second column for
#' a hierarchical view. Requires the \pkg{treemapify} package.
#'
#' @param data A data frame.
#' @param col Column whose values define the rectangles (quoted or unquoted).
#' @param color_by Optional second column (quoted or unquoted) used to fill
#'   the rectangles. When supplied the treemap is grouped hierarchically by
#'   `color_by`, with `col` nested inside. When `NULL` (default), rectangles
#'   are colored by `col` itself.
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param colors Character vector. Fill colors, cycled or matched by name.
#'   Defaults to [PALETTE].
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Defaults to `StudyID`.
#' @param studlabs Logical. If `TRUE`, show study IDs inside each rectangle.
#'   Defaults to `FALSE`.
#' @param border_col Character. Color of rectangle borders. Defaults to
#'   `"white"`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   StudyID = paste0("S", 1:8),
#'   Design  = c("RCT", "Cohort", "RCT", "RCT", "Cohort", "RCT", "Cohort", "RCT"),
#'   Quality = c("High", "Low", "High", "Low", "Low", "High", "Low", "High"),
#'   stringsAsFactors = FALSE
#' )
#' reviewTreemap(df, Design)
#' reviewTreemap(df, Design, color_by = Quality)
#' }
#'
#' @export
reviewTreemap <- function(data, col, color_by = NULL, sep = "\r\n",
                          colors = PALETTE, base_size = 12,
                          na.rm = TRUE, na_label = "Not reported",
                          study_id = StudyID, studlabs = FALSE,
                          border_col = "white") {
  rlang::check_installed("treemapify",
                         reason = "to draw treemaps with reviewTreemap()")

  col_sym <- rlang::ensym(col)
  col_name <- rlang::as_name(col_sym)
  id_sym <- rlang::ensym(study_id)
  id_name <- rlang::as_name(id_sym)
  has_color <- !missing(color_by) && !is.null(rlang::enexpr(color_by))

  if (has_color) {
    color_sym <- rlang::ensym(color_by)
    color_name <- rlang::as_name(color_sym)
    validate_inputs(data, color_name)
  }
  validate_inputs(data, col_name)

  # Split and handle NAs
  plot_data <- data
  plot_data <- split_col(plot_data, col_name, sep)
  plot_data <- handle_na(plot_data, col_name, na.rm = na.rm, na_label = na_label)
  if (has_color) {
    plot_data <- split_col(plot_data, color_name, sep)
    plot_data <- handle_na(plot_data, color_name, na.rm = na.rm,
                           na_label = na_label)
  }

  # Compute counts
  if (has_color) {
    counts <- plot_data |>
      dplyr::group_by(!!col_sym, !!color_sym) |>
      dplyr::summarise(
        n = dplyr::n(),
        Studies = paste(unique(!!id_sym), collapse = ", "),
        .groups = "drop"
      )
  } else {
    counts <- plot_data |>
      dplyr::group_by(!!col_sym) |>
      dplyr::summarise(
        n = dplyr::n(),
        Studies = paste(unique(!!id_sym), collapse = ", "),
        .groups = "drop"
      )
  }

  label_size <- base_size / ggplot2::.pt
  sub_size <- label_size * 0.65

  # Build the plot
  if (has_color) {
    n_colors <- length(unique(counts[[color_name]]))
    colors <- recycle_colors(colors, n_colors)

    p <- ggplot2::ggplot(counts, ggplot2::aes(
      area = .data$n, fill = !!color_sym,
      subgroup = !!color_sym
    )) +
      treemapify::geom_treemap(color = border_col, size = base_size / 6) +
      treemapify::geom_treemap_subgroup_border(
        color = border_col, size = base_size / 3
      ) +
      treemapify::geom_treemap_text(
        ggplot2::aes(label = !!col_sym),
        fontface = "bold", colour = "black",
        size = label_size * 2.5,
        min.size = 2, reflow = TRUE, place = "centre"
      ) +
      ggplot2::scale_fill_manual(values = colors) +
      ggplot2::labs(fill = color_name)
  } else {
    n_colors <- length(unique(counts[[col_name]]))
    colors <- recycle_colors(colors, n_colors)

    p <- ggplot2::ggplot(counts, ggplot2::aes(
      area = .data$n, fill = !!col_sym
    )) +
      treemapify::geom_treemap(color = border_col, size = base_size / 6) +
      treemapify::geom_treemap_text(
        ggplot2::aes(label = !!col_sym),
        fontface = "bold", colour = "black",
        size = label_size * 2.5,
        min.size = 2, reflow = TRUE, place = "centre"
      ) +
      ggplot2::scale_fill_manual(values = colors) +
      ggplot2::labs(fill = col_name)
  }

  # Optional study labels below the category name
  if (studlabs) {
    p <- p + treemapify::geom_treemap_text(
      ggplot2::aes(label = .data$Studies),
      colour = "grey30", size = sub_size * 2,
      min.size = 1, reflow = TRUE, place = "bottom",
      padding.y = grid::unit(base_size * 0.3, "mm")
    )
  }

  p + theme_litreview(base_size = base_size)
}
