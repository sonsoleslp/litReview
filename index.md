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

| Design | Studies | Frequency | Percent |
|----|----|----|----|
| RCT | Kim et al., Brown et al., Johansson et al., Santos et al., Park et al., Dubois et al., Tanaka et al., Nguyen et al., Takahashi et al., Reyes et al., Larsen et al. | 11 | 22% |
| Qualitative | Garcia et al., Mueller et al., Novak et al., Petrov et al., Schmidt et al., Eriksson et al., Popov et al., Torres et al., Sato et al. | 9 | 18% |
| Mixed methods | Johnson et al., Berg et al. | 2 | 4% |
| Cross-sectional | Patel et al., Silva et al., Ahmed et al., Taylor et al., Rossi et al., Okafor et al., Hassan et al., Olsen et al., Khan et al., Fischer et al., Nakamura et al., Kowalski et al. | 12 | 24% |
| Cohort | Chen et al., Yamamoto et al., Martinez et al., Li et al., Gupta et al., OBrien et al., Ivanov et al., Costa et al., Muller et al., Ali et al., Diaz et al., Suzuki et al. | 12 | 24% |
| Case-control | Andersen et al., Williams et al., Fernandez et al., Morales et al. | 4 | 8% |

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
