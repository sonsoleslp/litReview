#' Create a Hierarchical Tree Diagram
#'
#' Draws a left-to-right node-link tree from a set of columns given **in order**.
#' The first column forms the top-level branches, the next column their children,
#' and so on; multi-value cells are split so a study can sit in several branches.
#' Each level-1 branch gets its own colour, inherited by its descendants, and the
#' leaves can attach a wrapped list of the studies that reach them. Returns a
#' standard [ggplot2::ggplot] object.
#'
#' @param data A data frame with one row per study.
#' @param cols Character vector of columns defining the hierarchy, from root
#'   (first) to leaf (last). Each level branches by that column's values.
#' @param study_id Column with the study labels collected at the leaves (quoted
#'   or unquoted). Defaults to `StudyID`.
#' @param sep Character. Separator for multi-value cells. Defaults to `"\r\n"`.
#' @param show_members Logical. Attach a box listing the contributing studies at
#'   each leaf. Defaults to `TRUE`.
#' @param member_wrap Integer. Wrap the member list at this many characters.
#'   Defaults to `36`.
#' @param label_wrap Integer. Wrap node labels at this many characters.
#'   Defaults to `18`.
#' @param counts Character. Annotate each node with the number and/or percentage
#'   of studies it covers: `"none"` (default), `"count"`, `"percent"`, or
#'   `"both"`. Counts are distinct studies; percentages are relative to all
#'   studies, so sibling branches may sum past 100% when cells are multi-valued.
#' @param root_label Character. Text for the root node. Defaults to
#'   `"All studies"`.
#' @param colors Character vector of branch colours (one per level-1 value).
#'   Defaults to [PALETTE].
#' @param root_fill Character. Fill for the root node. Defaults to `"#F4F4C8"`.
#' @param base_size Numeric. Base font size in points. Defaults to `11`.
#' @param na.rm Logical. Drop missing values? Defaults to `TRUE`.
#' @param na_label Character. Label for missing values when `na.rm = FALSE`.
#'   Defaults to `"Not reported"`.
#' @param na_last Logical. If `TRUE` (and `na.rm = FALSE`), order the missing
#'   branch last (at the bottom) at every level. Defaults to `FALSE`.
#'

#' @return A [ggplot2::ggplot] object.
#'
#' @examples
#' data(studies)
#' reviewTree(studies, c("InterventionType", "Intervention"), study_id = Author)
#'
#' @importFrom ggplot2 ggplot aes geom_segment geom_label scale_fill_identity
#'   scale_x_continuous expansion coord_cartesian theme_void theme element_rect
#'   margin labs
#' @export
reviewTree <- function(data, cols, study_id = StudyID, sep = "\r\n",
                       show_members = TRUE, member_wrap = 36, label_wrap = 18,
                       counts = c("none", "count", "percent", "both"),
                       root_label = "All studies", colors = PALETTE,
                       root_fill = "#F4F4C8", base_size = 11,
                       na.rm = TRUE, na_label = "Not reported",
                       na_last = FALSE) {
  id_sym  <- rlang::ensym(study_id)
  id_name <- rlang::as_name(id_sym)
  counts  <- match.arg(counts)

  if (!is.character(cols) || length(cols) < 1L)
    cli::cli_abort("{.arg cols} must be a character vector of column names.")
  validate_inputs(data, id_name)
  miss <- setdiff(cols, names(data))
  if (length(miss))
    cli::cli_abort(c("Column{?s} {.val {miss}} not found in {.arg data}.",
                     "i" = "Available columns: {.val {names(data)}}."))

  # -- Expand multi-value cells level by level ---------------------------------
  ex <- data[unique(c(id_name, cols))]
  for (cn in cols) {
    ex <- split_col(ex, cn, sep)
    ex <- handle_na(ex, cn, na.rm = na.rm, na_label = na_label)
  }
  for (cn in cols) {
    lv <- unique(as.character(ex[[cn]]))
    lv <- levels_na_last(lv, na_label, !na.rm && isTRUE(na_last))
    ex[[cn]] <- factor(ex[[cn]], levels = lv)
  }

  # Distinct studies overall, and a per-node count -> label annotation
  total_n <- dplyr::n_distinct(as.character(ex[[id_name]]))
  annot <- function(n) {
    if (counts == "none") return("")
    pct <- if (total_n > 0) round(n / total_n * 100) else 0
    switch(counts,
      count   = sprintf(" (%d)", n),
      percent = sprintf(" (%d%%)", pct),
      both    = sprintf(" (%d, %d%%)", n, pct))
  }

  key_of <- function(df, kc) do.call(paste, c(df[kc], sep = ""))

  # -- Leaf paths, ordered for a non-crossing layout ---------------------------
  paths <- dplyr::arrange(
    dplyr::distinct(ex, dplyr::across(dplyr::all_of(cols))),
    dplyr::across(dplyr::all_of(cols)))
  paths <- as.data.frame(paths, stringsAsFactors = FALSE)
  paths$leaf_y <- rev(seq_len(nrow(paths)))

  members <- ex |>
    dplyr::group_by(dplyr::across(dplyr::all_of(cols))) |>
    dplyr::summarise(.members = paste(sort(unique(as.character(!!id_sym))),
                                      collapse = ", "), .groups = "drop")
  paths <- dplyr::left_join(paths, as.data.frame(members), by = cols)

  wrap_node <- wrap_labels(label_wrap)
  wrap_mem  <- wrap_labels(member_wrap)

  # -- Nodes: one per unique prefix at each level ------------------------------
  node_df <- do.call(rbind, lapply(seq_along(cols), function(k) {
    kc  <- cols[1:k]
    agg <- paths |>
      dplyr::group_by(dplyr::across(dplyr::all_of(kc))) |>
      dplyr::summarise(y = mean(.data$leaf_y), .groups = "drop")
    agg <- as.data.frame(agg, stringsAsFactors = FALSE)
    cnt <- ex |>
      dplyr::group_by(dplyr::across(dplyr::all_of(kc))) |>
      dplyr::summarise(.n = dplyr::n_distinct(as.character(!!id_sym)),
                       .groups = "drop")
    agg <- dplyr::left_join(agg, as.data.frame(cnt), by = kc)
    data.frame(
      key        = key_of(agg, kc),
      parent_key = if (k == 1) "ROOT" else key_of(agg, cols[1:(k - 1)]),
      label      = wrap_node(paste0(as.character(agg[[cols[k]]]),
                                    vapply(agg$.n, annot, character(1)))),
      level      = k,
      y          = agg$y,
      level1     = as.character(agg[[cols[1]]]),
      stringsAsFactors = FALSE)
  }))

  root <- data.frame(key = "ROOT", parent_key = NA_character_,
                     label = root_label, level = 0,
                     y = mean(paths$leaf_y),
                     level1 = NA_character_, stringsAsFactors = FALSE)
  nodes <- rbind(root, node_df)
  nodes$x <- nodes$level

  # Branch colours from the level-1 ancestor
  lvl1 <- levels(ex[[cols[1]]])
  pal  <- stats::setNames(recycle_colors(colors, length(lvl1)), lvl1)
  nodes$fill <- ifelse(is.na(nodes$level1), root_fill, pal[nodes$level1])

  lookup_x <- stats::setNames(nodes$x, nodes$key)
  lookup_y <- stats::setNames(nodes$y, nodes$key)

  # -- Edges (right-angle elbows: out, across, in) -----------------------------
  edge_nodes <- nodes[nodes$level >= 1, ]
  edges <- data.frame(
    x  = edge_nodes$x, y  = edge_nodes$y,
    px = lookup_x[edge_nodes$parent_key], py = lookup_y[edge_nodes$parent_key])

  # -- Member boxes as leaf-level annotations ----------------------------------
  max_x <- length(cols)
  if (isTRUE(show_members)) {
    leaf_key <- key_of(paths, cols)
    mem <- data.frame(
      x = max_x + 1, y = paths$leaf_y,
      label = wrap_mem(paste0("(", paths$.members, ")")),
      px = lookup_x[leaf_key], py = lookup_y[leaf_key],
      stringsAsFactors = FALSE)
    edges <- rbind(edges, mem[c("x", "y", "px", "py")])
    max_x <- max_x + 1
  }

  seg <- with(edges, {
    mid <- (px + x) / 2
    rbind(
      data.frame(x = px,  y = py, xend = mid, yend = py),   # out of parent
      data.frame(x = mid, y = py, xend = mid, yend = y),    # across
      data.frame(x = mid, y = y,  xend = x,   yend = y))    # into child
  })

  node_size <- base_size / ggplot2::.pt
  mem_size  <- base_size * 0.72 / ggplot2::.pt

  p <- ggplot2::ggplot() +
    ggplot2::geom_segment(data = seg,
      ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend),
      color = "grey65", linewidth = base_size / 30) +
    ggplot2::geom_label(data = nodes,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$label,
                   fill = .data$fill),
      size = node_size, color = "black", label.r = grid::unit(base_size * 0.5, "pt"),
      label.padding = grid::unit(base_size * 0.35, "pt"), lineheight = 0.9)

  if (isTRUE(show_members)) {
    p <- p +
      ggplot2::geom_label(data = mem,
        ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
        hjust = 0, size = mem_size, color = "black", fill = "white",
        label.r = grid::unit(base_size * 0.3, "pt"),
        label.padding = grid::unit(base_size * 0.3, "pt"), lineheight = 0.9)
  }

  p +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(
      expand = ggplot2::expansion(add = c(0.6, if (show_members) 4 else 0.6))) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme_void(base_size = base_size) +
    ggplot2::theme(
      legend.position = "none",
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.margin     = ggplot2::margin(base_size, base_size, base_size, base_size)) +
    ggplot2::labs(x = NULL, y = NULL)
}
