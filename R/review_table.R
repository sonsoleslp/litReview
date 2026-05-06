#' Create a Summary Table
#'
#' Summarizes a column from literature review data and returns a formatted
#' [gt::gt()] table showing each category, its associated study IDs,
#' frequency, and percentage.
#'
#' @param data A data frame with at least a study ID column and the column
#'   named by `col`.
#' @param col Column to summarize (quoted or unquoted).
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param study_id Column containing study identifiers (quoted or unquoted).
#'   Defaults to `StudyID`.
#' @param latex Logical. If `TRUE`, returns the table as LaTeX code via
#'   [gt::as_latex()] instead of a [gt::gt()] object. Defaults to `FALSE`.
#' @param cite Logical. If `TRUE`, treats values in `study_id` as BibTeX
#'   reference keys and wraps the per-row study list in `\\cite{...}`.
#'   Defaults to `FALSE`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param na_in_percent Logical. Include missing rows in the percentage
#'   denominator? Defaults to `TRUE`.
#' @param na_last Logical. If `TRUE`, place the missing-value category last
#'   regardless of its frequency. Defaults to `FALSE`.
#'
#' @return A [gt::gt()] table, or a LaTeX character object if `latex = TRUE`.
#'
#' @examples
#' df <- data.frame(
#'   StudyID = c("S1", "S2", "S3", "S4"),
#'   Design = c("RCT", "Cohort", "RCT", "Case-control"),
#'   stringsAsFactors = FALSE
#' )
#' reviewTable(df, Design)
#' reviewTable(df, Design, latex = TRUE, cite = TRUE)
#'
#' @importFrom gt gt as_latex fmt_passthrough
#' @export
reviewTable <- function(data, col, sep = "\r\n", study_id = StudyID,
                        latex = FALSE, cite = FALSE, na.rm = TRUE,
                        na_label = "Not reported", na_in_percent = TRUE,
                        na_last = FALSE) {
  col_sym <- rlang::ensym(col)
  id_sym <- rlang::ensym(study_id)

  summary_data <- summarize_data(data, !!col_sym, sep = sep, study_id = !!id_sym,
                                  na.rm = na.rm, na_label = na_label,
                                  na_in_percent = na_in_percent,
                                  na_last = na_last) |>
    dplyr::mutate(
      Percent = paste0(.data$Percent, "%")
    ) |>
    dplyr::arrange(dplyr::desc(!!col_sym))

  if (cite) {
    summary_data <- summary_data |>
      dplyr::mutate(
        Studies = paste0("\\cite{", gsub(", ", ",", .data$Studies, fixed = TRUE), "}")
      )
  }

  tbl <- gt::gt(summary_data)
  if (cite) {
    tbl <- gt::fmt_passthrough(tbl, columns = "Studies", escape = FALSE)
  }
  if (latex) gt::as_latex(tbl) else tbl
}
