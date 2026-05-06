## Generates inst/extdata/example_studies.xlsx
##
## A fictional dataset for demonstrating the litReview package.
## Studies, authors, journals, DOIs, and findings are synthetic and
## designed only to exercise the package's visualizations.

# Multi-value cells use "\r\n" (Excel's in-cell newline) so the package
# defaults (sep = "\r\n") work without extra arguments.
nl <- "\r\n"

studies <- data.frame(
  StudyID = sprintf("S%02d", 1:25),

  bibKey = c(
    "Garcia2021",      "Chen2022",        "Muller2020",
    "Patel2023",       "Johnson2021",     "Kim2022",
    "Rossi2019",       "Nakamura2023",    "Silva2020",
    "OConnor2024",     "Andersson2018",   "Martin2022",
    "Tanaka2021",      "vanderLinden2023","Okafor2024",
    "Hassan2019",      "Petrov2020",      "Dubois2022",
    "Smith2023",       "Yamamoto2024",    "Ali2021",
    "Costa2020",       "Wagner2022",      "Hernandez2024",
    "Park2023"
  ),

  Author = c(
    "Garcia et al.",          "Chen & Lee",            "Müller et al.",
    "Patel et al.",           "Johnson et al.",        "Kim et al.",
    "Rossi et al.",           "Nakamura et al.",       "Silva et al.",
    "O'Connor et al.",        "Andersson & Berg",      "Martín et al.",
    "Tanaka et al.",          "van der Linden et al.", "Okafor et al.",
    "Hassan et al.",          "Petrov & Ivanov",       "Dubois et al.",
    "Smith et al.",           "Yamamoto & Sato",       "Ali et al.",
    "Costa et al.",           "Wagner et al.",         "Hernández et al.",
    "Park et al."
  ),

  Year = c(
    2021, 2022, 2020, 2023, 2021, 2022, 2019, 2023, 2020, 2024,
    2018, 2022, 2021, 2023, 2024, 2019, 2020, 2022, 2023, 2024,
    2021, 2020, 2022, 2024, 2023
  ),

  Reference = c(
    "Garcia, M., López, A., & Romero, J. (2021). Group cognitive behavioural therapy for chronic low back pain: A randomised controlled trial. Pain Medicine, 22(4), 812-823. https://doi.org/10.1093/pm/pnab001",
    "Chen, H., & Lee, S. (2022). A prospective cohort study of mindfulness-based stress reduction in adults with fibromyalgia. Journal of Pain Research, 15, 1123-1135. https://doi.org/10.2147/JPR.S350001",
    "Müller, K., Weber, T., & Schmidt, F. (2020). Cross-sectional survey of pain management practices in European primary care. European Journal of Pain, 24(7), 1304-1316. https://doi.org/10.1002/ejp.1551",
    "Patel, R., Sharma, V., & Iyer, N. (2023). Yoga-based intervention for chronic neck pain: A randomised controlled trial in urban India. BMJ Open, 13(2), e066345. https://doi.org/10.1136/bmjopen-2022-066345",
    "Johnson, L., Brown, P., & Davis, T. (2021). Risk factors for opioid misuse in patients with chronic pain: A case-control study. Journal of General Internal Medicine, 36(9), 2645-2652. https://doi.org/10.1007/s11606-021-06721-9",
    "Kim, J., Park, S., & Choi, M. (2022). Wearable-based activity tracking and chronic pain outcomes: A 12-month cohort. Digital Health, 8, 1-14. https://doi.org/10.1177/20552076221101045",
    "Rossi, E., Bianchi, G., & Conti, P. (2019). Patient experiences of multidisciplinary pain clinics: A qualitative interview study. Pain Reports, 4(5), e776. https://doi.org/10.1097/PR9.0000000000000776",
    "Nakamura, Y., Sato, K., & Watanabe, R. (2023). Mixed-methods evaluation of a school-based pain education programme for adolescents. Journal of Adolescent Health, 72(6), 945-953. https://doi.org/10.1016/j.jadohealth.2023.01.022",
    "Silva, P., Almeida, R., & Costa, M. (2020). Hydrotherapy compared with land-based exercise for knee osteoarthritis: A pragmatic RCT. Physiotherapy, 108, 60-69. https://doi.org/10.1016/j.physio.2020.04.006",
    "O'Connor, B., Murphy, K., & Walsh, D. (2024). Telehealth-delivered cognitive behavioural therapy for chronic pain: A randomised controlled trial. The Lancet Digital Health, 6(3), e180-e190. https://doi.org/10.1016/S2589-7500(23)00250-3",
    "Andersson, J., & Berg, L. (2018). Long-term follow-up of multidisciplinary pain rehabilitation: A 5-year cohort. Scandinavian Journal of Pain, 18(3), 411-420. https://doi.org/10.1515/sjpain-2018-0032",
    "Martín, C., Fernández, P., & Ruiz, A. (2022). Cross-sectional analysis of pain catastrophising in older adults across four Spanish regions. Aging & Mental Health, 26(11), 2233-2241. https://doi.org/10.1080/13607863.2021.2007365",
    "Tanaka, H., Mori, A., & Yoshida, K. (2021). Acceptance and commitment therapy for chronic pain in older adults: A pilot RCT. Geriatrics & Gerontology International, 21(8), 712-719. https://doi.org/10.1111/ggi.14225",
    "van der Linden, M., Jansen, P., & de Vries, H. (2023). A multinational cohort of paediatric chronic pain: Predictors of disability at 12 months. Pain, 164(5), 1102-1112. https://doi.org/10.1097/j.pain.0000000000002830",
    "Okafor, N., Adeyemi, T., & Ibrahim, F. (2024). Community-based exercise programmes for chronic pain in Sub-Saharan Africa: A mixed-methods feasibility study. Global Health Action, 17(1), 2301234. https://doi.org/10.1080/16549716.2024.2301234",
    "Hassan, A., El-Sayed, M., & Khalil, R. (2019). Pharmacological versus non-pharmacological pain management in tertiary care: A cross-sectional audit. Egyptian Journal of Anaesthesia, 35(4), 412-419. https://doi.org/10.1080/11101849.2019.1675001",
    "Petrov, D., & Ivanov, S. (2020). Risk factors for postoperative chronic pain: A nested case-control study. Anesthesiology, 132(6), 1380-1389. https://doi.org/10.1097/ALN.0000000000003251",
    "Dubois, A., Laurent, P., & Moreau, C. (2022). Mindfulness and exercise for fibromyalgia: A pragmatic RCT in primary care. Annals of Family Medicine, 20(4), 320-328. https://doi.org/10.1370/afm.2823",
    "Smith, J., Williams, R., & Taylor, K. (2023). Workplace ergonomic interventions for low back pain: A cluster RCT. Occupational and Environmental Medicine, 80(7), 401-408. https://doi.org/10.1136/oemed-2022-108645",
    "Yamamoto, S., & Sato, A. (2024). Patient and clinician perspectives on shared decision-making in chronic pain: A qualitative study. BMC Primary Care, 25, 88. https://doi.org/10.1186/s12875-024-02312-9",
    "Ali, S., Rahman, M., & Khan, T. (2021). Acupuncture for chronic tension-type headache: A randomised controlled trial. Cephalalgia, 41(9), 956-965. https://doi.org/10.1177/03331024211002012",
    "Costa, L., Pereira, J., & Santos, R. (2020). A cohort study of digital self-management tools for chronic pain in Portugal. Journal of Medical Internet Research, 22(11), e21345. https://doi.org/10.2196/21345",
    "Wagner, U., Becker, H., & Klein, M. (2022). Predictors of treatment response in interdisciplinary pain rehabilitation: A retrospective cohort. European Journal of Pain, 26(5), 1054-1066. https://doi.org/10.1002/ejp.1934",
    "Hernández, R., Ramos, V., & Castillo, D. (2024). Adolescent perspectives on living with chronic pain: A qualitative study in Mexico and Colombia. Pediatric Pain Letter, 26(1), 1-9.",
    "Park, J., Lee, H., & Kim, S. (2023). Virtual reality-based exposure therapy for chronic pain: A pilot randomised trial. Journal of Pain, 24(8), 1421-1433. https://doi.org/10.1016/j.jpain.2023.03.002"
  ),

  Country = c(
    "Spain", "China", "Germany", "India", "USA", "South Korea",
    "Italy", "Japan", "Brazil", "Ireland", "Sweden", "Spain",
    "Japan", paste("Netherlands", "Belgium", "Germany", sep = nl),
    paste("Nigeria", "Kenya", sep = nl), "Egypt", "Russia", "France",
    "United Kingdom", "Japan", "Pakistan", "Portugal", "Germany",
    paste("Mexico", "Colombia", sep = nl), "South Korea"
  ),

  Design = c(
    "RCT", "Cohort", "Cross-sectional", "RCT", "Case-control",
    "Cohort", "Qualitative", "Mixed methods", "RCT", "RCT",
    "Cohort", "Cross-sectional", "RCT", "Cohort", "Mixed methods",
    "Cross-sectional", "Case-control", "RCT", "RCT", "Qualitative",
    "RCT", "Cohort", "Cohort", "Qualitative", "RCT"
  ),

  SampleSize = c(
    120, 450, 200, 85, 310, 175, 24, 312, 140, 280,
    520, 612, 60, 1804, 96, 410, 220, 198, 1240, 32,
    156, 384, 712, 28, 74
  ),

  FollowUpWeeks = c(
    12, 52, NA, 24, NA, 52, NA, 16, 26, 12,
    260, NA, 8, 52, 12, NA, NA, 24, 26, NA,
    12, 36, NA, NA, 8
  ),

  AgeGroup = c(
    "Adults", "Adults", "Adults",
    "Adults", "Adults", "Adults",
    "Adults", "Adolescents",
    paste("Adults", "Older adults", sep = nl),
    "Adults", "Adults", "Older adults",
    "Older adults",
    paste("Children", "Adolescents", sep = nl),
    "Adults", "Adults", "Adults",
    paste("Adults", "Older adults", sep = nl),
    "Adults", "Adults", "Adults", "Adults",
    "Adults", "Adolescents", "Adults"
  ),

  Setting = c(
    "Hospital", "Primary care", "Primary care", "Community", "Hospital",
    "Community", "Hospital", "School", "Hospital", "Online",
    "Hospital", "Community", "Primary care", "Hospital", "Community",
    "Hospital", "Hospital", "Primary care", "Workplace", "Primary care",
    "Hospital", "Online", "Hospital", "Community", "Hospital"
  ),

  Intervention = c(
    "Cognitive behavioural therapy",
    "Mindfulness",
    "Observational (no intervention)",
    paste("Yoga", "Education", sep = nl),
    "Observational (no intervention)",
    paste("Exercise", "Digital self-management", sep = nl),
    "Observational (no intervention)",
    "Education",
    paste("Exercise", "Hydrotherapy", sep = nl),
    paste("Cognitive behavioural therapy", "Telehealth", sep = nl),
    paste("Cognitive behavioural therapy", "Exercise", "Pharmacological", sep = nl),
    "Observational (no intervention)",
    "Acceptance and commitment therapy",
    "Observational (no intervention)",
    paste("Exercise", "Education", sep = nl),
    "Observational (no intervention)",
    "Observational (no intervention)",
    paste("Mindfulness", "Exercise", sep = nl),
    paste("Ergonomic redesign", "Education", sep = nl),
    "Observational (no intervention)",
    "Acupuncture",
    "Digital self-management",
    paste("Cognitive behavioural therapy", "Exercise", "Pharmacological", sep = nl),
    "Observational (no intervention)",
    paste("Virtual reality", "Cognitive behavioural therapy", sep = nl)
  ),

  Outcome = c(
    paste("Pain", "Function", sep = nl),
    paste("Pain", "Quality of life", sep = nl),
    "Pain",
    paste("Function", "Quality of life", sep = nl),
    paste("Pain", "Function", "Quality of life", sep = nl),
    paste("Pain", "Function", sep = nl),
    "Quality of life",
    paste("Pain", "Function", sep = nl),
    paste("Pain", "Function", sep = nl),
    paste("Pain", "Quality of life", sep = nl),
    paste("Pain", "Function", "Quality of life", sep = nl),
    "Pain",
    paste("Pain", "Quality of life", sep = nl),
    paste("Function", "Quality of life", sep = nl),
    paste("Pain", "Function", "Quality of life", sep = nl),
    "Pain",
    "Pain",
    paste("Pain", "Function", sep = nl),
    paste("Pain", "Function", sep = nl),
    "Quality of life",
    "Pain",
    paste("Pain", "Function", sep = nl),
    paste("Pain", "Function", "Quality of life", sep = nl),
    "Quality of life",
    paste("Pain", "Function", sep = nl)
  ),

  AnalysisApproach = c(
    "Quantitative", "Quantitative", "Quantitative", "Quantitative",
    "Quantitative", "Quantitative", "Qualitative", "Mixed methods",
    "Quantitative", "Quantitative", "Quantitative", "Quantitative",
    "Quantitative", "Quantitative", "Mixed methods", "Quantitative",
    "Quantitative", "Quantitative", "Quantitative", "Qualitative",
    "Quantitative", "Quantitative", "Quantitative", "Qualitative",
    "Quantitative"
  ),

  RiskOfBias = c(
    "Low", "Moderate", "Moderate", "Low", "Moderate",
    "Moderate", "Moderate", "Low", "Low", "Low",
    "Moderate", "High", "Moderate", "Low", "Moderate",
    "High", "Moderate", "Low", "Low", "Moderate",
    "Low", "Moderate", "Moderate", "Moderate", "Moderate"
  ),

  FundingSource = c(
    "Public", "Mixed", "None reported", "Public", "Public",
    "Mixed", "Public", "Public", "Public", "Public",
    "Public", "None reported", "Public", "Public", "Public",
    "None reported", "Public", "Public", "Mixed", "None reported",
    "Public", "Private", "Public", "None reported", "Mixed"
  ),

  OpenAccess = c(
    "Yes", "Yes", "No", "Yes", "Yes", "Yes", "Yes", "No",
    "Yes", "Yes", "No", "No", "No", "Yes", "Yes", "No",
    "No", "Yes", "Yes", "Yes", "No", "Yes", "No", "No", "Yes"
  ),

  stringsAsFactors = FALSE
)

stopifnot(nrow(studies) == 25L)
stopifnot(!anyDuplicated(studies$StudyID))

out <- file.path("inst", "extdata", "example_studies.xlsx")
rio::export(studies, out)
message("Wrote ", out, " (", nrow(studies), " rows, ", ncol(studies), " cols)")
