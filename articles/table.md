# Summary tables

``` r

library(litReview)
data(studies)
```

[`reviewTable()`](https://sonsoles.me/litReview/reference/reviewTable.md)
summarizes a single column as a formatted table listing each category,
its contributing studies, frequency, and percentage. It returns a
[`gt`](https://gt.rstudio.com) object that renders inline in HTML and
can be exported to LaTeX. This article walks through **every argument**
of

``` r

reviewTable(data, col, sep = "\r\n", study_id = StudyID, latex = FALSE,
            cite = FALSE, na.rm = TRUE, na_label = "Not reported",
            na_in_percent = TRUE, na_last = FALSE)
```

## Default

Pass the data frame and a column. Column names may be bare or quoted.
Each row is a distinct category, with its contributing study IDs, count,
and percentage.

``` r

reviewTable(studies, Design)
```

| Design | Studies | Frequency | Percent |
|----|----|----|----|
| RCT | S06, S17, S20, S21, S22, S24, S28, S32, S37, S39, S45 | 11 | 22% |
| Qualitative | S01, S03, S08, S18, S33, S35, S38, S43, S49 | 9 | 18% |
| Mixed methods | S05, S50 | 2 | 4% |
| Cross-sectional | S04, S07, S09, S10, S11, S14, S19, S30, S34, S42, S44, S48 | 12 | 24% |
| Cohort | S02, S12, S15, S16, S25, S26, S29, S31, S40, S41, S46, S47 | 12 | 24% |
| Case-control | S13, S23, S27, S36 | 4 | 8% |

## `col`: the column to summarize

Any categorical column works. Multi-value columns (cells holding several
values) are split first — see [`sep`](#sep-multi-value-separator) below.
`Outcome` stores several outcomes per study, so each value is counted
independently and its study list is the union of studies reporting it:

``` r

reviewTable(studies, Outcome)
```

| Outcome | Studies | Frequency | Percent |
|----|----|----|----|
| Quality of life | S02, S03, S04, S06, S07, S10, S11, S13, S15, S16, S18, S19, S21, S22, S23, S25, S26, S27, S28, S31, S34, S35, S38, S39, S41, S43, S44, S48, S49, S50 | 30 | 60% |
| Pain | S04, S05, S07, S08, S09, S10, S13, S14, S16, S17, S18, S20, S22, S23, S25, S26, S27, S28, S29, S31, S32, S38, S39, S40, S42, S43, S47, S48, S49 | 29 | 58% |
| Function | S01, S04, S06, S07, S08, S09, S10, S12, S13, S14, S17, S18, S23, S24, S25, S28, S29, S30, S31, S33, S36, S37, S38, S40, S42, S44, S45, S46, S49 | 29 | 58% |

## `sep`: multi-value separator

Multi-value cells are split on `sep` before counting. In `studies`,
`Outcome` uses newline separators (`"\r\n"`, the default). If your data
uses a different delimiter, set `sep`. Here we rebuild a
semicolon-separated column to demonstrate:

``` r

studies_semi <- studies
studies_semi$Outcome <- gsub("\r\n", "; ", studies_semi$Outcome)
reviewTable(studies_semi, Outcome, sep = "; ")
```

| Outcome | Studies | Frequency | Percent |
|----|----|----|----|
| Quality of life | S02, S03, S11, S15, S19, S21, S34, S35, S41, S50 | 10 | 20% |
| Pain Quality of life | S16, S22, S26, S27, S39, S43, S48 | 7 | 14% |
| Pain Function Quality of life | S04, S07, S10, S13, S18, S23, S25, S28, S31, S38, S49 | 11 | 22% |
| Pain Function | S08, S09, S14, S17, S29, S40, S42 | 7 | 14% |
| Pain | S05, S20, S32, S47 | 4 | 8% |
| Function Quality of life | S06, S44 | 2 | 4% |
| Function | S01, S12, S24, S30, S33, S36, S37, S45, S46 | 9 | 18% |

## `study_id`: which column lists the contributing studies

By default the studies column is filled from `StudyID`. Point `study_id`
at any other identifier column to list studies differently — here, by
author:

``` r

reviewTable(studies, Design, study_id = Author)
```

| Design | Studies | Frequency | Percent |
|----|----|----|----|
| RCT | Kim et al., Brown et al., Johansson et al., Santos et al., Park et al., Dubois et al., Tanaka et al., Nguyen et al., Takahashi et al., Reyes et al., Larsen et al. | 11 | 22% |
| Qualitative | Garcia et al., Mueller et al., Novak et al., Petrov et al., Schmidt et al., Eriksson et al., Popov et al., Torres et al., Sato et al. | 9 | 18% |
| Mixed methods | Johnson et al., Berg et al. | 2 | 4% |
| Cross-sectional | Patel et al., Silva et al., Ahmed et al., Taylor et al., Rossi et al., Okafor et al., Hassan et al., Olsen et al., Khan et al., Fischer et al., Nakamura et al., Kowalski et al. | 12 | 24% |
| Cohort | Chen et al., Yamamoto et al., Martinez et al., Li et al., Gupta et al., OBrien et al., Ivanov et al., Costa et al., Muller et al., Ali et al., Diaz et al., Suzuki et al. | 12 | 24% |
| Case-control | Andersen et al., Williams et al., Fernandez et al., Morales et al. | 4 | 8% |

## `latex`: emit LaTeX instead of a gt table

With `latex = TRUE`,
[`reviewTable()`](https://sonsoles.me/litReview/reference/reviewTable.md)
returns a LaTeX representation of the table (via
[`gt::as_latex()`](https://gt.rstudio.com/reference/as_latex.html))
rather than an HTML `gt` object. The result is a character string of
class `litreview_latex`; in a knitted document it is emitted verbatim.
Below we show the generated LaTeX source as text so it is visible in
this HTML article:

``` r

tex <- reviewTable(studies, Design, latex = TRUE)
cat("```latex", tex, "```", sep = "\n")
```

``` latex
\begin{table}[t]
\fontsize{12.0pt}{14.0pt}\selectfont
\begin{tabular*}{\linewidth}{@{\extracolsep{\fill}}llrr}
\toprule
Design & Studies & Frequency & Percent \\ 
\midrule\addlinespace[2.5pt]
RCT & S06, S17, S20, S21, S22, S24, S28, S32, S37, S39, S45 & 11 & 22\% \\ 
Qualitative & S01, S03, S08, S18, S33, S35, S38, S43, S49 & 9 & 18\% \\ 
Mixed methods & S05, S50 & 2 & 4\% \\ 
Cross-sectional & S04, S07, S09, S10, S11, S14, S19, S30, S34, S42, S44, S48 & 12 & 24\% \\ 
Cohort & S02, S12, S15, S16, S25, S26, S29, S31, S40, S41, S46, S47 & 12 & 24\% \\ 
Case-control & S13, S23, S27, S36 & 4 & 8\% \\ 
\bottomrule
\end{tabular*}
\end{table}
```

Drop that block into a `.tex` document (it requires the `booktabs`
package) to typeset the table.

## `cite`: render studies as `\cite{}` keys

`cite = TRUE` treats the `study_id` values as BibTeX citation keys and
wraps each row’s study list in a single `\cite{...}` command — ideal for
a manuscript. It is most useful with `study_id = bibKey` (the dataset’s
BibTeX keys) and `latex = TRUE`:

``` r

tex <- reviewTable(studies, Design, study_id = bibKey,
                   latex = TRUE, cite = TRUE)
cat("```latex", tex, "```", sep = "\n")
```

``` latex
\begin{table}[t]
\fontsize{12.0pt}{14.0pt}\selectfont
\begin{tabular*}{\linewidth}{@{\extracolsep{\fill}}llrr}
\toprule
Design & Studies & Frequency & Percent \\ 
\midrule\addlinespace[2.5pt]
RCT & \cite{author6_2021,author17_2019,author20_2020,author21_2018,author22_2018,author24_2021,author28_2022,author32_2020,author37_2020,author39_2023,author45_2022} & 11 & 22\% \\ 
Qualitative & \cite{author1_2018,author3_2018,author8_2019,author18_2019,author33_2019,author35_2019,author38_2024,author43_2023,author49_2019} & 9 & 18\% \\ 
Mixed methods & \cite{author5_2019,author50_2019} & 2 & 4\% \\ 
Cross-sectional & \cite{author4_2018,author7_2019,author9_2018,author10_2024,author11_2024,author14_2022,author19_2024,author30_2019,author34_2018,author42_2021,author44_2019,author48_2021} & 12 & 24\% \\ 
Cohort & \cite{author2_2022,author12_2021,author15_2023,author16_2021,author25_2022,author26_2024,author29_2021,author31_2021,author40_2019,author41_2021,author46_2021,author47_2022} & 12 & 24\% \\ 
Case-control & \cite{author13_2018,author23_2020,author27_2022,author36_2023} & 4 & 8\% \\ 
\bottomrule
\end{tabular*}
\end{table}
```

Each `Studies` cell now holds `\cite{author6_2021,author17_2019,...}`,
which resolves against your `.bib` file at compile time.

## Embedding in a LaTeX or R Markdown document

When your document compiles to PDF — an `.Rnw` (Sweave) file, or an R
Markdown document with a LaTeX/PDF output format — call
`reviewTable(..., latex = TRUE)` in a chunk and the table typesets in
place. The returned object carries a `knit_print` method that emits the
LaTeX verbatim, so no extra chunk options are needed; in Sweave, the
chunk option `results = "asis"` achieves the same.

``` r

reviewTable(studies, Design, study_id = bibKey, latex = TRUE, cite = TRUE)
```

That call expands to a complete `table` environment (`\begin{table}` …
`\end{table}`) — the same source shown under
[`latex`](#latex-emit-latex-instead-of-a-gt-table) and
[`cite`](#cite-render-studies-as-cite-keys) above. Two preamble
requirements:

- The rules use **booktabs** (`\toprule`, `\midrule`, `\bottomrule`), so
  load `\usepackage{booktabs}`.
- With `cite = TRUE`, load a citation package (`\usepackage{natbib}` or
  `\usepackage{biblatex}`) and make sure the keys in your `study_id`
  column exist in the bibliography, so each `\cite{...}` resolves at
  compile time.

If your citation keys live in a column other than `StudyID`, point
`study_id` at it — for example `study_id = bibKey` above, or any custom
key column:

``` r

refs <- data.frame(
  RefKey = c("smith2020", "doe2019", "lee2021", "smith2020"),
  Design = c("RCT", "Cohort", "RCT", "Case-control"),
  stringsAsFactors = FALSE
)
tex <- reviewTable(refs, Design, study_id = RefKey, latex = TRUE, cite = TRUE)
cat("```latex", tex, "```", sep = "\n")
```

``` latex
\begin{table}[t]
\fontsize{12.0pt}{14.0pt}\selectfont
\begin{tabular*}{\linewidth}{@{\extracolsep{\fill}}llrr}
\toprule
Design & Studies & Frequency & Percent \\ 
\midrule\addlinespace[2.5pt]
RCT & \cite{smith2020,lee2021} & 2 & 50\% \\ 
Cohort & \cite{doe2019} & 1 & 25\% \\ 
Case-control & \cite{smith2020} & 1 & 25\% \\ 
\bottomrule
\end{tabular*}
\end{table}
```

## Missing data: `na.rm`, `na_label`, `na_in_percent`, `na_last`

These four arguments control how `NA` (and empty) cells are treated. We
use a column that actually has missing values — `FundingSource`.

### `na.rm`

By default `na.rm = TRUE` drops missing rows, but the percentage
denominator is still the full sample, so the shown percentages need not
sum to 100%:

``` r

reviewTable(studies, FundingSource)
```

| FundingSource | Studies | Frequency | Percent |
|----|----|----|----|
| University | S03, S12, S16, S20, S23, S29 | 6 | 12% |
| None | S02, S05, S15, S19, S25, S34, S35, S40, S43, S45 | 10 | 20% |
| Industry | S06, S09, S14, S17, S27, S31, S38, S48, S49 | 9 | 18% |
| Government | S07, S13, S24, S28, S32, S36, S37, S42, S47, S50 | 10 | 20% |
| Foundation | S04, S10, S11, S18 | 4 | 8% |

Set `na.rm = FALSE` to keep the missing rows as their own category:

``` r

reviewTable(studies, FundingSource, na.rm = FALSE)
```

| FundingSource | Studies | Frequency | Percent |
|----|----|----|----|
| University | S03, S12, S16, S20, S23, S29 | 6 | 12% |
| Not reported | S01, S08, S21, S22, S26, S30, S33, S39, S41, S44, S46 | 11 | 22% |
| None | S02, S05, S15, S19, S25, S34, S35, S40, S43, S45 | 10 | 20% |
| Industry | S06, S09, S14, S17, S27, S31, S38, S48, S49 | 9 | 18% |
| Government | S07, S13, S24, S28, S32, S36, S37, S42, S47, S50 | 10 | 20% |
| Foundation | S04, S10, S11, S18 | 4 | 8% |

### `na_label`

When missing rows are kept, `na_label` names that category (default
`"Not reported"`):

``` r

reviewTable(studies, FundingSource, na.rm = FALSE, na_label = "Unspecified")
```

| FundingSource | Studies | Frequency | Percent |
|----|----|----|----|
| Unspecified | S01, S08, S21, S22, S26, S30, S33, S39, S41, S44, S46 | 11 | 22% |
| University | S03, S12, S16, S20, S23, S29 | 6 | 12% |
| None | S02, S05, S15, S19, S25, S34, S35, S40, S43, S45 | 10 | 20% |
| Industry | S06, S09, S14, S17, S27, S31, S38, S48, S49 | 9 | 18% |
| Government | S07, S13, S24, S28, S32, S36, S37, S42, S47, S50 | 10 | 20% |
| Foundation | S04, S10, S11, S18 | 4 | 8% |

### `na_in_percent`

With `na_in_percent = FALSE` the denominator excludes missing rows, so
the reported categories sum to 100%:

``` r

reviewTable(studies, FundingSource, na.rm = FALSE, na_in_percent = FALSE)
```

| FundingSource | Studies | Frequency | Percent |
|----|----|----|----|
| University | S03, S12, S16, S20, S23, S29 | 6 | 15.4% |
| Not reported | S01, S08, S21, S22, S26, S30, S33, S39, S41, S44, S46 | 11 | 28.2% |
| None | S02, S05, S15, S19, S25, S34, S35, S40, S43, S45 | 10 | 25.6% |
| Industry | S06, S09, S14, S17, S27, S31, S38, S48, S49 | 9 | 23.1% |
| Government | S07, S13, S24, S28, S32, S36, S37, S42, S47, S50 | 10 | 25.6% |
| Foundation | S04, S10, S11, S18 | 4 | 10.3% |

### `na_last`

`na_last = TRUE` forces the missing-value row to the end of the table
regardless of its frequency:

``` r

reviewTable(studies, FundingSource, na.rm = FALSE, na_last = TRUE)
```

| FundingSource | Studies | Frequency | Percent |
|----|----|----|----|
| University | S03, S12, S16, S20, S23, S29 | 6 | 12% |
| Not reported | S01, S08, S21, S22, S26, S30, S33, S39, S41, S44, S46 | 11 | 22% |
| None | S02, S05, S15, S19, S25, S34, S35, S40, S43, S45 | 10 | 20% |
| Industry | S06, S09, S14, S17, S27, S31, S38, S48, S49 | 9 | 18% |
| Government | S07, S13, S24, S28, S32, S36, S37, S42, S47, S50 | 10 | 20% |
| Foundation | S04, S10, S11, S18 | 4 | 8% |

## Notes

[`reviewTable()`](https://sonsoles.me/litReview/reference/reviewTable.md)
returns a [`gt`](https://gt.rstudio.com) object (or, with
`latex = TRUE`, a LaTeX character string). Because the default result is
a plain `gt` table, you can pipe it into any `gt` styling verb —
[`gt::tab_header()`](https://gt.rstudio.com/reference/tab_header.html),
[`gt::cols_label()`](https://gt.rstudio.com/reference/cols_label.html),
[`gt::opt_stylize()`](https://gt.rstudio.com/reference/opt_stylize.html),
and so on — before printing, or export it with
[`gt::gtsave()`](https://gt.rstudio.com/reference/gtsave.html) and
[`gt::as_latex()`](https://gt.rstudio.com/reference/as_latex.html).
