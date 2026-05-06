#' Create a World Map of Study Counts
#'
#' Counts the number of studies per country and shades a world map accordingly.
#' Common country name aliases (e.g. `"United States"` -> `"USA"`,
#' `"United Kingdom"` -> `"UK"`) are resolved automatically.
#' Returns a [ggplot2::ggplot] object.
#'
#' @param data A data frame with at least the column named by `country_col`.
#' @param country_col Country column (quoted or unquoted). Defaults to
#'   `Country`.
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param fill Character. High-end color for the gradient. Defaults to
#'   `"#7BB0D1"`.
#' @param base_size Numeric. Base font size in points. Defaults to `12`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' df <- data.frame(
#'   StudyID = c("S1", "S2", "S3"),
#'   Country = c("Spain", "Spain", "Germany"),
#'   stringsAsFactors = FALSE
#' )
#' reviewMap(df)
#'
#' @export
reviewMap <- function(data, country_col = Country, sep = "\r\n",
                      fill = "#7BB0D1", base_size = 12, na.rm = TRUE) {
  rlang::check_installed("maps", reason = "to draw world maps with reviewMap()")

  country_sym <- rlang::ensym(country_col)
  country_name <- rlang::as_name(country_sym)

  validate_inputs(data, country_name)

  expanded <- split_col(data, country_name, sep) |>
    handle_na(country_name, na.rm = na.rm, na_label = "Unknown")
  expanded$region <- normalise_countries(expanded[[country_name]])

  counts <- expanded |>
    dplyr::group_by(.data$region) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")

  world <- ggplot2::map_data("world")
  map_joined <- dplyr::left_join(world, counts, by = "region")

  border_lw <- base_size / 120

  ggplot2::ggplot(map_joined, ggplot2::aes(
    x = .data$long, y = .data$lat, group = .data$group, fill = .data$n
  )) +
    ggplot2::geom_polygon(color = "grey80", linewidth = border_lw) +
    ggplot2::scale_fill_gradient(
      low = lighten_color(fill, 0.8),
      high = fill, na.value = "#f5f5f5",
      breaks = function(x) seq(floor(min(x, na.rm = TRUE)),
                                ceiling(max(x, na.rm = TRUE)))
    ) +
    ggplot2::coord_fixed(1.3) +
    theme_litreview(base_size = base_size) +
    ggplot2::theme(
      axis.text  = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::labs(fill = "Studies")
}
