#' Create an Alluvial (Sankey) Plot
#'
#' Shows co-occurrence and flow between categories across multiple columns.
#' Each study traces a path through the strata. Requires the
#' \pkg{ggalluvial} package.
#'
#' @param data A data frame.
#' @param cols Character vector of column names to use as axes (left to right).
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#'   When a column contains multi-value cells, each combination generates a
#'   separate alluvium.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Defaults to `StudyID`.
#' @param colors Character vector. Fill colors for strata, cycled or matched
#'   by name. Defaults to [PALETTE].
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#' @param na.rm Logical. Drop rows with missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param labels Character. What to show on each stratum. One of `"none"`
#'   (default), `"prop"` (proportion within axis), or `"count"`.
#' @param flow_labels Logical. If `TRUE`, show counts on the flows between
#'   strata. Defaults to `FALSE`.
#' @param flow_alpha Numeric. Transparency of flows (0--1). Defaults to `0.25`.
#' @param stratum_width Numeric. Width of stratum bars. Defaults to `0.5`.
#' @param axis_labels Character vector of custom axis labels (same length as
#'   `cols`), or `NULL` to use the column names. Defaults to `NULL`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   StudyID  = paste0("S", 1:6),
#'   Design   = c("RCT", "Cohort", "RCT", "RCT", "Cohort", "RCT"),
#'   Quality  = c("High", "Low", "High", "Low", "Low", "High"),
#'   Outcome  = c("Positive", "Negative", "Positive", "Negative",
#'                "Positive", "Positive"),
#'   stringsAsFactors = FALSE
#' )
#' reviewAlluvial(df, c("Design", "Quality", "Outcome"))
#' }
#'
#' @export
reviewAlluvial <- function(data, cols, sep = "\r\n", study_id = StudyID,
                           colors = PALETTE, base_size = 12,
                           na.rm = TRUE, na_label = "Not reported",
                           labels = c("none", "prop", "count"),
                           flow_labels = FALSE, flow_alpha = 0.25,
                           stratum_width = 0.5, axis_labels = NULL) {
  rlang::check_installed("ggalluvial",
                         reason = "to draw alluvial plots with reviewAlluvial()")

  id_sym <- rlang::ensym(study_id)
  id_name <- rlang::as_name(id_sym)
  labels <- match.arg(labels)

  # Validate
  for (col_name in cols) validate_inputs(data, col_name)
  if (!id_name %in% names(data)) {
    cli::cli_abort(
      "Study ID column {.val {id_name}} not found in {.arg data}. Set {.arg study_id}."
    )
  }

  # Subset, split multi-value cells, and handle NAs
  plot_data <- data[, c(id_name, cols), drop = FALSE]
  for (col_name in cols) {
    plot_data <- split_col(plot_data, col_name, sep)
    plot_data <- handle_na(plot_data, col_name, na.rm = na.rm,
                           na_label = na_label)
  }
  # After splitting, a single study may have multiple rows — give each a

  # unique alluvium id so every combination traces its own flow.
  plot_data$.alluvium <- seq_len(nrow(plot_data))

  # Convert to lodes (long) form
  axes <- match(cols, names(plot_data))
  lodes <- ggalluvial::to_lodes_form(plot_data, axes = axes, id = ".alluvium")

  # Compute proportions per axis
  lodes$Freq <- 1
  lodes <- lodes |>
    dplyr::group_by(.data$x) |>
    dplyr::mutate(Total = dplyr::n()) |>
    dplyr::ungroup() |>
    dplyr::mutate(Prop = .data$Freq / .data$Total)

  # Colors
  all_strata <- unique(as.character(lodes$stratum))
  colors <- recycle_colors(colors, length(all_strata))

  label_size <- base_size * 0.7 / ggplot2::.pt

  p <- ggplot2::ggplot(lodes, ggplot2::aes(
    x = .data$x, stratum = .data$stratum,
    alluvium = .data$.alluvium,
    y = .data$Prop, fill = .data$stratum
  )) +
    ggalluvial::geom_flow(
      width = stratum_width, alpha = flow_alpha,
      curve_type = "sine", aes.flow = "backward"
    ) +
    ggalluvial::geom_stratum(width = stratum_width, color = "white") +
    ggplot2::scale_fill_manual(values = colors) +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      legend.position = "none",
      axis.text.y  = ggplot2::element_blank(),
      axis.title   = ggplot2::element_blank(),
      panel.grid   = ggplot2::element_blank()
    )

  # Stratum labels: combine name + optional stat into one centered label
  # StatStratum computes: n (observation count), prop (within-axis proportion)
  if (labels == "prop") {
    p <- p + ggplot2::geom_label(
      stat = ggalluvial::StatStratum, fill = "white",
      ggplot2::aes(label = paste0(
        ggplot2::after_stat(stratum), "\n",
        round(ggplot2::after_stat(prop) * 100, 1), "%"
      )),
      size = label_size, lineheight = 0.9
    )
  } else if (labels == "count") {
    p <- p + ggplot2::geom_label(
      stat = ggalluvial::StatStratum, fill = "white",
      ggplot2::aes(label = paste0(
        ggplot2::after_stat(stratum), "\n",
        as.integer(ggplot2::after_stat(n))
      )),
      size = label_size, lineheight = 0.9
    )
  } else {
    p <- p + ggplot2::geom_label(
      stat = ggalluvial::StatStratum, fill = "white",
      ggplot2::aes(label = ggplot2::after_stat(stratum)),
      size = label_size
    )
  }

  # Flow count labels
  if (flow_labels) {
    p <- p + ggplot2::geom_text(
      stat = ggalluvial::StatFlow,
      ggplot2::aes(
        hjust = ifelse(ggplot2::after_stat(flow) == "to", 2.75, -1.85),
        label = ggplot2::after_stat(count)
      ),
      size = label_size * 0.8, vjust = "inward"
    )
  }

  # Custom axis labels
  if (!is.null(axis_labels)) {
    p <- p + ggplot2::scale_x_discrete(labels = axis_labels)
  }

  p
}
