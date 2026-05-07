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
#'   (default), `"prop"` (proportion within axis), `"count"`, or `"both"`
#'   (count and proportion).
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
                           labels = c("none", "prop", "count", "both"),
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
    cli::cli_abort(c(
      "Study ID column {.val {id_name}} not found in {.arg data}.",
      "i" = "Available columns: {.val {names(data)}}.",
      "i" = "Set {.arg study_id} to the correct column."
    ))
  }

  # Subset, split multi-value cells, and handle NAs
  plot_data <- data[, c(id_name, cols), drop = FALSE]
  for (col_name in cols) {
    plot_data <- split_col(plot_data, col_name, sep)
    plot_data <- handle_na(plot_data, col_name, na.rm = na.rm,
                           na_label = na_label)
  }
  # After splitting, give each row a unique alluvium id
  plot_data$.alluvium <- seq_len(nrow(plot_data))
  n_alluvia <- nrow(plot_data)

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

  # Pre-compute stratum stats from the data (reliable, not after_stat)
  stratum_stats <- lodes |>
    dplyr::group_by(.data$x, .data$stratum) |>
    dplyr::summarise(s_n = dplyr::n(), .groups = "drop") |>
    dplyr::group_by(.data$x) |>
    dplyr::mutate(s_pct = round(.data$s_n / sum(.data$s_n) * 100, 1)) |>
    dplyr::ungroup()
  lodes <- dplyr::left_join(lodes, stratum_stats, by = c("x", "stratum"))

  # Build stratum label text
  lodes$stratum_label <- switch(labels,
    none  = paste0("<b>", lodes$stratum, "</b>"),
    count = paste0("<b>", lodes$stratum, "</b><br>", lodes$s_n),
    prop  = paste0("<b>", lodes$stratum, "</b><br>", lodes$s_pct, "%"),
    both  = paste0("<b>", lodes$stratum, "</b><br>", lodes$s_n, " (", lodes$s_pct, "%)")
  )

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
    ggtext::geom_richtext(
      stat = ggalluvial::StatStratum, fill = "white",
      ggplot2::aes(label = .data$stratum_label),
      size = label_size, color = NA, text.colour = "black",
      lineheight = if (labels == "none") 1 else 0.9
    ) +
    ggplot2::scale_fill_manual(values = colors) +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      legend.position = "none",
      axis.text.y  = ggplot2::element_blank(),
      axis.title   = ggplot2::element_blank(),
      panel.grid   = ggplot2::element_blank()
    )

  # Flow labels — position using stratum y-ranges from ggplot_build
  if (flow_labels && length(cols) >= 2) {
    built <- ggplot2::ggplot_build(p)
    # Stratum layer is layer 2 (geom_stratum); extract ymin/ymax per stratum
    stratum_layer <- built$data[[2]]

    flow_label_rows <- list()
    for (i in seq_len(length(cols) - 1)) {
      from_col <- cols[i]
      to_col <- cols[i + 1]

      # Count flows between this pair of axes
      pair <- plot_data |>
        dplyr::count(.data[[from_col]], .data[[to_col]])
      names(pair) <- c("from", "to", "n")
      total_pair <- sum(pair$n)
      pair$pct <- round(pair$n / total_pair * 100, 1)
      pair$label <- switch(labels,
        prop  = paste0(pair$pct, "%"),
        both  = paste0(pair$n, " (", pair$pct, "%)"),
        paste0(pair$n)
      )

      # Get "from" stratum positions from the built data
      from_strata <- stratum_layer[stratum_layer$x == i, ]
      from_strata$stratum_name <- levels(lodes$stratum)[from_strata$stratum]

      for (s in seq_len(nrow(from_strata))) {
        sname <- from_strata$stratum_name[s]
        symin <- from_strata$ymin[s]
        symax <- from_strata$ymax[s]
        sflows <- pair[pair$from == sname, , drop = FALSE]
        if (nrow(sflows) == 0) next
        # Stack flows within this stratum proportionally
        sflows <- sflows[order(sflows$to), ]
        stotal <- sum(sflows$n)
        sflows$y_end <- symin + cumsum(sflows$n / stotal) * (symax - symin)
        sflows$y_start <- c(symin, sflows$y_end[-nrow(sflows)])
        sflows$y <- (sflows$y_start + sflows$y_end) / 2
        sflows$x <- i + stratum_width / 2 + 0.02
        flow_label_rows <- c(flow_label_rows, list(sflows[, c("x", "y", "label")]))
      }
    }

    if (length(flow_label_rows) > 0) {
      flow_final <- do.call(rbind, flow_label_rows)
      p <- p + ggplot2::geom_text(
        data = flow_final,
        ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
        size = label_size * 0.6, color = "grey30",
        inherit.aes = FALSE
      )
    }
  }

  # Custom axis labels
  if (!is.null(axis_labels)) {
    p <- p + ggplot2::scale_x_discrete(labels = axis_labels)
  }

  p
}
