# `litReview`: An R package for plotting literature review results

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

![](reference/figures/README-bar-1.png)

``` r

reviewBar(studies, Design, fill = "#59a14f") +
  ggplot2::labs(title = "Study Designs")
```

![](reference/figures/README-bar-custom-1.png)

### Study labels on bars

``` r

reviewBar(studies, Design, fill = PALETTE[2], studlabs = TRUE)
```

![](reference/figures/README-studlabs-1.png)

### Waffle chart

``` r

reviewWaffle(studies, Design, ncol = 10)
```

![](reference/figures/README-waffle-1.png)

### Donut chart

``` r

reviewPie(studies, Design)
```

![](reference/figures/README-pie-1.png)

### Co-occurrence heatmap

``` r

reviewOverlap(studies, Design, Outcome)
```

![](reference/figures/README-overlap-1.png)

### Alluvial plot

``` r

reviewAlluvial(studies, c("Design", "Outcome"), labels = "prop")
```

![](reference/figures/README-alluvial-1.png)

### Year trend

``` r

reviewTrend(studies, Design)
```

![](reference/figures/README-trend-1.png)

### World map

``` r

reviewMap(studies)
```

![](reference/figures/README-map-1.png)

### Treemap

``` r

reviewTreemap(studies, Design)
```

![](reference/figures/README-treemap-1.png)

``` r

reviewTreemap(studies, Intervention, color_by = InterventionType)
```

![](reference/figures/README-treemap-color-1.png)

### Summary table

``` r

reviewTable(studies, Design, study_id = "Author")
```

![](reference/figures/README-table-1.png)

### Handling missing data

``` r

df_na <- data.frame(
  StudyID = paste0("S", 1:8),
  Design  = c("RCT", "Cohort", NA, "RCT", "Case-control", NA, "RCT", "Cohort"),
  stringsAsFactors = FALSE
)
reviewBar(df_na, Design, na.rm = FALSE, na_label = "Missing", na_last = TRUE)
```

![](reference/figures/README-na-1.png)
