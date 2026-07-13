# Example Literature Review Dataset

A synthetic dataset of 50 fictional studies for demonstrating the
plotting functions in litReview. Contains 27 columns covering common
fields extracted during a literature review, including a block of
methodological reporting criteria suitable for
[`reviewMatrix()`](https://sonsoles.me/litReview/reference/reviewMatrix.md).

## Usage

``` r
studies
```

## Format

A data frame with 50 rows and 27 variables:

- StudyID:

  Unique study identifier (S01–S50).

- bibKey:

  BibTeX citation key.

- Author:

  Author list (e.g. "Garcia et al.").

- Year:

  Publication year (2018–2024).

- Reference:

  Full reference string.

- Country:

  Country or countries where the study was conducted. Multi-value cells
  are separated by newlines.

- Design:

  Study design (e.g. RCT, Cohort, Cross-sectional).

- SampleSize:

  Number of participants.

- FollowUpWeeks:

  Follow-up duration in weeks, or `NA`.

- AgeGroup:

  Target age group. May contain multiple values.

- Setting:

  Study setting (e.g. Hospital, Community, Online).

- Intervention:

  Intervention type (e.g. CBT, Exercise). May contain multiple values.

- Outcome:

  Reported outcome (e.g. Pain, Function). May contain multiple values.

- AnalysisApproach:

  Statistical or analytical approach used.

- RiskOfBias:

  Risk of bias rating (Low, Moderate, High, or `NA`).

- FundingSource:

  Funding source, or `NA`.

- OpenAccess:

  Whether the study is open access (Yes, No, or `NA`).

- InterventionType:

  Higher-order grouping of `Intervention` (Behavioral, Educational,
  Physical, Medical, Multimodal).

- PubType:

  Publication type (Journal, Conference, Preprint, Report).

- Randomization:

  Reporting of randomization. Coded `"F"` (full), `"P"` (partial), `"M"`
  (mentioned), or `NA` (not addressed). Trial-only item: `NA` for
  non-RCT designs.

- Blinding:

  Reporting of blinding, coded as `Randomization`. Trial-only item: `NA`
  for non-RCT designs.

- SampleJustification:

  Reporting of sample-size justification, coded `"F"`/`"P"`/`"M"`/`NA`.

- AttritionReported:

  Reporting of attrition/dropout, coded as above.

- EthicsApproval:

  Reporting of ethics approval, coded as above.

- Preregistration:

  Reporting of preregistration, coded as above.

- EffectSize:

  Reporting of effect sizes, coded as above.

- LimitationsDiscussed:

  Reporting of study limitations, coded as above.

## Details

The reporting-criteria columns (`Randomization` through
`LimitationsDiscussed`) are coded for how fully each study reports the
item — `"F"` full, `"P"` partial, `"M"` only mentioned, or `NA` not
addressed — and are designed for the study-by-criteria
[`reviewMatrix()`](https://sonsoles.me/litReview/reference/reviewMatrix.md)
plot.

## Examples

``` r
data(studies)
reviewBar(studies, Design)


# Reporting-criteria matrix
criteria <- c("Randomization", "Blinding", "SampleJustification",
              "AttritionReported", "EthicsApproval", "Preregistration",
              "EffectSize", "LimitationsDiscussed")
reviewMatrix(studies, criteria, color_by = "PubType",
             levels = c(F = "Full", P = "Partial", M = "Mention"))
```
