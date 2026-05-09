#' Create a Year-Trend Bar Chart
#'
#' Shows how the values in a column distribute across publication years as a
#' stacked bar chart. Returns a [ggplot2::ggplot] object.
#'
#' @param data A data frame with at least `StudyID` (or the column set by
#'   `study_id`), the column named by `col`, and a year column.
#' @param col Column to visualize (quoted or unquoted).
#' @param year_col Year column (quoted or unquoted). Defaults to `Year`.
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param colors Character vector. Fill colors cycled across categories.
#'   Defaults to [PALETTE].
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param labels Character. What to display on each bar segment. One of
#'   `"none"` (default), `"count"`, `"percent"` (within-year),
#'   `"both"` (count and percent), or `"studies"` (comma-separated study IDs).
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Used when `labels = "studies"`. Defaults to `StudyID`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' df <- data.frame(
#'   StudyID = c("S1", "S2", "S3", "S4"),
#'   Year    = c(2020, 2021, 2021, 2022),
#'   Design  = c("RCT", "Cohort", "RCT", "Case-control"),
#'   stringsAsFactors = FALSE
#' )
#' reviewTrend(df, Design)
#' reviewTrend(df, Design, labels = "count")
#' reviewTrend(df, Design, labels = "percent")
#' reviewTrend(df, Design, labels = "studies")
#'
#' @export
reviewTrend <- function(data, col, year_col = Year, sep = "\r\n",
                        colors = PALETTE, base_size = 12, na.rm = TRUE,
                        na_label = "Not reported",
                        labels = c("none", "count", "percent", "both", "studies"),
                        study_id = StudyID) {
  col_sym <- rlang::ensym(col)
  col_name <- rlang::as_name(col_sym)
  year_sym <- rlang::ensym(year_col)
  year_name <- rlang::as_name(year_sym)
  id_sym <- rlang::ensym(study_id)
  id_name <- rlang::as_name(id_sym)
  labels <- match.arg(labels)

  validate_inputs(data, col_name)
  validate_inputs(data, year_name)

  expanded <- data |>
    split_col(col_name, sep) |>
    handle_na(col_name, na.rm = na.rm, na_label = na_label)

  counts <- expanded |>
    dplyr::group_by(!!year_sym, !!col_sym) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")

  if (labels %in% c("percent", "both")) {
    year_totals <- counts |>
      dplyr::group_by(!!year_sym) |>
      dplyr::summarise(year_total = sum(.data$n), .groups = "drop")
    counts <- dplyr::left_join(counts, year_totals, by = year_name)
    counts$pct <- round(counts$n / counts$year_total * 100, 1)
  }

  if (labels == "studies") {
    if (!id_name %in% names(data)) {
      cli::cli_abort(c(
        "Study ID column {.val {id_name}} not found in {.arg data}.",
        "i" = "Available columns: {.val {names(data)}}.",
        "i" = "Set {.arg study_id} for {.code labels = \"studies\"}."
      ))
    }
    study_labels <- expanded |>
      dplyr::group_by(!!year_sym, !!col_sym) |>
      dplyr::summarise(study_label = paste(!!id_sym, collapse = ", "),
                       .groups = "drop")
    counts <- dplyr::left_join(counts, study_labels, by = c(year_name, col_name))
  }

  counts$bar_label <- switch(labels,
    none    = NA_character_,
    count   = as.character(counts$n),
    percent = paste0(counts$pct, "%"),
    both    = paste0(counts$n, " (", counts$pct, "%)"),
    studies = gsub(", ", "\n", counts$study_label)
  )

  n_cats <- length(unique(counts[[col_name]]))
  colors <- recycle_colors(colors, n_cats)
  label_size <- base_size * 0.7 / ggplot2::.pt

  p <- ggplot2::ggplot(
    counts,
    ggplot2::aes(x = !!year_sym, y = .data$n, fill = !!col_sym)
  ) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::scale_fill_manual(values = colors) +
    theme_litreview(base_size = base_size) +
    ggplot2::labs(x = year_name, y = "Number of studies", fill = col_name)

  if (labels != "none") {
    lh <- if (labels == "studies") 0.8 else 1
    sz <- if (labels == "studies") label_size * 0.8 else label_size
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(label = .data$bar_label),
        position = ggplot2::position_stack(vjust = 0.5),
        size = sz, lineheight = lh, color = "black"
      )
  }

  p
}
