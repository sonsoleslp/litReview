library(shiny)
library(bslib)
library(litReview)

# -- Optional dependency flags ------------------------------------------------
has_ggalluvial <- requireNamespace("ggalluvial", quietly = TRUE)
has_treemapify <- requireNamespace("treemapify", quietly = TRUE)
has_maps       <- requireNamespace("maps",       quietly = TRUE)
has_ggfittext  <- requireNamespace("ggfittext",  quietly = TRUE)
has_ggupset    <- requireNamespace("ggupset",    quietly = TRUE)
has_rio        <- requireNamespace("rio",         quietly = TRUE)

plot_choices <- c("Bar", "Stacked", "Histogram", "Waffle", "Pie/Donut",
                  "Overlap", "Trend", "Matrix", "Tree", "Table")
if (has_maps)       plot_choices <- c(plot_choices, "Map")
if (has_ggalluvial) plot_choices <- c(plot_choices, "Alluvial")
if (has_treemapify) plot_choices <- c(plot_choices, "Treemap")
if (has_ggupset)    plot_choices <- c(plot_choices, "UpSet")

app_theme <- bs_theme(
  bootswatch = "minty", primary = "#7ea9c7", secondary = "#76b7b2",
  success = "#59a14f", info = "#b07aa1", warning = "#edc948", danger = "#f16769"
)

palette_choices <- stats::setNames(PALETTE, PALETTE)

# selectizeInput with a real colored swatch beside each choice.
# Values starting with "#" are treated as the swatch color; other values
# (e.g. "custom") get a neutral gray swatch.
palette_selectize <- function(inputId, label, choices, selected = NULL) {
  render_js <- "{
    option: function(item, escape) {
      var v = item.value || '';
      var c = (v.charAt(0) === '#') ? v : '#eee';
      return '<div style=\"display:flex;align-items:center;gap:8px;padding:4px 10px;\">'
        + '<span style=\"display:inline-block;width:14px;height:14px;flex:none;'
        + 'background:' + escape(c) + ';border:1px solid #ccc;\"></span>'
        + '<span>' + escape(item.label) + '</span></div>';
    },
    item: function(item, escape) {
      var v = item.value || '';
      var c = (v.charAt(0) === '#') ? v : '#eee';
      return '<div style=\"display:flex;align-items:center;gap:8px;padding-left:2px;\">'
        + '<span style=\"display:inline-block;width:14px;height:14px;flex:none;'
        + 'background:' + escape(c) + ';border:1px solid #ccc;\"></span>'
        + '<span>' + escape(item.label) + '</span></div>';
    }
  }"
  selectizeInput(inputId, label, choices = choices, selected = selected,
                 options = list(render = I(render_js)))
}

# Restored params arrive JSON-decoded, where multi-column fields come back as
# lists (Shiny decodes nested input values without simplifying). Coerce them
# back to plain character vectors so the plot functions accept them.
normalize_params <- function(p) {
  for (f in c("cols", "matrix_cols", "tree_cols"))
    if (!is.null(p[[f]])) p[[f]] <- as.character(unlist(p[[f]]))
  p
}

# -- Build a plot from an explicit params list (no input$ dependency) ----------
build_plot_from_params <- function(df, p) {
  p   <- normalize_params(p)
  typ <- p$plot_type
  bs  <- p$base_size %||% 12
  sep <- p$sep %||% "\r\n"
  sid <- rlang::sym(p$study_id %||% "StudyID")
  na_rm  <- p$na_rm %||% TRUE
  na_lab <- if (!na_rm) (p$na_label %||% "Not reported") else "Not reported"
  na_pct <- if (!na_rm) (p$na_in_percent %||% TRUE) else TRUE
  na_lst <- if (!na_rm) (p$na_last %||% FALSE) else FALSE
  pal <- if (!is.null(p$palette) && nzchar(p$palette)) p$palette else PALETTE

  switch(typ,
    "Bar" = {
      fill <- if (identical(p$fill_bar, "custom")) p$fill_bar_custom else (p$fill_bar %||% "#7BB0D1")
      sl <- if (has_ggfittext) isTRUE(p$studlabs_bar) else FALSE
      rlang::inject(reviewBar(df, !!rlang::sym(p$col), fill = fill,
        width = p$bar_width %||% 0.6, sep = sep, studlabs = sl, study_id = !!sid,
        label_space = p$label_space %||% 1.6, base_size = bs, na.rm = na_rm,
        na_label = na_lab, na_in_percent = na_pct, na_last = na_lst))
    },
    "Histogram" = {
      fb <- if (!is.null(p$fill_by_hist) && nzchar(p$fill_by_hist)) rlang::sym(p$fill_by_hist) else NULL
      fill <- p$fill_hist %||% "#7BB0D1"
      bw <- if (!is.null(p$binwidth_hist) && p$binwidth_hist > 0) p$binwidth_hist else NULL
      rlang::inject(reviewHistogram(df, !!rlang::sym(p$col), fill_by = !!fb,
        bins = p$bins_hist %||% 30, binwidth = bw, fill = fill, sep = sep,
        base_size = bs, na.rm = na_rm, na_label = na_lab))
    },
    "Waffle" = rlang::inject(
      reviewWaffle(df, !!rlang::sym(p$col), sep = sep, colors = pal,
        ncol = p$ncol_waffle %||% 5, study_id = !!sid, base_size = bs,
        na.rm = na_rm, na_label = na_lab, na_in_percent = na_pct, na_last = na_lst)),
    "Pie/Donut" = rlang::inject(
      reviewPie(df, !!rlang::sym(p$col), sep = sep, colors = pal,
        donut = p$donut %||% TRUE, study_id = !!sid, base_size = bs,
        na.rm = na_rm, na_label = na_lab, na_in_percent = na_pct, na_last = na_lst)),
    "Overlap" = rlang::inject(
      reviewOverlap(df, !!rlang::sym(p$col1), !!rlang::sym(p$col2),
        sep = sep, fill = p$fill_overlap %||% PALETTE[7], base_size = bs,
        na.rm = na_rm, na_label = na_lab,
        studlabs = p$studlabs_overlap %||% FALSE, study_id = !!sid)),
    "Trend" = rlang::inject(
      reviewTrend(df, !!rlang::sym(p$col),
        year_col = !!rlang::sym(p$year_col %||% "Year"), sep = sep, base_size = bs,
        colors = pal, na.rm = na_rm, na_label = na_lab, na_last = na_lst,
        labels = p$trend_labels %||% "none", study_id = !!sid)),
    "Map" = rlang::inject(
      reviewMap(df, country_col = !!rlang::sym(p$country_col %||% "Country"),
        sep = sep, fill = p$fill_map %||% PALETTE[7], base_size = bs, na.rm = na_rm)),
    "Alluvial" = rlang::inject(
      reviewAlluvial(df, p$cols, sep = sep, study_id = !!sid, base_size = bs,
        colors = pal, na.rm = na_rm, na_label = na_lab,
        labels = p$alluv_labels %||% "none",
        flow_labels = p$flow_labels %||% FALSE, flow_alpha = p$flow_alpha %||% 0.25,
        stratum_width = p$stratum_width %||% 0.5)),
    "Treemap" = {
      cb <- if (!is.null(p$color_by) && nzchar(p$color_by)) rlang::sym(p$color_by) else NULL
      rlang::inject(reviewTreemap(df, !!rlang::sym(p$col),
        color_by = !!cb, sep = sep, base_size = bs, colors = pal,
        na.rm = na_rm, na_label = na_lab, study_id = !!sid,
        studlabs = p$studlabs_treemap %||% FALSE))
    },
    "Table" = rlang::inject(
      reviewTable(df, !!rlang::sym(p$col), sep = sep, study_id = !!sid,
        na.rm = na_rm, na_label = na_lab, na_in_percent = na_pct, na_last = na_lst)),
    "Stacked" = rlang::inject(
      reviewStackedBar(df, !!rlang::sym(p$col), !!rlang::sym(p$group),
        position = p$stacked_position %||% "fill", sep = sep, study_id = !!sid,
        fill = pal, base_size = bs, na.rm = na_rm, na_label = na_lab,
        na_last = na_lst, labels = p$stacked_labels %||% TRUE)),
    "UpSet" = rlang::inject(
      reviewUpset(df, !!rlang::sym(p$col), sep = sep, study_id = !!sid,
        base_size = bs, na.rm = na_rm, na_label = na_lab,
        n_intersections = p$upset_n %||% 15, sort_by = p$upset_sort %||% "freq",
        fill = p$fill_upset %||% "#7BB0D1")),
    "Matrix" = rlang::inject(
      reviewMatrix(df, p$matrix_cols,
        color_by = if (!is.null(p$matrix_color) && nzchar(p$matrix_color)) p$matrix_color else NULL,
        study_id = !!sid, show_counts = p$matrix_counts %||% TRUE, colors = pal,
        base_size = bs, na.rm = na_rm, na_label = na_lab)),
    "Tree" = rlang::inject(
      reviewTree(df, p$tree_cols, study_id = !!sid, sep = sep, colors = pal,
        show_members = p$tree_members %||% TRUE, counts = p$tree_counts %||% "none",
        root_label = p$tree_root %||% "All studies", base_size = bs,
        na.rm = na_rm, na_label = na_lab, na_last = na_lst))
  )
}

# -- localStorage JS ----------------------------------------------------------
local_storage_js <- "
var litR = {
  setPT: function(btn, val) {
    $('#plot_type_btns .btn').removeClass('active');
    $(btn).addClass('active');
    $('#plot_type').val(val).trigger('change');
  }
};
$(document).on('shiny:connected', function() {
  var state = localStorage.getItem('litReview_state');
  if (state) {
    Shiny.setInputValue('_restore_state', JSON.parse(state), {priority: 'event'});
  } else {
    Shiny.setInputValue('_restore_state', null, {priority: 'event'});
  }
});
Shiny.addCustomMessageHandler('save_state', function(state) {
  localStorage.setItem('litReview_state', JSON.stringify(state));
});
Shiny.addCustomMessageHandler('set_plot_type', function(val) {
  $('#plot_type_btns .btn').removeClass('active');
  $('#plot_type_btns .btn[title=\"' + val + '\"]').addClass('active');
  $('#plot_type').val(val).trigger('change');
});
Shiny.addCustomMessageHandler('clear_state', function(msg) {
  localStorage.removeItem('litReview_state');
});
// Click anywhere on a plot card to enter edit mode (except on buttons/inputs).
$(document).on('click', 'div.card[id^=\"card_\"]', function(e) {
  var $t = $(e.target);
  if ($t.closest('button, a, input, select, textarea, label').length) return;
  if ($(this).hasClass('litr-editing')) return;
  var id = this.id.substring(5);
  Shiny.setInputValue('edit_' + id, +new Date(), {priority: 'event'});
});
"

# =============================================================================
# UI
# =============================================================================
ui <- page_sidebar(
  title = "litReview", theme = app_theme, window_title = "litReview",
  fillable = FALSE,
  tags$head(
    tags$script(HTML(local_storage_js)),
    tags$style(HTML(
      "div.shiny-plot-output { height: auto !important; }
       #plot_type_btns { display: grid !important; grid-template-columns: repeat(3, 1fr); gap: 4px; }
       #plot_type_btns .btn { min-width: 0; padding: 8px 4px; font-size: 1.2em; }
       #plot_type_btns .btn:hover { background-color: #fff7ca; color: inherit; }
       #plot_type_btns .btn.active,
       #plot_type_btns .btn.active:hover { background-color: var(--bs-primary); border-color: var(--bs-primary); color: #fff; }
       div.card[id^='card_'] { cursor: pointer; transition: box-shadow 0.15s, border-color 0.15s; }
       div.card[id^='card_']:hover:not(.litr-editing) { box-shadow: 0 0 0 2px var(--bs-primary); }
       div.card[id^='card_'] button, div.card[id^='card_'] a,
       div.card[id^='card_'] input, div.card[id^='card_'] select,
       div.card[id^='card_'] label { cursor: auto; }"
    ))
  ),

  sidebar = sidebar(
    width = 340,
    accordion(
      id = "sidebar_acc", open = c("data_input", "plot_config"),

      # -- Data Input -----------------------------------------------------------
      accordion_panel("Data Input", value = "data_input", icon = icon("upload"),
        fileInput("file_upload", "Upload file (.xlsx, .csv)",
                  accept = c(".xlsx", ".xls", ".csv", ".tsv")),
        tags$hr(),
        tags$p("Or load from URL:", class = "text-muted small"),
        textInput("url_input", NULL, placeholder = "https://..."),
        actionButton("load_url", "Load URL",
                     class = "btn-sm btn-outline-primary", icon = icon("globe")),
        tags$hr(),
        numericInput("sheet_input",
                     "Sheet (Excel / Google Sheets)",
                     value = 1, min = 1, step = 1),
        tags$hr(),
        actionLink("use_example", "Use example dataset", icon = icon("table"))
      ),

      # -- Plot Configuration ---------------------------------------------------
      accordion_panel("Plot Configuration", value = "plot_config",
        icon = icon("chart-bar"),

        tags$label("Plot type", class = "form-label"),
        {
          # Mini SVG icons simulating each plot type
          s <- function(...) HTML(paste0(
            '<svg viewBox="0 0 32 32" width="28" height="28" style="display:block;margin:auto;">',
            ..., '</svg>'))
          pt_btn <- function(id, title, svg) {
            cls <- if (title == "Bar") "btn-outline-primary btn-sm active" else "btn-outline-primary btn-sm"
            actionButton(id, tags$div(svg, tags$div(title, style="font-size:0.6em;margin-top:2px;")),
                         class = cls, title = title,
                         onclick = sprintf("litR.setPT(this,'%s')", title))
          }
          pal <- PALETTE
          tags$div(class = "mb-3", id = "plot_type_btns",
            # Bar: horizontal bars
            pt_btn("pt_Bar", "Bar", s(
              sprintf('<rect x="2" y="3" width="20" height="5" rx="1" fill="%s"/>', pal[1]),
              sprintf('<rect x="2" y="11" width="14" height="5" rx="1" fill="%s"/>', pal[2]),
              sprintf('<rect x="2" y="19" width="26" height="5" rx="1" fill="%s"/>', pal[3]),
              '<text x="24" y="7.5" font-size="4" fill="#333">3</text>',
              '<text x="18" y="15.5" font-size="4" fill="#333">2</text>',
              '<text x="30" y="23.5" font-size="4" fill="#333">5</text>')),
            # Stacked: horizontal bars split into colored segments
            pt_btn("pt_Stacked", "Stacked", s(
              sprintf('<rect x="2" y="4" width="13" height="5" fill="%s"/>', pal[1]),
              sprintf('<rect x="15" y="4" width="8" height="5" fill="%s"/>', pal[2]),
              sprintf('<rect x="23" y="4" width="6" height="5" fill="%s"/>', pal[3]),
              sprintf('<rect x="2" y="12" width="8" height="5" fill="%s"/>', pal[1]),
              sprintf('<rect x="10" y="12" width="11" height="5" fill="%s"/>', pal[2]),
              sprintf('<rect x="21" y="12" width="8" height="5" fill="%s"/>', pal[3]),
              sprintf('<rect x="2" y="20" width="17" height="5" fill="%s"/>', pal[1]),
              sprintf('<rect x="19" y="20" width="6" height="5" fill="%s"/>', pal[2]),
              sprintf('<rect x="25" y="20" width="4" height="5" fill="%s"/>', pal[3]))),
            # Histogram: adjacent vertical bars (no gaps)
            pt_btn("pt_Histogram", "Histogram", s(
              sprintf('<rect x="2"  y="20" width="4" height="6"  fill="%s"/>', pal[1]),
              sprintf('<rect x="6"  y="14" width="4" height="12" fill="%s"/>', pal[1]),
              sprintf('<rect x="10" y="6"  width="4" height="20" fill="%s"/>', pal[1]),
              sprintf('<rect x="14" y="10" width="4" height="16" fill="%s"/>', pal[1]),
              sprintf('<rect x="18" y="16" width="4" height="10" fill="%s"/>', pal[1]),
              sprintf('<rect x="22" y="22" width="4" height="4"  fill="%s"/>', pal[1]),
              '<line x1="1" y1="27" x2="30" y2="27" stroke="#999" stroke-width="0.5"/>')),
            # Waffle: grid of colored squares
            pt_btn("pt_Waffle", "Waffle", s(
              sprintf('<rect x="2" y="2" width="6" height="6" rx="1" fill="%s"/>', pal[1]),
              sprintf('<rect x="10" y="2" width="6" height="6" rx="1" fill="%s"/>', pal[1]),
              sprintf('<rect x="18" y="2" width="6" height="6" rx="1" fill="%s"/>', pal[2]),
              sprintf('<rect x="2" y="10" width="6" height="6" rx="1" fill="%s"/>', pal[2]),
              sprintf('<rect x="10" y="10" width="6" height="6" rx="1" fill="%s"/>', pal[3]),
              sprintf('<rect x="18" y="10" width="6" height="6" rx="1" fill="%s"/>', pal[3]),
              sprintf('<rect x="2" y="18" width="6" height="6" rx="1" fill="%s"/>', pal[3]),
              sprintf('<rect x="10" y="18" width="6" height="6" rx="1" fill="%s"/>', pal[4]),
              sprintf('<rect x="18" y="18" width="6" height="6" rx="1" fill="%s"/>', pal[4]))),
            # Pie/Donut: donut with segments
            pt_btn("pt_Pie", "Pie/Donut", s(
              sprintf('<circle cx="16" cy="14" r="12" fill="%s"/>', pal[1]),
              sprintf('<path d="M16,14 L16,2 A12,12 0 0,1 26.4,20Z" fill="%s"/>', pal[2]),
              sprintf('<path d="M16,14 L26.4,20 A12,12 0 0,1 16,26Z" fill="%s"/>', pal[3]),
              '<circle cx="16" cy="14" r="5" fill="white"/>')),
            # Overlap: heatmap tiles
            pt_btn("pt_Overlap", "Overlap", s(
              sprintf('<rect x="2" y="2" width="9" height="9" fill="%s" opacity="0.3"/>', pal[4]),
              sprintf('<rect x="12" y="2" width="9" height="9" fill="%s" opacity="0.7"/>', pal[4]),
              sprintf('<rect x="22" y="2" width="9" height="9" fill="%s"/>', pal[4]),
              sprintf('<rect x="2" y="12" width="9" height="9" fill="%s" opacity="0.7"/>', pal[4]),
              sprintf('<rect x="12" y="12" width="9" height="9" fill="%s" opacity="0.3"/>', pal[4]),
              sprintf('<rect x="22" y="12" width="9" height="9" fill="%s" opacity="0.5"/>', pal[4]),
              sprintf('<rect x="2" y="22" width="9" height="9" fill="%s" opacity="0.5"/>', pal[4]),
              sprintf('<rect x="12" y="22" width="9" height="9" fill="%s"/>', pal[4]),
              sprintf('<rect x="22" y="22" width="9" height="9" fill="%s" opacity="0.3"/>', pal[4]))),
            # Trend: stacked bars by year
            pt_btn("pt_Trend", "Trend", s(
              sprintf('<rect x="3" y="16" width="7" height="10" fill="%s"/>', pal[1]),
              sprintf('<rect x="3" y="10" width="7" height="6" fill="%s"/>', pal[2]),
              sprintf('<rect x="12" y="12" width="7" height="14" fill="%s"/>', pal[1]),
              sprintf('<rect x="12" y="4" width="7" height="8" fill="%s"/>', pal[2]),
              sprintf('<rect x="21" y="8" width="7" height="18" fill="%s"/>', pal[1]),
              sprintf('<rect x="21" y="2" width="7" height="6" fill="%s"/>', pal[2]),
              '<line x1="1" y1="27" x2="30" y2="27" stroke="#999" stroke-width="0.5"/>')),
            # Table: rows and columns
            pt_btn("pt_Table", "Table", s(
              '<rect x="2" y="2" width="28" height="5" rx="1" fill="#ddd"/>',
              '<line x1="2" y1="10" x2="30" y2="10" stroke="#ccc" stroke-width="0.5"/>',
              '<line x1="2" y1="15" x2="30" y2="15" stroke="#ccc" stroke-width="0.5"/>',
              '<line x1="2" y1="20" x2="30" y2="20" stroke="#ccc" stroke-width="0.5"/>',
              '<line x1="2" y1="25" x2="30" y2="25" stroke="#ccc" stroke-width="0.5"/>',
              '<line x1="12" y1="2" x2="12" y2="28" stroke="#ccc" stroke-width="0.5"/>',
              '<line x1="22" y1="2" x2="22" y2="28" stroke="#ccc" stroke-width="0.5"/>',
              '<text x="5" y="6" font-size="3.5" fill="#666" font-weight="bold">A</text>',
              '<text x="15" y="6" font-size="3.5" fill="#666" font-weight="bold">B</text>',
              '<text x="25" y="6" font-size="3.5" fill="#666" font-weight="bold">C</text>')),
            # Map: simple world silhouette
            if ("Map" %in% plot_choices)
              pt_btn("pt_Map", "Map", s(
                '<rect x="1" y="1" width="30" height="24" rx="2" fill="#e8f4f8" stroke="#ccc" stroke-width="0.5"/>',
                sprintf('<ellipse cx="10" cy="10" rx="4" ry="5" fill="%s" opacity="0.6"/>', pal[7]),
                sprintf('<ellipse cx="18" cy="8" rx="3" ry="4" fill="%s"/>', pal[7]),
                sprintf('<ellipse cx="24" cy="12" rx="4" ry="5" fill="%s" opacity="0.4"/>', pal[7]),
                sprintf('<ellipse cx="12" cy="18" rx="3" ry="3" fill="%s" opacity="0.7"/>', pal[7]),
                sprintf('<ellipse cx="22" cy="19" rx="2" ry="2" fill="%s" opacity="0.5"/>', pal[7]))),
            # Alluvial: flowing curves between strata
            if ("Alluvial" %in% plot_choices)
              pt_btn("pt_Alluvial", "Alluvial", s(
                sprintf('<rect x="2" y="2" width="5" height="12" rx="1" fill="%s"/>', pal[1]),
                sprintf('<rect x="2" y="16" width="5" height="10" rx="1" fill="%s"/>', pal[2]),
                sprintf('<rect x="25" y="2" width="5" height="8" rx="1" fill="%s"/>', pal[1]),
                sprintf('<rect x="25" y="12" width="5" height="7" rx="1" fill="%s"/>', pal[2]),
                sprintf('<rect x="25" y="21" width="5" height="7" rx="1" fill="%s"/>', pal[3]),
                sprintf('<path d="M7,8 C16,8 16,6 25,6" stroke="%s" fill="none" stroke-width="3" opacity="0.3"/>', pal[1]),
                sprintf('<path d="M7,12 C16,12 16,15 25,15" stroke="%s" fill="none" stroke-width="2" opacity="0.3"/>', pal[1]),
                sprintf('<path d="M7,20 C16,20 16,24 25,24" stroke="%s" fill="none" stroke-width="3" opacity="0.3"/>', pal[2]),
                sprintf('<path d="M7,24 C16,24 16,10 25,10" stroke="%s" fill="none" stroke-width="2" opacity="0.3"/>', pal[2]))),
            # Treemap: nested rectangles
            if ("Treemap" %in% plot_choices)
              pt_btn("pt_Treemap", "Treemap", s(
                sprintf('<rect x="2" y="2" width="16" height="14" rx="1" fill="%s"/>', pal[1]),
                sprintf('<rect x="20" y="2" width="10" height="14" rx="1" fill="%s"/>', pal[2]),
                sprintf('<rect x="2" y="18" width="10" height="10" rx="1" fill="%s"/>', pal[3]),
                sprintf('<rect x="14" y="18" width="16" height="10" rx="1" fill="%s"/>', pal[4]))),
            # UpSet: intersection bars over a dot matrix
            if ("UpSet" %in% plot_choices)
              pt_btn("pt_UpSet", "UpSet", s(
                sprintf('<rect x="3"  y="3"  width="4" height="11" fill="%s"/>', pal[7]),
                sprintf('<rect x="9"  y="6"  width="4" height="8"  fill="%s"/>', pal[7]),
                sprintf('<rect x="15" y="9"  width="4" height="5"  fill="%s"/>', pal[7]),
                sprintf('<rect x="21" y="10" width="4" height="4"  fill="%s"/>', pal[7]),
                '<line x1="5" y1="19" x2="5" y2="25" stroke="#888" stroke-width="1"/>',
                '<line x1="23" y1="19" x2="23" y2="25" stroke="#888" stroke-width="1"/>',
                sprintf('<circle cx="5"  cy="19" r="1.7" fill="%s"/>', pal[7]),
                sprintf('<circle cx="5"  cy="25" r="1.7" fill="%s"/>', pal[7]),
                sprintf('<circle cx="11" cy="19" r="1.7" fill="%s"/>', pal[7]),
                '<circle cx="11" cy="25" r="1.7" fill="#ccc"/>',
                '<circle cx="17" cy="19" r="1.7" fill="#ccc"/>',
                sprintf('<circle cx="17" cy="25" r="1.7" fill="%s"/>', pal[7]),
                sprintf('<circle cx="23" cy="19" r="1.7" fill="%s"/>', pal[7]),
                sprintf('<circle cx="23" cy="25" r="1.7" fill="%s"/>', pal[7]))),
            # Matrix: study x criteria grid of coded tiles
            pt_btn("pt_Matrix", "Matrix", s(
              # background grid (empty cells)
              paste(unlist(lapply(c(2,9,16,23), function(x)
                lapply(c(3,11,19), function(y) sprintf(
                  '<rect x="%d" y="%d" width="6" height="6" fill="#f4f4e2"/>', x, y)))),
                collapse = ""),
              # row 1 (one document type)
              sprintf('<rect x="2" y="3" width="6" height="6" fill="%s"/>', pal[1]),
              sprintf('<rect x="9" y="3" width="6" height="6" fill="%s"/>', pal[1]),
              sprintf('<rect x="23" y="3" width="6" height="6" fill="%s"/>', pal[1]),
              # row 2
              sprintf('<rect x="2" y="11" width="6" height="6" fill="%s"/>', pal[2]),
              sprintf('<rect x="16" y="11" width="6" height="6" fill="%s"/>', pal[2]),
              sprintf('<rect x="23" y="11" width="6" height="6" fill="%s"/>', pal[2]),
              # row 3
              sprintf('<rect x="9" y="19" width="6" height="6" fill="%s"/>', pal[6]),
              sprintf('<rect x="16" y="19" width="6" height="6" fill="%s"/>', pal[6]),
              '<text x="3.2" y="8" font-size="5" fill="#fff" font-weight="bold">F</text>',
              '<text x="24.2" y="8" font-size="5" fill="#fff" font-weight="bold">D</text>',
              '<text x="3.2" y="16" font-size="5" fill="#fff" font-weight="bold">P</text>',
              '<text x="10.2" y="24" font-size="5" fill="#fff" font-weight="bold">M</text>')),
            # Tree: left-to-right hierarchy of nodes
            pt_btn("pt_Tree", "Tree", s(
              '<path d="M8,16 H14 M14,16 V6 M14,16 V26 M14,6 H20 M14,26 H20" stroke="#999" stroke-width="1.2" fill="none"/>',
              sprintf('<rect x="2" y="13" width="6" height="6" rx="1.5" fill="%s"/>', pal[5]),
              sprintf('<rect x="20" y="3" width="9" height="6" rx="1.5" fill="%s"/>', pal[1]),
              sprintf('<rect x="20" y="23" width="9" height="6" rx="1.5" fill="%s"/>', pal[2]),
              sprintf('<rect x="20" y="13" width="9" height="6" rx="1.5" fill="%s"/>', pal[6]),
              '<path d="M14,16 H20" stroke="#999" stroke-width="1.2" fill="none"/>'))
          )
        },
        # Hidden text input to drive conditionalPanel via input.plot_type
        tags$div(style = "display:none;",
          textInput("plot_type", NULL, value = "Bar")),
        selectInput("study_id", "Study ID column", choices = NULL),

        conditionalPanel(
          "!['Overlap','Alluvial','Map','Matrix','Tree'].includes(input.plot_type)",
          selectInput("col", "Column", choices = NULL)),
        conditionalPanel("input.plot_type === 'Overlap'",
          selectInput("col1", "Column 1 (x-axis)", choices = NULL),
          selectInput("col2", "Column 2 (y-axis)", choices = NULL)),
        conditionalPanel("input.plot_type === 'Alluvial'",
          selectizeInput("cols", "Columns (select 2+)",
                         choices = NULL, multiple = TRUE)),
        conditionalPanel("input.plot_type === 'Matrix'",
          selectizeInput("matrix_cols", "Criteria columns (select 1+)",
                         choices = NULL, multiple = TRUE),
          selectInput("matrix_color", "Color by (optional)", choices = NULL),
          checkboxInput("matrix_counts", "Show counts in headers", TRUE)),
        conditionalPanel("input.plot_type === 'Tree'",
          selectizeInput("tree_cols", "Hierarchy columns (root → leaf, in order)",
                         choices = NULL, multiple = TRUE),
          textInput("tree_root", "Root label", value = "All studies"),
          selectInput("tree_counts", "Node counts",
                      choices = c("None" = "none", "Count" = "count",
                                  "Percent" = "percent", "Count + percent" = "both")),
          checkboxInput("tree_members", "Show study lists at leaves", TRUE)),
        conditionalPanel("input.plot_type === 'Map'",
          selectInput("country_col", "Country column", choices = NULL)),
        conditionalPanel("input.plot_type === 'Trend'",
          selectInput("year_col", "Year column", choices = NULL)),

        selectInput("sep", "Multi-value separator",
          choices = c("\\r\\n (Excel)" = "\r\n", "\\n (newline)" = "\n",
                      "; (semicolon)" = ";", ", (comma)" = ","),
          selected = "\r\n"),

        conditionalPanel("input.plot_type === 'Bar'",
          sliderInput("bar_width", "Bar width", 0.1, 1, 0.6, 0.05),
          sliderInput("label_space", "Label space", 1, 3, 1.6, 0.1),
          if (has_ggfittext) checkboxInput("studlabs_bar", "Show study labels", FALSE)),
        conditionalPanel("input.plot_type === 'Histogram'",
          selectInput("fill_by_hist", "Stack by (optional)", choices = NULL),
          numericInput("bins_hist", "Number of bins", value = 30, min = 2, max = 200, step = 1),
          numericInput("binwidth_hist", "Bin width (optional, overrides bins)",
                       value = NA, min = 0, step = 1)),
        conditionalPanel("input.plot_type === 'Pie/Donut'",
          checkboxInput("donut", "Donut style", TRUE)),
        conditionalPanel("input.plot_type === 'Waffle'",
          numericInput("ncol_waffle", "Grid columns", 5, min = 1, max = 30)),
        conditionalPanel("input.plot_type === 'Overlap'",
          checkboxInput("studlabs_overlap", "Study labels in tiles", FALSE)),
        conditionalPanel("input.plot_type === 'Trend'",
          selectInput("trend_labels", "Bar labels",
                      choices = c("none", "count", "percent", "both", "studies"))),
        conditionalPanel("input.plot_type === 'Treemap'",
          selectInput("color_by", "Color by (optional)", choices = NULL),
          checkboxInput("studlabs_treemap", "Show study labels", FALSE)),
        conditionalPanel("input.plot_type === 'Alluvial'",
          selectInput("alluv_labels", "Stratum labels",
                      choices = c("none", "prop", "count", "both")),
          checkboxInput("flow_labels", "Show flow labels", FALSE),
          sliderInput("flow_alpha", "Flow transparency", 0, 1, 0.25, 0.05),
          sliderInput("stratum_width", "Stratum width", 0.1, 1, 0.5, 0.05)),
        conditionalPanel("input.plot_type === 'Stacked'",
          selectInput("group", "Split by (fill)", choices = NULL),
          radioButtons("stacked_position", "Bars show",
                       choices = c("Proportion (100%)" = "fill",
                                   "Counts" = "stack"),
                       selected = "fill"),
          checkboxInput("stacked_labels", "Show segment labels", TRUE)),
        conditionalPanel("input.plot_type === 'UpSet'",
          selectInput("upset_sort", "Sort combinations by",
                      choices = c("Frequency" = "freq", "Set size" = "degree")),
          numericInput("upset_n", "Max combinations", value = 15,
                       min = 2, max = 40, step = 1))
      ),

      # -- Appearance & NA -------------------------------------------------------
      accordion_panel("Appearance & NA", value = "appearance",
        icon = icon("palette"),
        sliderInput("base_size", "Base font size", 8, 24, 12, 1),
        tags$hr(),
        conditionalPanel("input.plot_type === 'Bar'",
          palette_selectize("fill_bar", "Fill color",
                            choices = c(palette_choices, "Custom" = "custom")),
          conditionalPanel("input.fill_bar === 'custom'",
            textInput("fill_bar_custom", NULL, value = "#7BB0D1",
                      placeholder = "#hex"))),
        conditionalPanel("input.plot_type === 'Histogram' && !input.fill_by_hist",
          palette_selectize("fill_hist", "Fill color",
                            choices = palette_choices, selected = "#7BB0D1")),
        conditionalPanel("input.plot_type === 'Overlap'",
          palette_selectize("fill_overlap", "High color",
                            choices = palette_choices, selected = PALETTE[7])),
        conditionalPanel("input.plot_type === 'Map'",
          palette_selectize("fill_map", "High color",
                            choices = palette_choices, selected = PALETTE[7])),
        conditionalPanel("input.plot_type === 'UpSet'",
          palette_selectize("fill_upset", "Bar color",
                            choices = palette_choices, selected = "#7BB0D1")),
        conditionalPanel(
          "['Waffle','Pie/Donut','Trend','Alluvial','Treemap','Stacked','Matrix','Tree'].includes(input.plot_type)",
          selectInput("palette", "Color palette",
                      choices = c("litReview default" = "",
                                  "ColorBrewer: Set1" = "Set1",
                                  "ColorBrewer: Set2" = "Set2",
                                  "ColorBrewer: Set3" = "Set3",
                                  "ColorBrewer: Dark2" = "Dark2",
                                  "ColorBrewer: Paired" = "Paired",
                                  "ColorBrewer: Accent" = "Accent",
                                  "ColorBrewer: Pastel1" = "Pastel1",
                                  "ColorBrewer: Pastel2" = "Pastel2"))),
        tags$hr(),
        checkboxInput("na_rm", "Remove NAs", TRUE),
        conditionalPanel("!input.na_rm",
          # na_label applies everywhere except the choropleth Map
          conditionalPanel("input.plot_type !== 'Map'",
            textInput("na_label", "NA label", "Not reported")),
          # sample-wide percentage denominator: only the frequency-table plots
          conditionalPanel(
            "['Bar','Pie/Donut','Waffle','Table'].includes(input.plot_type)",
            checkboxInput("na_in_percent", "Include NA in percent", TRUE)),
          # order the NA category last: plots with an explicit category order
          conditionalPanel(
            "['Bar','Pie/Donut','Waffle','Table','Stacked','Trend','Tree'].includes(input.plot_type)",
            checkboxInput("na_last", "Place NA last", FALSE)))
      )
    )
  ),

  # -- Main panel --------------------------------------------------------------
  navset_card_tab(id = "main_tabs",
    nav_panel("Notebook", icon = icon("book"),
      tags$div(class = "mb-3",
        actionButton("add_plot", "Add Plot",
                     class = "btn-primary btn-lg w-100",
                     icon = icon("plus-circle"))),
      uiOutput("notebook_ui"),
      tags$div(class = "mt-3 mb-3 d-flex gap-2 flex-wrap",
        downloadButton("download_all", "Download All (ZIP)",
                       class = "btn-outline-success", icon = icon("file-zipper")),
        downloadButton("download_script", "Download R Script",
                       class = "btn-outline-primary", icon = icon("code")),
        actionButton("clear_session", "Clear Session",
                     class = "btn-outline-danger", icon = icon("trash")))),
    nav_panel("Data Preview", icon = icon("table"),
      verbatimTextOutput("data_summary"),
      tableOutput("data_preview"))
  )
)

# =============================================================================
# SERVER
# =============================================================================
server <- function(input, output, session) {

  loaded_data      <- reactiveVal(NULL)
  notebook         <- reactiveValues(plots = list(), counter = 0L)
  editing_id       <- reactiveVal(NULL)
  delete_observers <- reactiveValues()
  edit_observers   <- reactiveValues()
  restoring        <- reactiveVal(FALSE)  # flag to suppress save during restore
  pending_data_refresh <- reactiveVal(FALSE)  # refresh plots on next Notebook visit

  # -- Data loading -----------------------------------------------------------
  # Re-read the uploaded file whenever the file itself OR (for Excel) the
  # selected sheet number changes.
  observe({
    fu <- input$file_upload
    req(fu)
    ext <- tolower(tools::file_ext(fu$name))
    is_excel <- !(ext %in% c("csv", "tsv", "txt"))
    sheet <- if (is_excel) max(1L, as.integer(input$sheet_input %||% 1L)) else 1L
    tryCatch({
      df <- if (is_excel) {
        rlang::check_installed("readxl", reason = "to import Excel files")
        as.data.frame(readxl::read_excel(fu$datapath, sheet = sheet))
      } else {
        utils::read.delim(fu$datapath, stringsAsFactors = FALSE,
                          check.names = FALSE,
                          sep = if (ext == "csv") "," else "\t")
      }
      loaded_data(df)
      showNotification(
        paste0("Loaded ", nrow(df), " rows, ", ncol(df), " columns",
               if (is_excel) paste0(" (sheet ", sheet, ")") else ""),
        type = "message")
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error", duration = 10)
    })
  })

  observeEvent(input$load_url, {
    req(input$url_input)
    tryCatch({
      df <- import_from_google_drive(input$url_input, sheet = input$sheet_input)
      loaded_data(df)
      showNotification(paste("Loaded", nrow(df), "rows,", ncol(df), "columns"),
                       type = "message")
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error", duration = 10)
    })
  })

  observeEvent(input$use_example, {
    loaded_data(litReview::studies)
    showNotification("Loaded example dataset (50 studies)", type = "message")
  })

  # -- Refresh existing plots when the data changes ---------------------------
  # For each plot in the notebook, check that every column its params reference
  # is present in the new data. If so, rebuild the plot with the new data;
  # otherwise remove the card.
  cols_required_by <- function(p) {
    needed <- character()
    if (!is.null(p$study_id)) needed <- c(needed, p$study_id)
    switch(p$plot_type %||% "",
      "Bar" =, "Waffle" =, "Pie/Donut" =, "Trend" =, "Treemap" =,
      "Table" =, "Histogram" =, "UpSet" = { needed <- c(needed, p$col) },
      "Stacked"  = { needed <- c(needed, p$col, p$group) },
      "Overlap"  = { needed <- c(needed, p$col1, p$col2) },
      "Alluvial" = { needed <- c(needed, p$cols) },
      "Matrix"   = { needed <- c(needed, p$matrix_cols) },
      "Tree"     = { needed <- c(needed, p$tree_cols) },
      "Map"      = { needed <- c(needed, p$country_col) })
    if (identical(p$plot_type, "Trend"))
      needed <- c(needed, p$year_col)
    if (identical(p$plot_type, "Matrix") && nzchar(p$matrix_color %||% ""))
      needed <- c(needed, p$matrix_color)
    if (identical(p$plot_type, "Treemap") && nzchar(p$color_by %||% ""))
      needed <- c(needed, p$color_by)
    if (identical(p$plot_type, "Histogram") && nzchar(p$fill_by_hist %||% ""))
      needed <- c(needed, p$fill_by_hist)
    unique(needed[nzchar(needed)])
  }

  refresh_plots_for_new_data <- function(df) {
    if (length(notebook$plots) == 0L) return(invisible())
    new_cols <- names(df)
    kept <- list()
    removed <- integer()
    for (entry in notebook$plots) {
      needed <- cols_required_by(entry$params)
      if (length(setdiff(needed, new_cols)) > 0L) {
        removed <- c(removed, entry$id); next
      }
      new_res <- tryCatch(build_plot_from_params(df, entry$params),
                          error = function(e) NULL)
      if (is.null(new_res)) { removed <- c(removed, entry$id); next }
      entry$result <- new_res
      entry$is_gt  <- inherits(new_res, "gt_tbl")
      kept <- c(kept, list(entry))
    }
    notebook$plots <- kept
    if (length(removed) > 0L) {
      if (!is.null(editing_id()) && editing_id() %in% removed) editing_id(NULL)
      showNotification(
        paste("Removed", length(removed),
              "plot(s) referencing missing columns."),
        type = "warning", duration = 8)
    }
  }

  # -- Update column selectors ------------------------------------------------
  observeEvent(loaded_data(), {
    df <- loaded_data(); req(df); cols <- names(df)
    id_def  <- if ("StudyID" %in% cols) "StudyID" else cols[1]
    yr_def  <- if ("Year" %in% cols)    "Year"    else cols[1]
    ctr_def <- if ("Country" %in% cols) "Country" else cols[1]
    other   <- setdiff(cols, id_def)
    col_def <- if (length(other)) other[1] else cols[1]
    grp_pool <- setdiff(cols, c(id_def, col_def))
    grp_def <- if (length(grp_pool)) grp_pool[1] else col_def
    updateSelectInput(session, "study_id",    choices = cols, selected = id_def)
    updateSelectInput(session, "col",         choices = cols, selected = col_def)
    updateSelectInput(session, "group",       choices = cols, selected = grp_def)
    updateSelectInput(session, "col1",        choices = cols, selected = cols[1])
    updateSelectInput(session, "col2",        choices = cols,
                      selected = if (length(cols) >= 2) cols[2] else cols[1])
    updateSelectizeInput(session, "cols",     choices = cols,
                         selected = if (length(cols) >= 2) cols[1:2] else cols[1])
    updateSelectInput(session, "country_col", choices = cols, selected = ctr_def)
    updateSelectInput(session, "year_col",    choices = cols, selected = yr_def)
    updateSelectInput(session, "color_by",    choices = c("(None)" = "", cols), selected = "")
    updateSelectInput(session, "fill_by_hist", choices = c("(None)" = "", cols), selected = "")
    # Prefer single-character coded columns (e.g. F/P/M) as the matrix default
    coded <- cols[vapply(cols, function(cc) {
      v <- trimws(as.character(df[[cc]])); v <- v[!is.na(v) & nzchar(v)]
      length(v) > 0 && all(nchar(v) == 1)
    }, logical(1))]
    mtx_def <- if (length(coded) >= 1) coded else
      if (length(other) >= 2) other[1:2] else other[1]
    updateSelectizeInput(session, "matrix_cols", choices = cols, selected = mtx_def)
    updateSelectInput(session, "matrix_color", choices = c("(None)" = "", cols), selected = "")
    tree_def <- if (all(c("InterventionType", "Intervention") %in% cols))
      c("InterventionType", "Intervention")
    else if (length(other) >= 2) other[1:2] else other[1]
    updateSelectizeInput(session, "tree_cols", choices = cols, selected = tree_def)
    pending_data_refresh(TRUE)
    if (!restoring()) nav_select("main_tabs", "Data Preview")
  })

  # -- Refresh plots when the user actually opens the Notebook tab -------------
  observeEvent(input$main_tabs, {
    if (identical(input$main_tabs, "Notebook") && isTRUE(pending_data_refresh())) {
      df <- loaded_data()
      if (!is.null(df)) refresh_plots_for_new_data(df)
      pending_data_refresh(FALSE)
    }
  }, ignoreInit = TRUE)

  # -- Data preview -----------------------------------------------------------
  output$data_summary <- renderPrint({
    req(loaded_data()); df <- loaded_data()
    cat(sprintf("%d rows x %d columns\n", nrow(df), ncol(df)))
    cat("Columns:", paste(names(df), collapse = ", "), "\n")
    str(df, give.attr = FALSE, list.len = ncol(df))
  })
  output$data_preview <- renderTable({ req(loaded_data()); head(loaded_data(), 20) })

  # -- Snapshot / restore sidebar params --------------------------------------
  snapshot_params <- function() {
    list(
      plot_type = input$plot_type, study_id = input$study_id,
      col = input$col, col1 = input$col1, col2 = input$col2,
      cols = input$cols, country_col = input$country_col,
      year_col = input$year_col, color_by = input$color_by,
      sep = input$sep, base_size = input$base_size,
      na_rm = input$na_rm, na_label = input$na_label,
      na_in_percent = input$na_in_percent, na_last = input$na_last,
      fill_bar = input$fill_bar, fill_bar_custom = input$fill_bar_custom,
      bar_width = input$bar_width, label_space = input$label_space,
      studlabs_bar = input$studlabs_bar, donut = input$donut,
      ncol_waffle = input$ncol_waffle, fill_overlap = input$fill_overlap,
      studlabs_overlap = input$studlabs_overlap, trend_labels = input$trend_labels,
      fill_map = input$fill_map, studlabs_treemap = input$studlabs_treemap,
      alluv_labels = input$alluv_labels, flow_labels = input$flow_labels,
      flow_alpha = input$flow_alpha, stratum_width = input$stratum_width,
      fill_by_hist = input$fill_by_hist, fill_hist = input$fill_hist,
      bins_hist = input$bins_hist, binwidth_hist = input$binwidth_hist,
      group = input$group, stacked_position = input$stacked_position,
      stacked_labels = input$stacked_labels, fill_upset = input$fill_upset,
      upset_sort = input$upset_sort, upset_n = input$upset_n,
      matrix_cols = input$matrix_cols, matrix_color = input$matrix_color,
      matrix_counts = input$matrix_counts,
      tree_cols = input$tree_cols, tree_members = input$tree_members,
      tree_counts = input$tree_counts, tree_root = input$tree_root,
      palette = input$palette)
  }

  restore_params <- function(p) {
    # Update plot type via JS (icon buttons, not a select)
    session$sendCustomMessage("set_plot_type", p$plot_type)
    updateSelectInput(session, "study_id", selected = p$study_id)
    updateSelectInput(session, "col", selected = p$col)
    updateSelectInput(session, "col1", selected = p$col1)
    updateSelectInput(session, "col2", selected = p$col2)
    updateSelectizeInput(session, "cols", selected = p$cols)
    updateSelectInput(session, "country_col", selected = p$country_col)
    updateSelectInput(session, "year_col", selected = p$year_col)
    updateSelectInput(session, "color_by", selected = p$color_by)
    updateSelectInput(session, "sep", selected = p$sep)
    updateSliderInput(session, "base_size", value = p$base_size)
    updateCheckboxInput(session, "na_rm", value = p$na_rm)
    updateTextInput(session, "na_label", value = p$na_label %||% "Not reported")
    updateCheckboxInput(session, "na_in_percent", value = p$na_in_percent %||% TRUE)
    updateCheckboxInput(session, "na_last", value = p$na_last %||% FALSE)
    updateSelectInput(session, "fill_bar", selected = p$fill_bar)
    updateTextInput(session, "fill_bar_custom", value = p$fill_bar_custom %||% "#7BB0D1")
    updateSliderInput(session, "bar_width", value = p$bar_width %||% 0.6)
    updateSliderInput(session, "label_space", value = p$label_space %||% 1.6)
    if (has_ggfittext)
      updateCheckboxInput(session, "studlabs_bar", value = p$studlabs_bar %||% FALSE)
    updateCheckboxInput(session, "donut", value = p$donut %||% TRUE)
    updateNumericInput(session, "ncol_waffle", value = p$ncol_waffle %||% 5)
    updateSelectInput(session, "fill_overlap", selected = p$fill_overlap)
    updateCheckboxInput(session, "studlabs_overlap", value = p$studlabs_overlap %||% FALSE)
    updateSelectInput(session, "trend_labels", selected = p$trend_labels)
    updateSelectInput(session, "fill_map", selected = p$fill_map)
    updateCheckboxInput(session, "studlabs_treemap", value = p$studlabs_treemap %||% FALSE)
    updateSelectInput(session, "alluv_labels", selected = p$alluv_labels)
    updateCheckboxInput(session, "flow_labels", value = p$flow_labels %||% FALSE)
    updateSliderInput(session, "flow_alpha", value = p$flow_alpha %||% 0.25)
    updateSliderInput(session, "stratum_width", value = p$stratum_width %||% 0.5)
    updateSelectInput(session, "fill_by_hist", selected = p$fill_by_hist %||% "")
    updateSelectInput(session, "fill_hist", selected = p$fill_hist %||% "#7BB0D1")
    updateNumericInput(session, "bins_hist", value = p$bins_hist %||% 30)
    updateNumericInput(session, "binwidth_hist", value = p$binwidth_hist %||% NA)
    updateSelectInput(session, "group", selected = p$group)
    updateRadioButtons(session, "stacked_position", selected = p$stacked_position %||% "fill")
    updateCheckboxInput(session, "stacked_labels", value = p$stacked_labels %||% TRUE)
    updateSelectInput(session, "fill_upset", selected = p$fill_upset %||% "#7BB0D1")
    updateSelectInput(session, "upset_sort", selected = p$upset_sort %||% "freq")
    updateNumericInput(session, "upset_n", value = p$upset_n %||% 15)
    updateSelectizeInput(session, "matrix_cols", selected = p$matrix_cols)
    updateSelectInput(session, "matrix_color", selected = p$matrix_color %||% "")
    updateCheckboxInput(session, "matrix_counts", value = p$matrix_counts %||% TRUE)
    updateSelectizeInput(session, "tree_cols", selected = p$tree_cols)
    updateCheckboxInput(session, "tree_members", value = p$tree_members %||% TRUE)
    updateSelectInput(session, "tree_counts", selected = p$tree_counts %||% "none")
    updateTextInput(session, "tree_root", value = p$tree_root %||% "All studies")
    updateSelectInput(session, "palette", selected = p$palette %||% "")
  }

  # -- Build plot from current sidebar (reactive, tracks all inputs) -----------
  current_plot <- reactive({
    df <- loaded_data(); req(df)
    typ <- input$plot_type; req(typ)
    bs  <- input$base_size; sep <- input$sep
    sid_str <- input$study_id; req(sid_str)
    sid <- rlang::sym(sid_str)
    na_rm  <- input$na_rm
    na_lab <- if (!na_rm) input$na_label else "Not reported"
    na_pct <- if (!na_rm) input$na_in_percent else TRUE
    na_lst <- if (!na_rm) input$na_last else FALSE
    pal <- if (nzchar(input$palette %||% "")) input$palette else PALETTE

    tryCatch(
      switch(typ,
        "Bar" = {
          req(input$col)
          fill <- if (identical(input$fill_bar, "custom")) input$fill_bar_custom else input$fill_bar
          sl <- if (has_ggfittext) isTRUE(input$studlabs_bar) else FALSE
          rlang::inject(reviewBar(df, !!rlang::sym(input$col), fill = fill,
            width = input$bar_width, sep = sep, studlabs = sl, study_id = !!sid,
            label_space = input$label_space, base_size = bs, na.rm = na_rm,
            na_label = na_lab, na_in_percent = na_pct, na_last = na_lst))
        },
        "Histogram" = { req(input$col)
          fb <- if (nzchar(input$fill_by_hist %||% "")) rlang::sym(input$fill_by_hist) else NULL
          bw <- if (isTRUE(is.finite(input$binwidth_hist)) && input$binwidth_hist > 0) input$binwidth_hist else NULL
          rlang::inject(reviewHistogram(df, !!rlang::sym(input$col), fill_by = !!fb,
            bins = input$bins_hist, binwidth = bw, fill = input$fill_hist,
            sep = sep, base_size = bs, na.rm = na_rm, na_label = na_lab)) },
        "Waffle" = { req(input$col); rlang::inject(
          reviewWaffle(df, !!rlang::sym(input$col), sep = sep, colors = pal,
            ncol = input$ncol_waffle, study_id = !!sid, base_size = bs,
            na.rm = na_rm, na_label = na_lab, na_in_percent = na_pct,
            na_last = na_lst)) },
        "Pie/Donut" = { req(input$col); rlang::inject(
          reviewPie(df, !!rlang::sym(input$col), sep = sep, colors = pal,
            donut = input$donut, study_id = !!sid, base_size = bs,
            na.rm = na_rm, na_label = na_lab, na_in_percent = na_pct,
            na_last = na_lst)) },
        "Overlap" = { req(input$col1, input$col2); rlang::inject(
          reviewOverlap(df, !!rlang::sym(input$col1), !!rlang::sym(input$col2),
            sep = sep, fill = input$fill_overlap, base_size = bs,
            na.rm = na_rm, na_label = na_lab,
            studlabs = input$studlabs_overlap, study_id = !!sid)) },
        "Trend" = { req(input$col, input$year_col); rlang::inject(
          reviewTrend(df, !!rlang::sym(input$col),
            year_col = !!rlang::sym(input$year_col), sep = sep, base_size = bs,
            colors = pal, na.rm = na_rm, na_label = na_lab, na_last = na_lst,
            labels = input$trend_labels, study_id = !!sid)) },
        "Map" = { req(input$country_col); rlang::inject(
          reviewMap(df, country_col = !!rlang::sym(input$country_col),
            sep = sep, fill = input$fill_map, base_size = bs, na.rm = na_rm)) },
        "Alluvial" = { req(input$cols, length(input$cols) >= 2); rlang::inject(
          reviewAlluvial(df, input$cols, sep = sep, study_id = !!sid,
            base_size = bs, colors = pal, na.rm = na_rm, na_label = na_lab,
            labels = input$alluv_labels, flow_labels = input$flow_labels,
            flow_alpha = input$flow_alpha, stratum_width = input$stratum_width)) },
        "Treemap" = { req(input$col)
          cb <- if (nzchar(input$color_by)) rlang::sym(input$color_by) else NULL
          rlang::inject(reviewTreemap(df, !!rlang::sym(input$col),
            color_by = !!cb, sep = sep, base_size = bs, colors = pal,
            na.rm = na_rm, na_label = na_lab, study_id = !!sid,
            studlabs = input$studlabs_treemap)) },
        "Table" = { req(input$col); rlang::inject(
          reviewTable(df, !!rlang::sym(input$col), sep = sep, study_id = !!sid,
            na.rm = na_rm, na_label = na_lab, na_in_percent = na_pct,
            na_last = na_lst)) },
        "Stacked" = { req(input$col, input$group); rlang::inject(
          reviewStackedBar(df, !!rlang::sym(input$col), !!rlang::sym(input$group),
            position = input$stacked_position %||% "fill", sep = sep,
            study_id = !!sid, fill = pal, base_size = bs, na.rm = na_rm,
            na_label = na_lab, na_last = na_lst,
            labels = isTRUE(input$stacked_labels))) },
        "UpSet" = { req(input$col); rlang::inject(
          reviewUpset(df, !!rlang::sym(input$col), sep = sep, study_id = !!sid,
            base_size = bs, na.rm = na_rm, na_label = na_lab,
            n_intersections = input$upset_n %||% 15,
            sort_by = input$upset_sort %||% "freq",
            fill = input$fill_upset %||% "#7BB0D1")) },
        "Matrix" = { req(input$matrix_cols, length(input$matrix_cols) >= 1)
          cb <- if (nzchar(input$matrix_color %||% "")) input$matrix_color else NULL
          rlang::inject(reviewMatrix(df, input$matrix_cols, color_by = cb,
            study_id = !!sid, show_counts = isTRUE(input$matrix_counts),
            colors = pal, base_size = bs, na.rm = na_rm, na_label = na_lab)) },
        "Tree" = { req(input$tree_cols, length(input$tree_cols) >= 1)
          rlang::inject(reviewTree(df, input$tree_cols, study_id = !!sid,
            sep = sep, colors = pal, show_members = isTRUE(input$tree_members),
            counts = input$tree_counts %||% "none",
            root_label = input$tree_root %||% "All studies",
            base_size = bs, na.rm = na_rm, na_label = na_lab, na_last = na_lst)) }
      ),
      error = function(e) NULL
    )
  })

  current_plot_d <- current_plot |> debounce(400)

  # -- Live update: push changes to the active card + scroll to it -------------
  # Depend only on the (debounced) plot, not on editing_id — otherwise clicking
  # a card would fire this observer before restore_params had propagated to
  # current_plot_d, writing the previously-edited plot into the newly clicked
  # card for one debounce cycle (visible as a flicker).
  observe({
    result <- current_plot_d(); req(result)
    eid <- isolate(editing_id()); req(eid)
    typ <- isolate(input$plot_type)
    col_label <- isolate(switch(typ,
      "Overlap"  = paste(input$col1, "vs", input$col2),
      "Alluvial" = paste(input$cols, collapse = ", "),
      "Stacked"  = paste(input$col, "by", input$group),
      "Matrix"   = paste(input$matrix_cols, collapse = ", "),
      "Tree"     = paste(input$tree_cols, collapse = " > "),
      "Map"      = input$country_col, input$col))
    title  <- paste0(typ, ": ", col_label)
    params <- isolate(snapshot_params())
    notebook$plots <- lapply(notebook$plots, function(e) {
      if (e$id == eid) {
        e$type <- typ; e$title <- title; e$result <- result
        e$is_gt <- inherits(result, "gt_tbl"); e$params <- params
      }; e
    })
    # Scroll to the active card
    shiny::insertUI(selector = "body", where = "beforeEnd", immediate = TRUE,
      ui = tags$script(sprintf(
        "setTimeout(function(){
           var el = document.getElementById('card_%d');
           if(el) el.scrollIntoView({behavior:'smooth', block:'nearest'});
         }, 100);", eid)))
  })

  # -- Helper: set up per-card observers --------------------------------------
  setup_card_observers <- function(cid) {
    delete_observers[[as.character(cid)]] <- observeEvent(
      input[[paste0("delete_", cid)]], {
        notebook$plots <- Filter(function(e) e$id != cid, notebook$plots)
        if (identical(editing_id(), cid)) editing_id(NULL)
      }, ignoreInit = TRUE, once = TRUE)
    edit_observers[[as.character(cid)]] <- observeEvent(
      input[[paste0("edit_", cid)]], {
        entry <- Find(function(e) e$id == cid, notebook$plots)
        if (!is.null(entry)) { restore_params(entry$params); editing_id(cid) }
      }, ignoreInit = TRUE)
  }

  # -- Add new plot (creates card + enters edit mode) --------------------------
  observeEvent(input$add_plot, {
    req(loaded_data())
    result <- current_plot(); req(result)

    typ <- input$plot_type
    col_label <- switch(typ,
      "Overlap"  = paste(input$col1, "vs", input$col2),
      "Alluvial" = paste(input$cols, collapse = ", "),
      "Stacked"  = paste(input$col, "by", input$group),
      "Matrix"   = paste(input$matrix_cols, collapse = ", "),
      "Tree"     = paste(input$tree_cols, collapse = " > "),
      "Map"      = input$country_col, input$col)
    title  <- paste0(typ, ": ", col_label)
    params <- snapshot_params()
    notebook$counter <- notebook$counter + 1L
    id <- notebook$counter
    entry <- list(id = id, type = typ, title = title, result = result,
                  is_gt = inherits(result, "gt_tbl"), params = params,
                  width = 10, height = 6)
    notebook$plots <- c(notebook$plots, list(entry))
    setup_card_observers(id)

    # Immediately enter edit mode on the new card
    editing_id(id)

    nav_select("main_tabs", "Notebook")
    shiny::insertUI(selector = "body", where = "beforeEnd", immediate = TRUE,
      ui = tags$script(sprintf(
        "setTimeout(function(){
           var el = document.getElementById('card_%d');
           if(el) el.scrollIntoView({behavior:'smooth', block:'start'});
         }, 300);", id)))
  })

  # -- Clear session -----------------------------------------------------------
  observeEvent(input$clear_session, {
    notebook$plots <- list()
    notebook$counter <- 0L
    loaded_data(NULL)
    editing_id(NULL)
    session$sendCustomMessage("clear_state", list())
    showNotification("Session cleared", type = "message")
  })

  # -- Save state to localStorage (debounced) ----------------------------------
  save_trigger <- reactive({
    # Depend on each card's height/width inputs so a resize is persisted
    dims <- lapply(notebook$plots, function(e)
      c(input[[paste0("h_", e$id)]], input[[paste0("w_", e$id)]]))
    list(notebook$plots, loaded_data(), dims)
  }) |> debounce(1000)

  observe({
    save_trigger()
    if (restoring()) return()
    df <- isolate(loaded_data())
    plots <- isolate(notebook$plots)
    counter <- isolate(notebook$counter)

    # Only save params, not ggplot objects
    plot_meta <- lapply(plots, function(e) {
      list(id = e$id, type = e$type, title = e$title,
           is_gt = e$is_gt, params = e$params,
           width  = isolate(input[[paste0("w_", e$id)]]) %||% e$width  %||% 10,
           height = isolate(input[[paste0("h_", e$id)]]) %||% e$height %||% 6)
    })

    state <- list(
      data = if (!is.null(df)) as.character(jsonlite::toJSON(df, dataframe = "rows", auto_unbox = TRUE)) else NULL,
      plots = plot_meta,
      counter = counter
    )
    session$sendCustomMessage("save_state", state)
  })

  # -- Restore state from localStorage ----------------------------------------
  observeEvent(input$`_restore_state`, {
    state <- input$`_restore_state`
    if (is.null(state) || is.null(state$data)) return()

    restoring(TRUE)
    on.exit(restoring(FALSE))

    tryCatch({
      # Restore data — state$data may be a JSON string or already-parsed list
      raw <- state$data
      df <- if (is.character(raw)) {
        jsonlite::fromJSON(raw, simplifyDataFrame = TRUE)
      } else if (is.data.frame(raw)) {
        raw
      } else if (is.list(raw) && length(raw) > 0) {
        # Could be column-major (named list of vectors) or row-major (list of lists)
        if (!is.null(names(raw)) && all(vapply(raw, is.atomic, FALSE))) {
          as.data.frame(raw, stringsAsFactors = FALSE)
        } else {
          do.call(rbind, lapply(raw, function(r)
            as.data.frame(r, stringsAsFactors = FALSE)))
        }
      } else {
        stop("Unrecognized data format in saved state")
      }
      loaded_data(df)
      notebook$counter <- state$counter %||% 0L

      # Rebuild plots from stored params (no input$ needed)
      restored <- 0L
      for (pm in state$plots) {
        tryCatch({
          pm$params <- normalize_params(pm$params)
          result <- build_plot_from_params(df, pm$params)
          id <- pm$id
          entry <- list(id = id, type = pm$type, title = pm$title,
                        result = result, is_gt = inherits(result, "gt_tbl"),
                        params = pm$params,
                        width = pm$width %||% 10, height = pm$height %||% 6)
          notebook$plots <- c(notebook$plots, list(entry))
          setup_card_observers(id)
          restored <- restored + 1L
        }, error = function(e) NULL)
      }
      restoring(FALSE)
      if (restored > 0L) {
        nav_select("main_tabs", "Notebook")
        showNotification(paste("Restored", restored, "plot(s)"), type = "message")
      }
    }, error = function(e) {
      restoring(FALSE)
    })
  }, ignoreNULL = TRUE, once = TRUE)

  # -- Render notebook cards ---------------------------------------------------
  output$notebook_ui <- renderUI({
    plots <- notebook$plots
    if (length(plots) == 0)
      return(tags$div(class = "text-center text-muted py-5",
        tags$p(icon("chart-bar", class = "fa-3x")),
        tags$p("No plots yet. Configure options in the sidebar and click",
               tags$strong("Add Plot"), "above. Click any plot to edit it.")))

    eid <- editing_id()
    card_list <- lapply(plots, function(entry) {
      pid    <- paste0("plot_", entry$id)
      gid    <- paste0("gt_", entry$id)
      del_id <- paste0("delete_", entry$id)
      dl_png <- paste0("dl_png_", entry$id)
      dl_pdf <- paste0("dl_pdf_", entry$id)
      w_id   <- paste0("w_", entry$id)
      h_id   <- paste0("h_", entry$id)
      is_ed  <- identical(eid, entry$id)

      body <- if (entry$is_gt) gt::gt_output(gid) else plotOutput(pid, width = "100%")

      h_val <- isolate(input[[h_id]]) %||% entry$height %||% 6
      w_val <- isolate(input[[w_id]]) %||% entry$width %||% 10
      dim_row <- if (!entry$is_gt) tags$div(
        class = "d-flex gap-2 align-items-end flex-wrap",
        tags$div(style = "width:100px;",
          numericInput(h_id, "Height (in)", value = h_val, min = 2, max = 16, step = 1)),
        tags$div(style = "width:120px;",
          numericInput(w_id, "Export width (in)", value = w_val, min = 3, max = 20, step = 1)))

      btns <- tags$div(class = "d-flex gap-2 mt-2",
        if (!entry$is_gt) downloadButton(dl_png, "PNG",
          class = "btn-outline-success btn-sm", icon = icon("image")),
        if (!entry$is_gt) downloadButton(dl_pdf, "PDF",
          class = "btn-outline-success btn-sm", icon = icon("file-pdf")),
        actionButton(del_id, NULL,
          class = "btn-outline-danger btn-sm", icon = icon("trash")))

      card(full_screen = TRUE,
        id = paste0("card_", entry$id),
        class = if (is_ed) "border-warning border-2 litr-editing" else "",
        height = "auto",
        card_header(tags$strong(entry$title),
          if (is_ed) tags$span(class = "badge bg-warning ms-2", "editing")),
        card_body(body, fillable = FALSE),
        card_footer(dim_row, btns))
    })
    tagList(card_list)
  })

  # -- Dynamic plot/table outputs & downloads ----------------------------------
  observe({
    for (entry in notebook$plots) {
      local({ e <- entry
        cid <- e$id
        pid <- paste0("plot_", cid); gid <- paste0("gt_", cid)
        dl_png <- paste0("dl_png_", cid); dl_pdf <- paste0("dl_pdf_", cid)
        w_inp <- paste0("w_", cid); h_inp <- paste0("h_", cid)
        if (e$is_gt) {
          output[[gid]] <- gt::render_gt({ e$result })
        } else {
          output[[pid]] <- renderPlot({ print(e$result) },
            res = 96, height = function() (input[[h_inp]] %||% e$height %||% 6) * 96)
          output[[dl_png]] <- downloadHandler(
            filename = function() paste0("litReview_",
              gsub("[^A-Za-z0-9]", "_", e$title), ".png"),
            content = function(file) ggplot2::ggsave(file, plot = e$result,
              width = input[[w_inp]] %||% e$width %||% 10,
              height = input[[h_inp]] %||% e$height %||% 6,
              dpi = 300, bg = "white"))
          output[[dl_pdf]] <- downloadHandler(
            filename = function() paste0("litReview_",
              gsub("[^A-Za-z0-9]", "_", e$title), ".pdf"),
            content = function(file) ggplot2::ggsave(file, plot = e$result,
              width = input[[w_inp]] %||% e$width %||% 10,
              height = input[[h_inp]] %||% e$height %||% 6,
              bg = "white"))
        }
      })
    }
  })

  # -- Download All (ZIP) ------------------------------------------------------
  output$download_all <- downloadHandler(
    filename = function() paste0("litReview_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".zip"),
    content = function(file) {
      plots <- notebook$plots; req(length(plots) > 0)
      plot_dir <- file.path(tempdir(), "litReview_plots")
      dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)
      files <- character(0)
      for (entry in plots) {
        safe <- gsub("[^A-Za-z0-9_]", "_", entry$title)
        if (entry$is_gt) {
          f <- file.path(plot_dir, paste0(safe, ".html"))
          gt::gtsave(entry$result, f)
        } else {
          f <- file.path(plot_dir, paste0(safe, ".png"))
          ggplot2::ggsave(f, plot = entry$result,
            width = input[[paste0("w_", entry$id)]] %||% entry$width %||% 10,
            height = input[[paste0("h_", entry$id)]] %||% entry$height %||% 6,
            dpi = 300, bg = "white")
        }
        files <- c(files, f)
      }
      old_wd <- setwd(plot_dir); on.exit(setwd(old_wd), add = TRUE)
      utils::zip(file, files = basename(files))
    })

  # -- Download R Script -------------------------------------------------------
  generate_script <- function() {
    plots <- notebook$plots; req(length(plots) > 0)
    fmt <- function(val) {
      if (is.null(val)) return("NULL")
      if (is.logical(val)) return(if (val) "TRUE" else "FALSE")
      if (is.numeric(val)) return(as.character(val))
      deparse(val)
    }
    col <- function(name) {
      if (make.names(name) == name) name else paste0("`", name, "`")
    }
    lines <- c("library(litReview)", "",
      "# -- Load your data --------------------------------------------------------",
      "# Replace this with your own data loading code:",
      "# data <- rio::import(\"your_file.xlsx\")",
      "data <- litReview::studies", "")

    for (i in seq_along(plots)) {
      entry <- plots[[i]]; p <- entry$params; typ <- p$plot_type
      w <- input[[paste0("w_", entry$id)]] %||% 10
      h <- input[[paste0("h_", entry$id)]] %||% 6
      lines <- c(lines, paste0("# -- Plot ", i, ": ", entry$title, " ",
                                paste(rep("-", 50), collapse = "")))
      sep_arg <- if (identical(p$sep, "\r\n")) "" else paste0(", sep = ", fmt(p$sep))
      sid_arg <- if (identical(p$study_id, "StudyID")) "" else
                   paste0(", study_id = ", col(p$study_id))
      bs_arg  <- if (identical(p$base_size, 12L) || identical(p$base_size, 12)) "" else
                   paste0(", base_size = ", p$base_size)
      pal_col <- if (!is.null(p$palette) && nzchar(p$palette)) paste0(", colors = ", fmt(p$palette)) else ""
      pal_fill <- if (!is.null(p$palette) && nzchar(p$palette)) paste0(", fill = ", fmt(p$palette)) else ""
      # Build NA-argument fragments matched to what each function accepts
      na_core <- if (!isTRUE(p$na_rm))
        paste0(", na.rm = FALSE, na_label = ", fmt(p$na_label %||% "Not reported")) else ""
      na_last_str <- if (!isTRUE(p$na_rm) && isTRUE(p$na_last)) ", na_last = TRUE" else ""
      na_pct_str  <- if (!isTRUE(p$na_rm) && !isTRUE(p$na_in_percent)) ", na_in_percent = FALSE" else ""
      na_args      <- paste0(na_core, na_pct_str, na_last_str)   # Bar/Pie/Waffle/Table
      na_core_last <- paste0(na_core, na_last_str)               # Trend/Stacked/Tree
      call <- switch(typ,
        "Bar" = {
          fill <- if (identical(p$fill_bar, "custom")) p$fill_bar_custom else p$fill_bar
          fill_arg <- if (identical(fill, "#7BB0D1")) "" else paste0(", fill = ", fmt(fill))
          w_arg <- if (identical(p$bar_width, 0.6)) "" else paste0(", width = ", p$bar_width)
          ls_arg <- if (identical(p$label_space, 1.6)) "" else paste0(", label_space = ", p$label_space)
          sl_arg <- if (isTRUE(p$studlabs_bar)) ", studlabs = TRUE" else ""
          paste0("p", i, " <- reviewBar(data, ", col(p$col), fill_arg, w_arg, sl_arg, ls_arg,
                 sep_arg, sid_arg, bs_arg, na_args, ")")
        },
        "Histogram" = {
          fb_arg <- if (!is.null(p$fill_by_hist) && nzchar(p$fill_by_hist)) paste0(", fill_by = ", col(p$fill_by_hist)) else ""
          bins_arg <- if (identical(p$bins_hist, 30L) || identical(p$bins_hist, 30)) "" else paste0(", bins = ", p$bins_hist)
          bw_arg <- if (!is.null(p$binwidth_hist) && isTRUE(is.finite(p$binwidth_hist)) && p$binwidth_hist > 0)
                      paste0(", binwidth = ", p$binwidth_hist) else ""
          fill_arg <- if (nzchar(fb_arg) || identical(p$fill_hist, "#7BB0D1") || is.null(p$fill_hist))
                        "" else paste0(", fill = ", fmt(p$fill_hist))
          paste0("p", i, " <- reviewHistogram(data, ", col(p$col), fb_arg, bins_arg, bw_arg, fill_arg,
                 sep_arg, bs_arg,
                 if (!isTRUE(p$na_rm)) paste0(", na.rm = FALSE, na_label = ", fmt(p$na_label %||% "Not reported")) else "",
                 ")")
        },
        "Waffle" = {
          nc_arg <- if (identical(p$ncol_waffle, 5L) || identical(p$ncol_waffle, 5)) "" else paste0(", ncol = ", p$ncol_waffle)
          paste0("p", i, " <- reviewWaffle(data, ", col(p$col), nc_arg, pal_col, sep_arg, sid_arg, bs_arg, na_args, ")")
        },
        "Pie/Donut" = {
          d_arg <- if (isTRUE(p$donut)) "" else ", donut = FALSE"
          paste0("p", i, " <- reviewPie(data, ", col(p$col), d_arg, pal_col, sep_arg, sid_arg, bs_arg, na_args, ")")
        },
        "Overlap" = {
          fill_arg <- if (identical(p$fill_overlap, "#7BB0D1") || identical(p$fill_overlap, PALETTE[7])) "" else paste0(", fill = ", fmt(p$fill_overlap))
          sl_arg <- if (isTRUE(p$studlabs_overlap)) ", studlabs = TRUE" else ""
          paste0("p", i, " <- reviewOverlap(data, ", col(p$col1), ", ", col(p$col2), fill_arg, sl_arg, sep_arg, sid_arg, bs_arg, na_core, ")")
        },
        "Trend" = {
          yr_arg <- if (identical(p$year_col, "Year")) "" else paste0(", year_col = ", col(p$year_col))
          lb_arg <- if (identical(p$trend_labels, "none")) "" else paste0(", labels = ", fmt(p$trend_labels))
          paste0("p", i, " <- reviewTrend(data, ", col(p$col), yr_arg, lb_arg, pal_col, sep_arg, sid_arg, bs_arg, na_core_last, ")")
        },
        "Map" = {
          cc_arg <- if (identical(p$country_col, "Country")) "" else paste0(", country_col = ", col(p$country_col))
          fill_arg <- if (identical(p$fill_map, "#7BB0D1") || identical(p$fill_map, PALETTE[7])) "" else paste0(", fill = ", fmt(p$fill_map))
          paste0("p", i, " <- reviewMap(data", cc_arg, fill_arg, sep_arg, bs_arg,
                 if (!isTRUE(p$na_rm)) ", na.rm = FALSE" else "", ")")
        },
        "Alluvial" = {
          cols_str <- paste0("c(", paste(fmt(p$cols), collapse = ", "), ")")
          lb_arg <- if (identical(p$alluv_labels, "none")) "" else paste0(", labels = ", fmt(p$alluv_labels))
          fl_arg <- if (isTRUE(p$flow_labels)) ", flow_labels = TRUE" else ""
          fa_arg <- if (identical(p$flow_alpha, 0.25)) "" else paste0(", flow_alpha = ", p$flow_alpha)
          sw_arg <- if (identical(p$stratum_width, 0.5)) "" else paste0(", stratum_width = ", p$stratum_width)
          paste0("p", i, " <- reviewAlluvial(data, ", cols_str, lb_arg, fl_arg, fa_arg, sw_arg, pal_col, sep_arg, sid_arg, bs_arg, na_core, ")")
        },
        "Treemap" = {
          cb_arg <- if (!is.null(p$color_by) && nzchar(p$color_by)) paste0(", color_by = ", col(p$color_by)) else ""
          sl_arg <- if (isTRUE(p$studlabs_treemap)) ", studlabs = TRUE" else ""
          paste0("p", i, " <- reviewTreemap(data, ", col(p$col), cb_arg, sl_arg, pal_col, sep_arg, sid_arg, bs_arg, na_core, ")")
        },
        "Table" = paste0("p", i, " <- reviewTable(data, ", col(p$col), sep_arg, sid_arg, na_args, ")"),
        "Stacked" = {
          pos_arg <- if (identical(p$stacked_position, "stack")) ", position = \"stack\"" else ""
          lab_arg <- if (isFALSE(p$stacked_labels)) ", labels = FALSE" else ""
          paste0("p", i, " <- reviewStackedBar(data, ", col(p$col), ", ", col(p$group),
                 pos_arg, lab_arg, pal_fill, sep_arg, sid_arg, bs_arg, na_core_last, ")")
        },
        "UpSet" = {
          srt_arg  <- if (identical(p$upset_sort, "degree")) ", sort_by = \"degree\"" else ""
          n_arg    <- if (identical(p$upset_n, 15L) || identical(p$upset_n, 15)) "" else paste0(", n_intersections = ", p$upset_n)
          fill_arg <- if (identical(p$fill_upset, "#7BB0D1")) "" else paste0(", fill = ", fmt(p$fill_upset))
          na_simple <- if (!isTRUE(p$na_rm)) paste0(", na.rm = FALSE, na_label = ", fmt(p$na_label %||% "Not reported")) else ""
          paste0("p", i, " <- reviewUpset(data, ", col(p$col),
                 fill_arg, srt_arg, n_arg, sep_arg, sid_arg, bs_arg, na_simple, ")")
        },
        "Matrix" = {
          cols_str <- paste0("c(", paste(vapply(p$matrix_cols, fmt, character(1)), collapse = ", "), ")")
          cby_arg  <- if (!is.null(p$matrix_color) && nzchar(p$matrix_color)) paste0(", color_by = ", fmt(p$matrix_color)) else ""
          sc_arg   <- if (isFALSE(p$matrix_counts)) ", show_counts = FALSE" else ""
          paste0("p", i, " <- reviewMatrix(data, ", cols_str, cby_arg, sc_arg, pal_col, sid_arg, bs_arg, na_core, ")")
        },
        "Tree" = {
          cols_str <- paste0("c(", paste(vapply(p$tree_cols, fmt, character(1)), collapse = ", "), ")")
          sm_arg   <- if (isFALSE(p$tree_members)) ", show_members = FALSE" else ""
          ct_arg   <- if (!identical(p$tree_counts %||% "none", "none")) paste0(", counts = ", fmt(p$tree_counts)) else ""
          rt_arg   <- if (!identical(p$tree_root %||% "All studies", "All studies")) paste0(", root_label = ", fmt(p$tree_root)) else ""
          paste0("p", i, " <- reviewTree(data, ", cols_str, ct_arg, rt_arg, sm_arg, pal_col, sep_arg, sid_arg, bs_arg, na_core_last, ")")
        }
      )
      lines <- c(lines, call)
      if (typ != "Table") {
        safe <- gsub("[^A-Za-z0-9_]", "_", entry$title)
        lines <- c(lines, paste0("ggsave(\"", safe, ".png\", p", i,
                   ", width = ", w, ", height = ", h, ", dpi = 300, bg = \"white\")"))
      }
      lines <- c(lines, "")
    }
    paste(lines, collapse = "\n")
  }

  output$download_script <- downloadHandler(
    filename = function() paste0("litReview_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".R"),
    content = function(file) writeLines(generate_script(), file))
}

shinyApp(ui, server)
