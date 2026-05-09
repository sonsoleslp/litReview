# Exporting Review Tables to LaTeX

## Overview

[`reviewTable()`](https://sonsoles.me/litReview/reference/reviewTable.md)
can return a LaTeX representation of the summary table for inclusion in
a manuscript. Two arguments control the LaTeX workflow:

- `latex = TRUE` returns the table as LaTeX code instead of a `gt`
  object.
- `cite = TRUE` treats values in the study ID column as BibTeX reference
  keys and wraps each row’s study list in `\cite{...}`, so citations
  render correctly when the document is compiled.

``` r

library(litReview)
data(studies)
```

## Plain LaTeX output

Pass `latex = TRUE` to get LaTeX code:

``` r

reviewTable(studies, Design, latex = TRUE)
```

## Study IDs as BibTeX keys

If `StudyID` matches the keys in your `.bib` file (e.g. `smith2020`,
`doe2019`), set `cite = TRUE` so the `Studies` column is wrapped in
`\cite{...}`:

``` r

reviewTable(studies, Design, latex = TRUE, cite = TRUE)
```

The `cite` flag also works without `latex = TRUE` if you want a `gt`
preview of the cited form:

``` r

reviewTable(studies, Design, cite = TRUE, study_id = "bibKey")
```

| Design | Studies | Frequency | Percent |
|----|----|----|----|
| RCT | \cite{author6_2021,author17_2019,author20_2020,author21_2018,author22_2018,author24_2021,author28_2022,author32_2020,author37_2020,author39_2023,author45_2022} | 11 | 22% |
| Qualitative | \cite{author1_2018,author3_2018,author8_2019,author18_2019,author33_2019,author35_2019,author38_2024,author43_2023,author49_2019} | 9 | 18% |
| Mixed methods | \cite{author5_2019,author50_2019} | 2 | 4% |
| Cross-sectional | \cite{author4_2018,author7_2019,author9_2018,author10_2024,author11_2024,author14_2022,author19_2024,author30_2019,author34_2018,author42_2021,author44_2019,author48_2021} | 12 | 24% |
| Cohort | \cite{author2_2022,author12_2021,author15_2023,author16_2021,author25_2022,author26_2024,author29_2021,author31_2021,author40_2019,author41_2021,author46_2021,author47_2022} | 12 | 24% |
| Case-control | \cite{author13_2018,author23_2020,author27_2022,author36_2023} | 4 | 8% |

## Embedding in a LaTeX or R Markdown document

In an `.Rnw` (Sweave) or LaTeX-output R Markdown file, use
`results = "asis"` so the LaTeX code is emitted verbatim:

``` r

reviewTable(studies, Design, latex = TRUE, cite = TRUE)
```

    \begin{table}[t]
    \fontsize{12.0pt}{14.0pt}\selectfont
    \begin{tabular*}{\linewidth}{@{\extracolsep{\fill}}llrr}
    \toprule
    Design & Studies & Frequency & Percent \\ 
    \midrule\addlinespace[2.5pt]
    RCT & \cite{S06,S17,S20,S21,S22,S24,S28,S32,S37,S39,S45} & 11 & 22\% \\ 
    Qualitative & \cite{S01,S03,S08,S18,S33,S35,S38,S43,S49} & 9 & 18\% \\ 
    Mixed methods & \cite{S05,S50} & 2 & 4\% \\ 
    Cross-sectional & \cite{S04,S07,S09,S10,S11,S14,S19,S30,S34,S42,S44,S48} & 12 & 24\% \\ 
    Cohort & \cite{S02,S12,S15,S16,S25,S26,S29,S31,S40,S41,S46,S47} & 12 & 24\% \\ 
    Case-control & \cite{S13,S23,S27,S36} & 4 & 8\% \\ 
    \bottomrule
    \end{tabular*}
    \end{table}

Make sure your preamble loads a citation package
(e.g. `\usepackage{natbib}` or `\usepackage{biblatex}`) and that the
keys used in `StudyID` exist in the bibliography.

## Custom ID column

If your study IDs live in a column other than `StudyID`, pass it via
`study_id`:

``` r

df <- data.frame(
  RefKey = c("smith2020", "doe2019", "lee2021", "smith2020"),
  Design = c("RCT", "Cohort", "RCT", "Case-control"),
  stringsAsFactors = FALSE
)
reviewTable(df, Design, study_id = RefKey, latex = TRUE, cite = TRUE)
```
