#' Create a Numeric Histogram
#'
#' Bins the values of a numeric column and plots the frequency of each bin.
#' Optionally stacks bars by a second categorical column. Returns a
#' [ggplot2::ggplot] object that can be customized with `+`.
#'
#' @param data A data frame containing at least the column named by `col`.
#' @param col Numeric column to bin (quoted or unquoted).
#' @param fill_by Optional categorical column to stack the bars by (quoted or
#'   unquoted). If `NULL` (default), bars are drawn in a single color.
#' @param bins Integer. Number of bins. Passed to
#'   [ggplot2::geom_histogram()]. Ignored when `binwidth` is set.
#'   Defaults to `30`.
#' @param binwidth Numeric. Optional bin width. Overrides `bins` when set.
#'   Defaults to `NULL`.
#' @param fill Character. Bar fill color when `fill_by` is `NULL`. Defaults to
#'   `"#7BB0D1"`.
#' @param colors Character vector. Fill colors cycled across categories when
#'   `fill_by` is set. Defaults to [PALETTE].
#' @param sep Character. Separator for multi-value cells in `fill_by`.
#'   Defaults to `"\r\n"`.
#' @param base_size Numeric. Base font size in points; controls proportional
#'   scaling of all text and elements. Defaults to `12`.
#' @param na.rm Logical. Drop rows with missing values in `col` (and, when
#'   set, in `fill_by`)? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values in `fill_by` when
#'   `na.rm = FALSE`. Defaults to `"Not reported"`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' df <- data.frame(
#'   StudyID     = paste0("S", 1:20),
#'   SampleSize  = c(30, 45, 60, 22, 88, 120, 35, 51, 74, 66,
#'                   40, 95, 110, 28, 72, 58, 41, 33, 80, 105),
#'   Design      = rep(c("RCT", "Cohort", "Case-control", "Other"), 5)
#' )
#' reviewHistogram(df, SampleSize, bins = 8)
#' reviewHistogram(df, SampleSize, fill_by = Design, bins = 8)
#'
#' @export
reviewHistogram <- function(data, col, fill_by = NULL,
                            bins = 30, binwidth = NULL,
                            fill = "#7BB0D1", colors = PALETTE,
                            sep = "\r\n", base_size = 12, na.rm = TRUE,
                            na_label = "Not reported") {
  col_sym  <- rlang::ensym(col)
  col_name <- rlang::as_name(col_sym)

  fill_by_q   <- rlang::enquo(fill_by)
  has_fill_by <- !rlang::quo_is_null(fill_by_q)
  if (has_fill_by) {
    fill_sym  <- rlang::ensym(fill_by)
    fill_name <- rlang::as_name(fill_sym)
  }

  validate_inputs(data, col_name)
  if (has_fill_by) validate_inputs(data, fill_name)

  if (!is.numeric(data[[col_name]])) {
    coerced <- suppressWarnings(as.numeric(data[[col_name]]))
    if (all(is.na(coerced))) {
      cli::cli_abort(c(
        "Column {.val {col_name}} is not numeric.",
        "i" = "{.fn reviewHistogram} requires a numeric column."
      ))
    }
    data[[col_name]] <- coerced
  }

  if (has_fill_by) {
    data <- split_col(data, fill_name, sep)
    data <- handle_na(data, fill_name, na.rm = na.rm, na_label = na_label)
  }

  if (na.rm) {
    data <- data[!is.na(data[[col_name]]), , drop = FALSE]
  }

  hist_args <- list(color = "white", linewidth = 0.3)
  if (!is.null(binwidth)) hist_args$binwidth <- binwidth else hist_args$bins <- bins

  if (has_fill_by) {
    n_cats <- length(unique(data[[fill_name]]))
    colors <- recycle_colors(colors, n_cats)
    p <- ggplot2::ggplot(data, ggplot2::aes(x = !!col_sym, fill = !!fill_sym)) +
      do.call(ggplot2::geom_histogram, hist_args) +
      ggplot2::scale_fill_manual(values = colors) +
      ggplot2::labs(x = col_name, y = "Number of studies", fill = fill_name)
  } else {
    hist_args$fill <- fill
    p <- ggplot2::ggplot(data, ggplot2::aes(x = !!col_sym)) +
      do.call(ggplot2::geom_histogram, hist_args) +
      ggplot2::labs(x = col_name, y = "Number of studies")
  }

  p +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
    theme_litreview(base_size = base_size)
}
