## Adds reporting-criteria columns to the bundled `studies` dataset so the
## study-by-criteria matrix (reviewMatrix()) can be demonstrated on real data.
##
## Derives the new columns from the existing data/studies.rda (50 rows) and
## re-saves it. Reproducible: run with the package root as the working dir.
##
##   Rscript data-raw/add_matrix_columns.R
##
## New columns
##   PubType  — publication type (Journal / Conference / Preprint / Report),
##              a good `color_by` for reviewMatrix().
##   Eight methodological *reporting criteria*, each coded for how fully the
##   study reports that item:  "F" full, "P" partial, "M" only mentioned,
##   NA not addressed.  Randomization/Blinding apply to trials only, so they
##   are NA for non-RCT designs; completeness correlates with RiskOfBias.

load(file.path("data", "studies.rda"))       # -> studies (50 x 18)
set.seed(2024)
n <- nrow(studies)

studies$PubType <- sample(
  c("Journal", "Conference", "Preprint", "Report"),
  n, replace = TRUE, prob = c(0.62, 0.22, 0.10, 0.06)
)

criteria <- c("Randomization", "Blinding", "SampleJustification",
              "AttritionReported", "EthicsApproval", "Preregistration",
              "EffectSize", "LimitationsDiscussed")

# Probability each criterion is addressed at all
addressed_p <- c(Randomization = 0.90, Blinding = 0.70, SampleJustification = 0.72,
                 AttritionReported = 0.75, EthicsApproval = 0.92,
                 Preregistration = 0.45, EffectSize = 0.80,
                 LimitationsDiscussed = 0.95)

# Lower risk of bias -> fuller reporting
rob_shift <- c(Low = 0.22, Moderate = 0, High = -0.22)

code_for <- function(rob, addr_p) {
  if (stats::runif(1) > addr_p) return(NA_character_)
  s <- if (is.na(rob) || !rob %in% names(rob_shift)) 0 else rob_shift[[rob]]
  p <- c(F = 0.40 + s, P = 0.40, M = 0.20 - s)
  p[p < 0.02] <- 0.02
  sample(c("F", "P", "M"), 1, prob = p)
}

for (cc in criteria) {
  studies[[cc]] <- vapply(seq_len(n), function(i) {
    # Randomization / Blinding are meaningful only for trials
    if (cc %in% c("Randomization", "Blinding") && studies$Design[i] != "RCT")
      return(NA_character_)
    code_for(studies$RiskOfBias[i], addressed_p[[cc]])
  }, character(1))
}

stopifnot(nrow(studies) == 50L, all(criteria %in% names(studies)),
          "PubType" %in% names(studies))

save(studies, file = file.path("data", "studies.rda"), version = 2)
if (requireNamespace("tools", quietly = TRUE))
  tools::resaveRdaFiles(file.path("data", "studies.rda"), compress = "xz")
message("Updated data/studies.rda -> ", nrow(studies), " rows, ",
        ncol(studies), " cols")
