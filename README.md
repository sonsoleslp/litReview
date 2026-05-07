
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `litReview`: An R package for plotting literature review results <img src="man/figures/logo.png" align="right" height="119" />

<!-- badges: start -->

<!-- badges: end -->

`litReview` provides functions to summarize and visualize categorical
data from literature reviews. All plot functions return standard ggplot
objects you can customize with `+`.

## Installation

``` r
remotes::install_github("sonsoleslp/litReview")
```

## Usage

``` r
library(litReview)
data(studies)
```

### Bar chart

``` r
reviewBar(studies, Design)
```

<img src="man/figures/README-bar-1.png" alt="" width="100%" />

``` r
reviewBar(studies, Design, fill = "#59a14f") +
  ggplot2::labs(title = "Study Designs")
```

<img src="man/figures/README-bar-custom-1.png" alt="" width="100%" />

### Study labels on bars

``` r
reviewBar(studies, Design, fill = PALETTE[2], studlabs = TRUE)
```

<img src="man/figures/README-studlabs-1.png" alt="" width="100%" />

### Waffle chart

``` r
reviewWaffle(studies, Design, ncol = 10)
```

<img src="man/figures/README-waffle-1.png" alt="" width="100%" />

### Donut chart

``` r
reviewPie(studies, Design)
```

<img src="man/figures/README-pie-1.png" alt="" width="100%" />

### Co-occurrence heatmap

``` r
reviewOverlap(studies, Design, Outcome)
```

<img src="man/figures/README-overlap-1.png" alt="" width="100%" />

### Alluvial plot

``` r
reviewAlluvial(studies, c("Design", "Outcome"), labels = "prop")
```

<img src="man/figures/README-alluvial-1.png" alt="" width="100%" />

### Year trend

``` r
reviewTrend(studies, Design)
```

<img src="man/figures/README-trend-1.png" alt="" width="100%" />

### World map

``` r
reviewMap(studies)
```

<img src="man/figures/README-map-1.png" alt="" width="100%" />

### Treemap

``` r
reviewTreemap(studies, Design)
```

<img src="man/figures/README-treemap-1.png" alt="" width="100%" />

``` r
reviewTreemap(studies, Intervention, color_by = InterventionType)
```

<img src="man/figures/README-treemap-color-1.png" alt="" width="100%" />

### Summary table

``` r
reviewTable(studies, Design, study_id = "Author")
```

<div id="xcufvqrjed" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#xcufvqrjed table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#xcufvqrjed thead, #xcufvqrjed tbody, #xcufvqrjed tfoot, #xcufvqrjed tr, #xcufvqrjed td, #xcufvqrjed th {
  border-style: none;
}
&#10;#xcufvqrjed p {
  margin: 0;
  padding: 0;
}
&#10;#xcufvqrjed .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#xcufvqrjed .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#xcufvqrjed .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#xcufvqrjed .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#xcufvqrjed .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#xcufvqrjed .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#xcufvqrjed .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#xcufvqrjed .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#xcufvqrjed .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#xcufvqrjed .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#xcufvqrjed .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#xcufvqrjed .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#xcufvqrjed .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#xcufvqrjed .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#xcufvqrjed .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcufvqrjed .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#xcufvqrjed .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#xcufvqrjed .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#xcufvqrjed .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcufvqrjed .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#xcufvqrjed .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcufvqrjed .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#xcufvqrjed .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcufvqrjed .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#xcufvqrjed .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xcufvqrjed .gt_left {
  text-align: left;
}
&#10;#xcufvqrjed .gt_center {
  text-align: center;
}
&#10;#xcufvqrjed .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#xcufvqrjed .gt_font_normal {
  font-weight: normal;
}
&#10;#xcufvqrjed .gt_font_bold {
  font-weight: bold;
}
&#10;#xcufvqrjed .gt_font_italic {
  font-style: italic;
}
&#10;#xcufvqrjed .gt_super {
  font-size: 65%;
}
&#10;#xcufvqrjed .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#xcufvqrjed .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#xcufvqrjed .gt_indent_1 {
  text-indent: 5px;
}
&#10;#xcufvqrjed .gt_indent_2 {
  text-indent: 10px;
}
&#10;#xcufvqrjed .gt_indent_3 {
  text-indent: 15px;
}
&#10;#xcufvqrjed .gt_indent_4 {
  text-indent: 20px;
}
&#10;#xcufvqrjed .gt_indent_5 {
  text-indent: 25px;
}
&#10;#xcufvqrjed .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#xcufvqrjed div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Design">Design</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Studies">Studies</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Frequency">Frequency</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Percent">Percent</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Design" class="gt_row gt_left">RCT</td>
<td headers="Studies" class="gt_row gt_left">Kim et al., Brown et al., Johansson et al., Santos et al., Park et al., Dubois et al., Tanaka et al., Nguyen et al., Takahashi et al., Reyes et al., Larsen et al.</td>
<td headers="Frequency" class="gt_row gt_right">11</td>
<td headers="Percent" class="gt_row gt_right">22%</td></tr>
    <tr><td headers="Design" class="gt_row gt_left">Qualitative</td>
<td headers="Studies" class="gt_row gt_left">Garcia et al., Mueller et al., Novak et al., Petrov et al., Schmidt et al., Eriksson et al., Popov et al., Torres et al., Sato et al.</td>
<td headers="Frequency" class="gt_row gt_right">9</td>
<td headers="Percent" class="gt_row gt_right">18%</td></tr>
    <tr><td headers="Design" class="gt_row gt_left">Mixed methods</td>
<td headers="Studies" class="gt_row gt_left">Johnson et al., Berg et al.</td>
<td headers="Frequency" class="gt_row gt_right">2</td>
<td headers="Percent" class="gt_row gt_right">4%</td></tr>
    <tr><td headers="Design" class="gt_row gt_left">Cross-sectional</td>
<td headers="Studies" class="gt_row gt_left">Patel et al., Silva et al., Ahmed et al., Taylor et al., Rossi et al., Okafor et al., Hassan et al., Olsen et al., Khan et al., Fischer et al., Nakamura et al., Kowalski et al.</td>
<td headers="Frequency" class="gt_row gt_right">12</td>
<td headers="Percent" class="gt_row gt_right">24%</td></tr>
    <tr><td headers="Design" class="gt_row gt_left">Cohort</td>
<td headers="Studies" class="gt_row gt_left">Chen et al., Yamamoto et al., Martinez et al., Li et al., Gupta et al., OBrien et al., Ivanov et al., Costa et al., Muller et al., Ali et al., Diaz et al., Suzuki et al.</td>
<td headers="Frequency" class="gt_row gt_right">12</td>
<td headers="Percent" class="gt_row gt_right">24%</td></tr>
    <tr><td headers="Design" class="gt_row gt_left">Case-control</td>
<td headers="Studies" class="gt_row gt_left">Andersen et al., Williams et al., Fernandez et al., Morales et al.</td>
<td headers="Frequency" class="gt_row gt_right">4</td>
<td headers="Percent" class="gt_row gt_right">8%</td></tr>
  </tbody>
  &#10;</table>
</div>

### Handling missing data

``` r
df_na <- data.frame(
  StudyID = paste0("S", 1:8),
  Design  = c("RCT", "Cohort", NA, "RCT", "Case-control", NA, "RCT", "Cohort"),
  stringsAsFactors = FALSE
)
reviewBar(df_na, Design, na.rm = FALSE, na_label = "Missing", na_last = TRUE)
```

<img src="man/figures/README-na-1.png" alt="" width="100%" />
