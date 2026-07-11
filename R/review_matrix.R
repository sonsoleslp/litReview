#' Create a Study-by-Criteria Coding Matrix
#'
#' Draws an evidence / coding matrix: one row per study, one column per
#' criterion, and a tile wherever a study addresses a criterion. The tile
#' **fill** encodes an optional per-study attribute (e.g. document type) and the
#' **letter** inside each tile is the cell's own value (e.g. a coding level such
#' as `O`/`D`/`M`). Column headers can carry the number of studies addressing
#' each criterion. Returns a standard [ggplot2::ggplot] object.
#'
#' The input is one row per study (wide format): a study-id column, an optional
#' grouping column for the fill, and one column per criterion holding the cell
#' code (or `NA`/empty where the study does not address that criterion).
#'
#' @param data A data frame with one row per study.
#' @param cols Character vector of criterion column names, in the order they
#'   should appear on the x-axis. Each cell holds the code shown in the tile,
#'   or `NA`/`""` for no tile.
#' @param color_by Optional column name (character) giving each study's category,
#'   mapped to the tile fill (e.g. `"DocumentType"`). `NULL` (default) fills all
#'   tiles with a single color.
#' @param study_id Column with the study labels for the y-axis (quoted or
#'   unquoted). Defaults to `StudyID`.
#' @param levels Optional named character vector mapping cell codes to
#'   descriptions for the "Level" legend, e.g.
#'   `c(O = "Operationalized", D = "Discussed", M = "Mention")`. The names fix
#'   the legend order. `NULL` (default) labels the legend with the codes
#'   themselves.
#' @param colors Character vector of fill colors for the `color_by` categories.
#'   Defaults to [PALETTE].
#' @param show_counts Logical. Append `" (N=k)"` to each column header, where
#'   `k` is the number of studies addressing that criterion. Defaults to `TRUE`.
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#' @param label_wrap Integer. Wrap axis labels longer than this many characters.
#'   `NULL`/`Inf` disables. Defaults to `20`.
#' @param empty_fill Character. Fill for the background grid behind empty cells.
#'   Defaults to `"#FCFCE6"`.
#' @param tile_color Character. Border color between tiles. Defaults to
#'   `"white"`.
#' @param na.rm Logical. If `TRUE` (default), cells with a missing/empty value
#'   are left blank (the study did not address that criterion). If `FALSE`,
#'   they are drawn as an explicit tile labelled with `na_label`.
#' @param na_label Character. Code shown in unaddressed cells when
#'   `na.rm = FALSE`. Defaults to `"Not reported"`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' studies_wide <- data.frame(
#'   StudyID  = c("Tam 2024", "Schiff 2021", "Reddy 2023", "Yu 2023"),
#'   Type     = c("Journal", "Journal", "Journal", "Conference"),
#'   Accuracy = c("O", "D", "D", "M"),
#'   Equity   = c(NA, "D", "D", "O"),
#'   Ethics   = c("O", "D", "D", "O"),
#'   stringsAsFactors = FALSE
#' )
#' reviewMatrix(studies_wide, c("Accuracy", "Equity", "Ethics"),
#'              color_by = "Type",
#'              levels = c(O = "Operationalized", D = "Discussed", M = "Mention"))
#'
#' @importFrom ggplot2 ggplot aes geom_tile geom_text geom_point
#'   scale_fill_manual scale_shape_manual scale_x_discrete scale_y_discrete
#'   guides guide_legend theme element_text element_blank labs
#' @export
reviewMatrix <- function(data, cols, color_by = NULL, study_id = StudyID,
                         levels = NULL, colors = PALETTE, show_counts = TRUE,
                         base_size = 12, label_wrap = 20,
                         empty_fill = "#FCFCE6", tile_color = "white",
                         na.rm = TRUE, na_label = "Not reported") {
  id_sym  <- rlang::ensym(study_id)
  id_name <- rlang::as_name(id_sym)

  if (!is.character(cols) || length(cols) < 1L)
    cli::cli_abort("{.arg cols} must be a character vector of column names.")
  validate_inputs(data, id_name)
  missing_cols <- setdiff(c(cols, color_by), names(data))
  if (length(missing_cols))
    cli::cli_abort(c("Column{?s} {.val {missing_cols}} not found in {.arg data}.",
                     "i" = "Available columns: {.val {names(data)}}."))

  # -- Reshape to long: one row per (study, criterion) with a value + group ----
  keep <- unique(c(id_name, color_by, cols))
  long <- tidyr::pivot_longer(data[keep], dplyr::all_of(cols),
                              names_to = ".criterion", values_to = ".code")
  long$.study <- as.character(long[[id_name]])
  long$.code  <- trimws(as.character(long$.code))
  missing     <- is_missing(long$.code)
  if (isTRUE(na.rm)) {
    long$.present <- !missing
  } else {
    # Keep unaddressed cells as an explicit labelled tile
    long$.code[missing] <- na_label
    long$.present <- rep(TRUE, nrow(long))
  }

  # -- Column order and headers (optionally with counts) -----------------------
  counts <- vapply(cols, function(cc)
    sum(long$.present[long$.criterion == cc]), integer(1))
  col_label <- if (isTRUE(show_counts))
    stats::setNames(paste0(cols, " (N=", counts, ")"), cols) else
    stats::setNames(cols, cols)
  long$.criterion <- factor(long$.criterion, levels = cols,
                            labels = col_label[cols])

  # -- Row order: cluster by group (if any), first study at the top ------------
  if (!is.null(color_by)) {
    long$.group <- as.character(long[[color_by]])
    grp_levels  <- unique(long$.group)
    grp_rank    <- match(long$.group, grp_levels)
  } else {
    grp_rank <- rep(1L, nrow(long))
  }
  study_order <- unique(long$.study[order(grp_rank, match(long$.study,
                        unique(long$.study)))])
  long$.study <- factor(long$.study, levels = rev(study_order))

  present <- long[long$.present, , drop = FALSE]

  text_size  <- base_size * 0.62 / ggplot2::.pt
  tile_lw    <- base_size / 24
  wrapper    <- wrap_labels(label_wrap)

  p <- ggplot2::ggplot(long, ggplot2::aes(.data$.criterion, .data$.study)) +
    # Background grid so empty cells read as an explicit matrix
    ggplot2::geom_tile(fill = empty_fill, color = tile_color,
                       linewidth = tile_lw)

  # Filled tiles for addressed criteria
  if (!is.null(color_by)) {
    present$.group <- factor(present$.group, levels = grp_levels)
    p <- p +
      ggplot2::geom_tile(data = present,
        ggplot2::aes(fill = .data$.group), color = tile_color,
        linewidth = tile_lw) +
      ggplot2::scale_fill_manual(values = recycle_colors(colors, length(grp_levels)),
        name = color_by, drop = FALSE)
  } else {
    p <- p +
      ggplot2::geom_tile(data = present, fill = colors[1], color = tile_color,
                         linewidth = tile_lw)
  }

  # Cell codes as letters, plus a "Level" legend built from character glyphs
  code_vals <- if (!is.null(levels)) names(levels) else
    sort(unique(present$.code))
  code_labs <- if (!is.null(levels)) unname(levels) else code_vals
  present$.code <- factor(present$.code, levels = code_vals)

  p <- p +
    ggplot2::geom_text(data = present, ggplot2::aes(label = .data$.code),
                       size = text_size, fontface = "bold", color = "black") +
    ggplot2::geom_point(data = present, ggplot2::aes(shape = .data$.code),
                        alpha = 0, na.rm = TRUE) +
    ggplot2::scale_shape_manual(name = "Level", values = stats::setNames(
      code_vals, code_vals), labels = code_labs, drop = FALSE) +
    ggplot2::guides(shape = ggplot2::guide_legend(
      override.aes = list(alpha = 1, size = base_size * 0.35))) +
    ggplot2::scale_x_discrete(position = "bottom", labels = wrapper) +
    ggplot2::scale_y_discrete(labels = wrapper) +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      axis.text.x        = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid         = ggplot2::element_blank(),
      legend.position    = "right",
      legend.key         = ggplot2::element_blank()) +
    ggplot2::labs(x = NULL, y = NULL)

  p
}
