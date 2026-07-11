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

#' Names of the ColorBrewer palettes (from RColorBrewer)
#' @noRd
BREWER_PALETTES <- c(
  # Sequential
  "BuGn", "BuPu", "GnBu", "Greens", "Greys", "Oranges", "OrRd", "PuBu",
  "PuBuGn", "PuRd", "Purples", "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr",
  "YlOrRd", "Blues",
  # Diverging
  "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral",
  # Qualitative
  "Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3"
)

#' Is `x` the name of a single ColorBrewer palette?
#' @param x Anything.
#' @return Logical scalar.
#' @noRd
is_brewer_palette <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) &&
    !startsWith(x, "#") && x %in% BREWER_PALETTES
}

#' Resolve a colour spec, expanding a ColorBrewer palette name
#'
#' If `colors` is a single string naming a ColorBrewer palette (e.g. `"Set2"`),
#' expand it to `n` colours via \pkg{RColorBrewer}; otherwise return it
#' unchanged. Any character vector of hex/colour names passes straight through.
#' @param colors Character vector of colours, or a single ColorBrewer name.
#' @param n Integer or NULL. Number of colours needed.
#' @return Character vector of colours.
#' @noRd
resolve_palette <- function(colors, n = NULL) {
  if (!is_brewer_palette(colors)) return(colors)
  rlang::check_installed("RColorBrewer",
                         reason = paste0("to use the '", colors, "' palette"))
  maxn <- RColorBrewer::brewer.pal.info[colors, "maxcolors"]
  k    <- if (is.null(n)) maxn else max(3L, min(as.integer(n), maxn))
  pal  <- RColorBrewer::brewer.pal(k, colors)
  if (!is.null(n) && n > length(pal)) pal <- rep_len(pal, n)
  pal
}

#' Build a continuous fill scale, honouring a ColorBrewer palette name
#'
#' If `fill` names a ColorBrewer palette, use [ggplot2::scale_fill_distiller()];
#' otherwise a two-point gradient from `low` to `fill`. Extra arguments in `...`
#' (e.g. `na.value`, `breaks`) are forwarded to whichever scale is used. `low`
#' is only evaluated for the gradient path, so callers may pass an expression
#' that assumes `fill` is a real colour.
#' @param fill Character. High-end colour or a ColorBrewer palette name.
#' @param low Character. Low-end colour for the gradient path.
#' @return A ggplot2 fill scale.
#' @noRd
fill_gradient_scale <- function(fill, low = "#f0f0f0", ...) {
  if (is_brewer_palette(fill)) {
    rlang::check_installed("RColorBrewer",
                           reason = paste0("to use the '", fill, "' palette"))
    ggplot2::scale_fill_distiller(palette = fill, direction = 1, ...)
  } else {
    ggplot2::scale_fill_gradient(low = low, high = fill, ...)
  }
}

#' Move the NA label to the end of a set of factor levels
#'
#' Shared by the ordered categorical plots to honour `na_last`: the
#' missing-value category is pushed after all real categories.
#' @param lv Character vector of levels (in their intended order).
#' @param na_label Character. The missing-value label.
#' @param do Logical. If `FALSE`, return `lv` unchanged.
#' @return Character vector of levels with `na_label` moved last.
#' @noRd
levels_na_last <- function(lv, na_label, do) {
  if (!do || !na_label %in% lv) return(lv)
  c(setdiff(lv, na_label), na_label)
}

#' Recycle a color vector to the required length
#'
#' A single ColorBrewer palette name is expanded first (see [resolve_palette()]).
#' Named vectors are returned as-is (ggplot2 matches by name).
#' Unnamed vectors shorter than `n` are recycled with `rep_len`.
#' @param colors Character vector of colors, or a ColorBrewer palette name.
#' @param n Integer. Number of categories.
#' @return Character vector of length >= `n`.
#' @noRd
recycle_colors <- function(colors, n) {
  colors <- resolve_palette(colors, n)
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

#' Build a discrete-scale labeller that wraps long labels
#'
#' Returns a function suitable for the `labels` argument of
#' [ggplot2::scale_x_discrete()] / [ggplot2::scale_y_discrete()]. Each label is
#' wrapped onto multiple lines at word boundaries once it exceeds `width`
#' characters. A `NULL`, non-finite, or non-positive `width` disables wrapping.
#'
#' @param width Integer. Maximum characters per line.
#' @return A vectorized function mapping a character vector to wrapped labels.
#' @noRd
wrap_labels <- function(width = 15) {
  if (is.null(width) || !is.finite(width) || width <= 0) return(identity)
  function(x) vapply(
    as.character(x),
    function(s) paste(strwrap(s, width = width), collapse = "\n"),
    character(1), USE.NAMES = FALSE
  )
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
  available <- names(data)
  if (!col_name %in% available) {
    cli::cli_abort(c(
      "Column {.val {col_name}} not found in {.arg data}.",
      "i" = "Available columns: {.val {available}}."
    ))
  }
  if (!is.null(id_name) && !id_name %in% available) {
    cli::cli_abort(c(
      "Study ID column {.val {id_name}} not found in {.arg data}.",
      "i" = "Available columns: {.val {available}}.",
      "i" = "Set {.arg study_id} to the correct column."
    ))
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

#' Convert a Google Sheets or Drive URL to an xlsx export URL
#'
#' Handles:
#' - `https://docs.google.com/spreadsheets/d/ID/edit...`
#' - `https://docs.google.com/spreadsheets/d/ID/...` (any path)
#' - `https://drive.google.com/file/d/ID/view...`
#' - `https://drive.google.com/open?id=ID`
#' - `https://drive.google.com/uc?export=download&id=ID` (already correct)
#'
#' Non-Google URLs are returned unchanged.
#'
#' @param url Character. A URL string.
#' @return Character. The export URL, or the original URL if not recognized.
#' @noRd
normalise_google_url <- function(url) {
  # Google Sheets: docs.google.com/spreadsheets/d/ID/...
  m <- regmatches(url, regexec(
    "docs\\.google\\.com/spreadsheets/d/([^/]+)", url))[[1]]
  if (length(m) == 2) {
    return(paste0("https://docs.google.com/spreadsheets/d/", m[2],
                  "/export?format=xlsx"))
  }
  # Google Drive file: drive.google.com/file/d/ID/...

  m <- regmatches(url, regexec(
    "drive\\.google\\.com/file/d/([^/]+)", url))[[1]]
  if (length(m) == 2) {
    return(paste0("https://drive.google.com/uc?export=download&id=", m[2]))
  }
  # Google Drive open: drive.google.com/open?id=ID
  m <- regmatches(url, regexec(
    "drive\\.google\\.com/open\\?id=([^&]+)", url))[[1]]
  if (length(m) == 2) {
    return(paste0("https://drive.google.com/uc?export=download&id=", m[2]))
  }
  url
}

#' ISO 2-/3-letter code -> map_data("world") region lookup
#'
#' Built from [maps::iso3166]; only codes whose (cleaned) map name is an actual
#' `map_data("world")` region are kept.
#' @param world_regions Character vector of valid region names.
#' @return A list with named character vectors `a3` and `a2`.
#' @noRd
iso_region_lookup <- function(world_regions) {
  iso   <- maps::iso3166
  clean <- trimws(sub("\\(.*$", "", iso$mapname))   # strip maps' regex artifacts
  keep  <- clean %in% world_regions
  iso   <- iso[keep, , drop = FALSE]
  clean <- clean[keep]
  list(
    a3 = stats::setNames(clean[!duplicated(iso$a3)], iso$a3[!duplicated(iso$a3)]),
    a2 = stats::setNames(clean[!duplicated(iso$a2)], iso$a2[!duplicated(iso$a2)])
  )
}

#' Normalise country names / codes to map_data("world") region names
#'
#' Resolves common full-name aliases and, when `world_regions` is supplied,
#' ISO 2- and 3-letter country codes (e.g. `"US"`/`"USA"` -> `"USA"`,
#' `"GBR"` -> `"UK"`). Values already equal to a region are left untouched.
#' @param x Character vector of country names or codes.
#' @param world_regions Optional character vector of valid region names; enables
#'   ISO-code resolution (requires the \pkg{maps} package).
#' @return Character vector with names/codes resolved to region names.
#' @noRd
normalise_countries <- function(x, world_regions = NULL) {
  idx <- match(x, names(COUNTRY_ALIASES))
  replaced <- !is.na(idx)
  x[replaced] <- COUNTRY_ALIASES[idx[replaced]]

  if (!is.null(world_regions) && requireNamespace("maps", quietly = TRUE)) {
    lk <- iso_region_lookup(world_regions)
    up <- toupper(trimws(x))
    need <- !(x %in% world_regions)                 # don't override real regions
    h3 <- need & nchar(up) == 3L & up %in% names(lk$a3)
    x[h3] <- lk$a3[up[h3]]
    up <- toupper(trimws(x)); need <- !(x %in% world_regions)
    h2 <- need & nchar(up) == 2L & up %in% names(lk$a2)
    x[h2] <- lk$a2[up[h2]]
  }
  x
}
