#' Example Literature Review Dataset
#'
#' A synthetic dataset of 50 fictional studies for demonstrating the
#' plotting functions in \pkg{litReview}. Contains 18 columns covering
#' common fields extracted during a literature review.
#'
#' @format A data frame with 50 rows and 18 variables:
#' \describe{
#'   \item{StudyID}{Unique study identifier (S01--S50).}
#'   \item{bibKey}{BibTeX citation key.}
#'   \item{Author}{Author list (e.g. "Garcia et al.").}
#'   \item{Year}{Publication year (2018--2024).}
#'   \item{Reference}{Full reference string.}
#'   \item{Country}{Country or countries where the study was conducted.
#'     Multi-value cells are separated by newlines.}
#'   \item{Design}{Study design (e.g. RCT, Cohort, Cross-sectional).}
#'   \item{SampleSize}{Number of participants.}
#'   \item{FollowUpWeeks}{Follow-up duration in weeks, or \code{NA}.}
#'   \item{AgeGroup}{Target age group. May contain multiple values.}
#'   \item{Setting}{Study setting (e.g. Hospital, Community, Online).}
#'   \item{Intervention}{Intervention type (e.g. CBT, Exercise). May
#'     contain multiple values.}
#'   \item{Outcome}{Reported outcome (e.g. Pain, Function). May contain
#'     multiple values.}
#'   \item{AnalysisApproach}{Statistical or analytical approach used.}
#'   \item{RiskOfBias}{Risk of bias rating (Low, Moderate, High, or \code{NA}).}
#'   \item{FundingSource}{Funding source, or \code{NA}.}
#'   \item{OpenAccess}{Whether the study is open access (Yes, No, or \code{NA}).}
#'   \item{InterventionType}{Higher-order grouping of \code{Intervention}
#'     (Behavioral, Educational, Physical, Medical, Multimodal).}
#' }
#'
#' @examples
#' data(studies)
#' reviewBar(studies, Design)
"studies"
