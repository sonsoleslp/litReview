#' Create a Stacked / Grouped Bar Chart
#'
#' Cross-tabulates a primary category (`col`) against a grouping variable
#' (`group`) and displays the result as horizontal stacked bars. Use
#' `position = "fill"` for within-category proportions (each bar sums to
#' 100%) or `position = "stack"` for raw counts. Both columns may contain
#' multi-value cells, which are split before counting. Returns a standard
#' [ggplot2::ggplot] object.
#'
#' @param data A data frame with at least the columns named by `col` and
#'   `group`.
#' @param col Primary category (quoted or unquoted); one horizontal bar per
#'   value.
#' @param group Grouping/splitting column (quoted or unquoted); mapped to the
#'   bar fill.
#' @param position Character. `"fill"` (default) scales each bar to 100% to
#'   compare proportions; `"stack"` shows raw counts.
#' @param fill Character vector of fill colors for the groups. Defaults to
#'   [PALETTE].
#' @param width Numeric. Bar width (0--1). Defaults to `0.7`.
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Defaults to `StudyID`. Present for API consistency; not currently used.
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param na_last Logical. If `TRUE` (and `na.rm = FALSE`), place the missing
#'   category last — at the bottom of the axis and the end of each bar/legend.
#'   Defaults to `FALSE`.
#' @param labels Logical. Draw the count (or percentage) inside each segment?
#'   Defaults to `TRUE`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' df <- data.frame(
#'   StudyID = paste0("S", 1:6),
#'   Design  = c("RCT", "Cohort", "RCT", "Cohort", "RCT", "Cohort"),
#'   Risk    = c("Low", "High", "Low", "Moderate", "High", "Low"),
#'   stringsAsFactors = FALSE
#' )
#' reviewStackedBar(df, Design, Risk)
#' reviewStackedBar(df, Design, Risk, position = "stack")
#'
#' @importFrom ggplot2 ggplot aes geom_col geom_text scale_fill_manual
#'   scale_x_continuous position_fill position_stack expansion theme
#'   element_text element_blank labs
#' @export
reviewStackedBar <- function(data, col, group,
                             position = c("fill", "stack"),
                             fill = PALETTE, width = 0.7, sep = "\r\n",
                             study_id = StudyID, base_size = 12,
                             na.rm = TRUE, na_label = "Not reported",
                             na_last = FALSE, labels = TRUE) {
  position <- match.arg(position)
  col_sym  <- rlang::ensym(col)
  grp_sym  <- rlang::ensym(group)
  col_name <- rlang::as_name(col_sym)
  grp_name <- rlang::as_name(grp_sym)

  validate_inputs(data, col_name)
  validate_inputs(data, grp_name)

  expanded <- data |>
    split_col(col_name, sep) |>
    handle_na(col_name, na.rm = na.rm, na_label = na_label) |>
    split_col(grp_name, sep) |>
    handle_na(grp_name, na.rm = na.rm, na_label = na_label)

  counts <- expanded |>
    dplyr::group_by(!!col_sym, !!grp_sym) |>
    dplyr::summarise(Frequency = dplyr::n(), .groups = "drop")

  keep_na <- !na.rm && isTRUE(na_last)

  # Order primary categories by total frequency (largest at the top).
  # With na_last, the missing category is pushed to the bottom of the axis.
  col_tot <- counts |>
    dplyr::group_by(!!col_sym) |>
    dplyr::summarise(tot = sum(.data$Frequency), .groups = "drop") |>
    dplyr::arrange(.data$tot)
  col_levels <- as.character(col_tot[[col_name]])
  if (keep_na && na_label %in% col_levels)
    col_levels <- c(na_label, setdiff(col_levels, na_label))
  counts[[col_name]] <- factor(counts[[col_name]], levels = col_levels)

  # Order groups by total frequency (largest first in stack and legend);
  # na_last sends the missing group to the end of each bar and the legend.
  grp_tot <- counts |>
    dplyr::group_by(!!grp_sym) |>
    dplyr::summarise(tot = sum(.data$Frequency), .groups = "drop") |>
    dplyr::arrange(dplyr::desc(.data$tot))
  grp_levels <- levels_na_last(as.character(grp_tot[[grp_name]]), na_label, keep_na)
  counts[[grp_name]] <- factor(counts[[grp_name]], levels = grp_levels)

  # Within-bar percentage (used for fill-mode labels)
  counts <- counts |>
    dplyr::group_by(!!col_sym) |>
    dplyr::mutate(Percent = .data$Frequency / sum(.data$Frequency) * 100) |>
    dplyr::ungroup()

  counts$lab <- if (position == "fill")
    paste0(round(counts$Percent), "%") else as.character(counts$Frequency)
  # Suppress labels on slivers that have no room for text
  if (position == "fill") counts$lab[counts$Percent < 6] <- ""

  n_grp     <- nlevels(counts[[grp_name]])
  pal       <- recycle_colors(fill, n_grp)
  text_size <- base_size * 0.72 / ggplot2::.pt
  bar_pos   <- if (position == "fill") "fill" else "stack"
  txt_pos   <- if (position == "fill")
    ggplot2::position_fill(vjust = 0.5) else ggplot2::position_stack(vjust = 0.5)

  p <- ggplot2::ggplot(counts, ggplot2::aes(
      x = .data$Frequency, y = !!col_sym, fill = !!grp_sym)) +
    ggplot2::geom_col(width = width, position = bar_pos) +
    ggplot2::scale_fill_manual(values = pal, drop = FALSE) +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      axis.text.y        = ggplot2::element_text(face = "bold"),
      panel.grid.major.y = ggplot2::element_blank()) +
    ggplot2::labs(
      x    = if (position == "fill") "Percent of studies" else "Number of studies",
      y    = col_name, fill = grp_name)

  p <- p + if (position == "fill") {
    ggplot2::scale_x_continuous(expand = c(0, 0),
                                labels = function(x) paste0(x * 100, "%"))
  } else {
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.05)))
  }

  if (isTRUE(labels)) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = .data$lab), position = txt_pos,
      size = text_size, color = "black")
  }
  p
}
