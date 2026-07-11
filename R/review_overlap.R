#' Create a Co-occurrence Heatmap
#'
#' Counts how many studies share each combination of values in two columns
#' and displays the result as a tile heatmap. Returns a [ggplot2::ggplot]
#' object.
#'
#' @param data A data frame with at least the columns named by `col1` and
#'   `col2`.
#' @param col1 First column (quoted or unquoted), mapped to the x-axis.
#' @param col2 Second column (quoted or unquoted), mapped to the y-axis.
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param fill Character. High-end color for the gradient. Defaults to
#'   `"#7BB0D1"`.
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param studlabs Logical. If `TRUE`, show comma-separated study IDs inside
#'   each tile instead of (or below) the count. Defaults to `FALSE`.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Used when `studlabs = TRUE`. Defaults to `StudyID`.
#' @param label_wrap Integer. Wrap axis tick labels longer than this many
#'   characters onto multiple lines. Set to `NULL` or `Inf` to disable.
#'   Defaults to `15`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' df <- data.frame(
#'   StudyID = c("S1", "S2", "S3", "S4"),
#'   Design  = c("RCT", "Cohort", "RCT", "Case-control"),
#'   Country = c("UK", "UK", "Spain", "Spain"),
#'   stringsAsFactors = FALSE
#' )
#' reviewOverlap(df, Design, Country)
#' reviewOverlap(df, Design, Country, studlabs = TRUE)
#'
#' @export
reviewOverlap <- function(data, col1, col2, sep = "\r\n", fill = "#7BB0D1",
                          base_size = 12, na.rm = TRUE,
                          na_label = "Not reported",
                          studlabs = FALSE, study_id = StudyID,
                          label_wrap = 15) {
  col1_sym <- rlang::ensym(col1)
  col2_sym <- rlang::ensym(col2)
  col1_name <- rlang::as_name(col1_sym)
  col2_name <- rlang::as_name(col2_sym)
  id_sym <- rlang::ensym(study_id)
  id_name <- rlang::as_name(id_sym)

  validate_inputs(data, col1_name)
  validate_inputs(data, col2_name)

  expanded <- data |>
    split_col(col1_name, sep) |>
    handle_na(col1_name, na.rm = na.rm, na_label = na_label) |>
    split_col(col2_name, sep) |>
    handle_na(col2_name, na.rm = na.rm, na_label = na_label)

  counts <- expanded |>
    dplyr::group_by(!!col1_sym, !!col2_sym) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")

  if (studlabs) {
    if (!id_name %in% names(data)) {
      cli::cli_abort(c(
        "Study ID column {.val {id_name}} not found in {.arg data}.",
        "i" = "Available columns: {.val {names(data)}}.",
        "i" = "Set {.arg study_id} for {.code studlabs = TRUE}."
      ))
    }
    study_labels <- expanded |>
      dplyr::group_by(!!col1_sym, !!col2_sym) |>
      dplyr::summarise(Studies = paste(unique(!!id_sym), collapse = ", "),
                       .groups = "drop")
    counts <- dplyr::left_join(counts, study_labels,
                               by = c(col1_name, col2_name))
  }

  tile_lw <- base_size / 15
  text_size <- base_size / ggplot2::.pt
  stud_size <- base_size * 0.55 / ggplot2::.pt

  # Wrap long tick labels onto multiple lines so they don't run off the axes.
  wrapper <- wrap_labels(label_wrap)

  p <- ggplot2::ggplot(
    counts,
    ggplot2::aes(!!col1_sym, !!col2_sym, fill = .data$n)
  ) +
    ggplot2::geom_tile(color = "white", linewidth = tile_lw) +
    fill_gradient_scale(fill) +
    ggplot2::scale_x_discrete(labels = wrapper) +
    ggplot2::scale_y_discrete(labels = wrapper) +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      axis.text.x     = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid      = ggplot2::element_blank(),
      legend.position = "none"
    ) +
    ggplot2::labs(x = col1_name, y = col2_name)

  if (studlabs) {
    p <- p +
      ggplot2::geom_text(ggplot2::aes(label = .data$n),
                         size = text_size, color = "black",
                         fontface = "bold",
                         vjust = -0.5) +
      ggplot2::geom_text(ggplot2::aes(label = .data$Studies),
                         size = stud_size, color = "black",
                         vjust = 1.2)
  } else {
    p <- p +
      ggplot2::geom_text(ggplot2::aes(label = .data$n),
                         size = text_size, color = "black")
  }

  p
}
