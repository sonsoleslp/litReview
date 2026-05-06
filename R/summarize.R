#' Summarize Frequency of Values in a Column
#'
#' Splits multi-value cells, counts frequencies, and computes percentages.
#'
#' @param data A data frame containing at least the columns specified by
#'   `col` and `study_id`.
#' @param col Column to summarize (quoted or unquoted).
#' @param sep Character. The separator used to split multi-value cells.
#'   Defaults to `"\r\n"`.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Defaults to `StudyID`.
#' @param na.rm Logical. If `TRUE` (default), rows with missing values (`NA`
#'   or empty strings) in `col` are dropped. If `FALSE`, they are kept and
#'   labelled with `na_label`.
#' @param na_label Character. Label used for missing values when
#'   `na.rm = FALSE`. Defaults to `"Not reported"`.
#' @param na_in_percent Logical. If `TRUE` (default), the denominator for
#'   percentages is the total number of rows (including missing). If `FALSE`,
#'   only non-missing rows are counted, so non-missing categories sum to
#'   \eqn{\approx 100\%}.
#' @param na_last Logical. If `TRUE`, the missing-value row (when
#'   `na.rm = FALSE`) is placed at the bottom of the result regardless of
#'   its frequency. Defaults to `FALSE` (sorted by frequency like all other
#'   rows).
#'
#' @return A data frame with columns for the grouping variable, `Studies`
#'   (comma-separated study IDs), `Frequency`, and `Percent` (numeric, 0--100).
#'
#' @examples
#' df <- data.frame(
#'   StudyID = c("S1", "S2", "S3", "S4"),
#'   Design = c("RCT", "Cohort", NA, "RCT"),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Drop NAs (default)
#' summarize_data(df, Design)
#'
#' # Keep NAs with a custom label
#' summarize_data(df, Design, na.rm = FALSE, na_label = "Missing")
#'
#' # Percentages of non-missing only
#' summarize_data(df, Design, na_in_percent = FALSE)
#'
#' @importFrom rlang ensym as_name
#' @importFrom dplyr group_by summarise mutate arrange n desc
#' @export
summarize_data <- function(data, col, sep = "\r\n", study_id = StudyID,
                           na.rm = TRUE, na_label = "Not reported",
                           na_in_percent = TRUE, na_last = FALSE) {
  col_sym <- rlang::ensym(col)
  col_name <- rlang::as_name(col_sym)
  id_sym <- rlang::ensym(study_id)
  id_name <- rlang::as_name(id_sym)

  validate_inputs(data, col_name, id_name)

  # Compute denominator before splitting
  if (na_in_percent) {
    total <- nrow(data)
  } else {
    total <- sum(!is_missing(data[[col_name]]))
  }
  if (total == 0L) {
    cli::cli_abort("All values in {.val {col_name}} are missing.")
  }

  data |>
    split_col(col_name, sep) |>
    handle_na(col_name, na.rm = na.rm, na_label = na_label) |>
    dplyr::group_by(!!col_sym) |>
    dplyr::summarise(
      Studies = paste(!!id_sym, collapse = ", "),
      Frequency = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      Percent = round(.data$Frequency / total * 100, 1)
    ) |>
    dplyr::arrange(.data$Frequency, dplyr::desc(!!col_sym)) |>
    move_na_last(col_name, na_label, na_last && !na.rm)
}
