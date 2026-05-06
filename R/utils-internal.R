#' Move the NA-label row to the first position in a summary data frame
#'
#' In horizontal bar charts the first row maps to the bottom of the figure,
#' so placing the NA row first makes it appear last visually.
#'
#' @param data A data frame with a column `col_name`.
#' @param col_name Character. Column to check.
#' @param na_label Character. The label that marks the missing-value row.
#' @param do Logical. If `FALSE`, return `data` unchanged.
#' @return A data frame with the NA row moved to the first position.
#' @noRd
move_na_last <- function(data, col_name, na_label, do) {
  if (!do) return(data)
  is_na_row <- data[[col_name]] == na_label
  if (!any(is_na_row)) return(data)
  rbind(data[is_na_row, , drop = FALSE], data[!is_na_row, , drop = FALSE])
}

#' Recycle a color vector to the required length
#'
#' Named vectors are returned as-is (ggplot2 matches by name).
#' Unnamed vectors shorter than `n` are recycled with `rep_len`.
#' @param colors Character vector of colors.
#' @param n Integer. Number of categories.
#' @return Character vector of length >= `n`.
#' @noRd
recycle_colors <- function(colors, n) {
  if (!is.null(names(colors))) return(colors)
  if (length(colors) < n) rep_len(colors, n) else colors
}

#' Lighten a hex color by blending toward white
#'
#' @param hex Character. A hex color like `"#7BB0D1"`.
#' @param amount Numeric 0--1. 0 = unchanged, 1 = white.
#' @return Character. Lightened hex color.
#' @noRd
lighten_color <- function(hex, amount = 0.5) {
  rgb_vals <- grDevices::col2rgb(hex)[, 1]
  blended <- as.integer(rgb_vals + (255 - rgb_vals) * amount)
  grDevices::rgb(blended[1], blended[2], blended[3], maxColorValue = 255)
}

#' Split a multi-value column into long format
#'
#' @param data A data frame.
#' @param col_name Character. Column name to split.
#' @param sep Character. Delimiter.
#' @return A data frame with one value per row in `col_name`.
#' @noRd
split_col <- function(data, col_name, sep = "\r\n") {
  # Normalize \r\n to \n so splitting works regardless of line ending style
  if (sep == "\r\n") {
    data[[col_name]] <- gsub("\r\n", "\n", data[[col_name]], fixed = TRUE)
    sep <- "\n"
  }
  data <- tidyr::separate_longer_delim(data, !!rlang::sym(col_name), delim = sep)
  data[[col_name]] <- trimws(data[[col_name]])
  data
}

#' Detect missing values in a character column
#'
#' Treats R `NA` and empty / whitespace-only strings as missing.
#' @param x Character vector.
#' @return Logical vector.
#' @noRd
is_missing <- function(x) {
  is.na(x) | trimws(x) == ""
}

#' Handle NAs in a split column
#'
#' Either removes missing rows or renames them. Applied *after* splitting.
#' @param data A data frame.
#' @param col_name Character. Column to check.
#' @param na.rm Logical. Drop missing rows?
#' @param na_label Character. Replacement label if `na.rm = FALSE`.
#' @return A data frame.
#' @noRd
handle_na <- function(data, col_name, na.rm = TRUE, na_label = "Not reported") {
  missing <- is_missing(data[[col_name]])
  if (na.rm) {
    data[!missing, , drop = FALSE]
  } else {
    data[[col_name]][missing] <- na_label
    data
  }
}

#' Count occurrences of values in a column (after splitting)
#'
#' Shared helper for reviewOverlap, reviewTrend, reviewMap.
#'
#' @param data A data frame.
#' @param col_name Character. Column name to count.
#' @param sep Character. Delimiter for multi-value cells.
#' @return A data frame with the column and an `n` count column.
#' @noRd
count_col <- function(data, col_name, sep = "\r\n") {
  data |>
    split_col(col_name, sep) |>
    dplyr::group_by(!!rlang::sym(col_name)) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")
}

#' Validate common inputs
#'
#' @param data A data frame.
#' @param col_name Character. Column name that must exist.
#' @param id_name Character or NULL. Study ID column name.
#' @noRd
validate_inputs <- function(data, col_name, id_name = NULL) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.obj_type_of {data}}.")
  }
  if (nrow(data) == 0L) {
    cli::cli_abort("{.arg data} has 0 rows.")
  }
  if (!col_name %in% names(data)) {
    cli::cli_abort("Column {.val {col_name}} not found in {.arg data}.")
  }
  if (!is.null(id_name) && !id_name %in% names(data)) {
    cli::cli_abort(
      "Study ID column {.val {id_name}} not found in {.arg data}. Set {.arg study_id} to the correct column."
    )
  }
}

#' Common country name aliases for map_data("world")
#' @noRd
COUNTRY_ALIASES <- c(
  "United States"          = "USA",
  "United States of America" = "USA",
  "US"                     = "USA",
  "United Kingdom"         = "UK",
  "Great Britain"          = "UK",
  "England"                = "UK",
  "Republic of Korea"      = "South Korea",
  "Korea, South"           = "South Korea",
  "Korea, Republic of"     = "South Korea",
  "Korea, North"           = "North Korea",
  "Russian Federation"     = "Russia",
  "Czechia"                = "Czech Republic",
  "Ivory Coast"            = "Cote d'Ivoire",
  "Congo, Democratic Republic" = "Democratic Republic of the Congo",
  "DR Congo"               = "Democratic Republic of the Congo",
  "DRC"                    = "Democratic Republic of the Congo",
  "UAE"                    = "United Arab Emirates",
  "Republic of Ireland"    = "Ireland",
  "Timor-Leste"            = "East Timor",
  "Burma"                  = "Myanmar",
  "Swaziland"              = "Eswatini",
  "Holland"                = "Netherlands",
  "The Netherlands"        = "Netherlands",
  "People\u2019s Republic of China" = "China",
  "PRC"                    = "China",
  "ROC"                    = "Taiwan",
  "T\u00fcrkiye"             = "Turkey",
  "Turkiye"                = "Turkey"
)

#' Normalise country names to map_data("world") region names
#' @param x Character vector of country names.
#' @return Character vector with aliases resolved.
#' @noRd
normalise_countries <- function(x) {
  idx <- match(x, names(COUNTRY_ALIASES))
  replaced <- !is.na(idx)
  x[replaced] <- COUNTRY_ALIASES[idx[replaced]]
  x
}
