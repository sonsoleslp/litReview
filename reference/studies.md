# Example Literature Review Dataset

A synthetic dataset of 50 fictional studies for demonstrating the
plotting functions in litReview. Contains 18 columns covering common
fields extracted during a literature review.

## Usage

``` r
studies
```

## Format

A data frame with 50 rows and 18 variables:

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

## Examples

``` r
data(studies)
reviewBar(studies, Design)
```
