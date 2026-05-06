# ---- test data with various NA patterns ------------------------------------

# Single-value column with R NAs
df_na <- data.frame(
  StudyID = paste0("S", 1:10),
  Design  = c("RCT", "Cohort", NA, "RCT", "Case-control",
              NA, "RCT", "Cohort", NA, "RCT"),
  Year    = c(2020, 2021, 2021, 2022, 2022, 2020, 2021, 2022, 2023, 2023),
  Country = c("Spain", NA, "UK", "Germany", NA,
              "Spain", "UK", NA, "Germany", "Spain"),
  stringsAsFactors = FALSE
)

# Multi-value column with NAs
df_multi_na <- data.frame(
  StudyID = paste0("S", 1:6),
  Outcome = c("Pain\r\nFunction", NA, "Pain", "", "Function\r\nQoL", NA),
  stringsAsFactors = FALSE
)

# All NAs
df_all_na <- data.frame(
  StudyID = c("S1", "S2", "S3"),
  Design  = c(NA_character_, NA_character_, NA_character_),
  stringsAsFactors = FALSE
)

# Empty strings and whitespace
df_empty <- data.frame(
  StudyID = paste0("S", 1:5),
  Design  = c("RCT", "", "  ", "Cohort", NA),
  stringsAsFactors = FALSE
)

# ---- summarize_data: na.rm = TRUE (default) --------------------------------

test_that("summarize_data drops NAs by default", {
  result <- summarize_data(df_na, Design)
  expect_false(any(is.na(result$Design)))
  expect_false("Not reported" %in% result$Design)
  # 4 RCT, 2 Cohort, 1 Case-control = 7 rows after dropping 3 NAs
  expect_equal(sum(result$Frequency), 7)
})

test_that("summarize_data drops empty strings and whitespace", {
  result <- summarize_data(df_empty, Design)
  expect_equal(nrow(result), 2)  # RCT and Cohort only
  expect_false("" %in% result$Design)
})

test_that("default na.rm with multi-value column drops NAs", {
  result <- summarize_data(df_multi_na, Outcome)
  expect_false(any(is.na(result$Outcome)))
  expect_false("" %in% result$Outcome)
  # S1: Pain+Function, S3: Pain, S5: Function+QoL → Pain=2, Function=2, QoL=1
  expect_equal(sum(result$Frequency), 5)
})

# ---- summarize_data: na.rm = FALSE -----------------------------------------

test_that("na.rm = FALSE keeps NAs with default label", {
  result <- summarize_data(df_na, Design, na.rm = FALSE)
  expect_true("Not reported" %in% result$Design)
  nr_row <- result[result$Design == "Not reported", ]
  expect_equal(nr_row$Frequency, 3)
})

test_that("na.rm = FALSE with custom na_label", {
  result <- summarize_data(df_na, Design, na.rm = FALSE, na_label = "Missing")
  expect_true("Missing" %in% result$Design)
  expect_false("Not reported" %in% result$Design)
})

test_that("na.rm = FALSE keeps empty strings as na_label", {
  result <- summarize_data(df_empty, Design, na.rm = FALSE)
  expect_true("Not reported" %in% result$Design)
  # "", "  ", NA all become "Not reported"
  nr_row <- result[result$Design == "Not reported", ]
  expect_equal(nr_row$Frequency, 3)
})

test_that("na.rm = FALSE with multi-value column", {
  result <- summarize_data(df_multi_na, Outcome, na.rm = FALSE)
  expect_true("Not reported" %in% result$Outcome)
})

# ---- na_in_percent ----------------------------------------------------------

test_that("na_in_percent = TRUE uses total rows as denominator", {
  result <- summarize_data(df_na, Design, na.rm = TRUE, na_in_percent = TRUE)
  # 10 studies total, 4 RCT → 40%
  rct_row <- result[result$Design == "RCT", ]
  expect_equal(rct_row$Percent, 40)
  # Percentages do NOT sum to 100 when NAs are dropped
  expect_true(sum(result$Percent) < 100)
})

test_that("na_in_percent = FALSE uses non-missing rows as denominator", {
  result <- summarize_data(df_na, Design, na.rm = TRUE, na_in_percent = FALSE)
  # 7 non-missing studies, 4 RCT → 4/7*100 = 57.1%
  rct_row <- result[result$Design == "RCT", ]
  expect_equal(rct_row$Percent, 57.1)
  # Non-missing percentages sum to ~100
  expect_equal(sum(result$Percent), 100)
})

test_that("na.rm = FALSE + na_in_percent = TRUE: all sum to 100", {
  result <- summarize_data(df_na, Design, na.rm = FALSE, na_in_percent = TRUE)
  expect_equal(sum(result$Percent), 100)
})

test_that("na.rm = FALSE + na_in_percent = FALSE: denominator is non-missing", {
  result <- summarize_data(df_na, Design, na.rm = FALSE, na_in_percent = FALSE)
  # Denominator is 7 (non-missing). 4 RCT → 57.1%, 3 NA → 42.9%
  rct_row <- result[result$Design == "RCT", ]
  expect_equal(rct_row$Percent, 57.1)
  # Sum > 100 because NA row also uses the non-missing denominator
  expect_true(sum(result$Percent) > 100)
})

# ---- all NA errors -----------------------------------------------------------

test_that("all-NA column with na.rm = TRUE and na_in_percent = FALSE errors", {
  expect_error(
    summarize_data(df_all_na, Design, na_in_percent = FALSE),
    "missing"
  )
})

test_that("all-NA column with na.rm = FALSE still works", {
  result <- summarize_data(df_all_na, Design, na.rm = FALSE)
  expect_equal(nrow(result), 1)
  expect_equal(result$Design, "Not reported")
  expect_equal(result$Frequency, 3)
})

# ---- Study IDs are correct for NA groups ------------------------------------

test_that("StudyIDs are concatenated correctly for NA group", {
  result <- summarize_data(df_na, Design, na.rm = FALSE)
  nr_row <- result[result$Design == "Not reported", ]
  expect_true(grepl("S3", nr_row$Studies))
  expect_true(grepl("S6", nr_row$Studies))
  expect_true(grepl("S9", nr_row$Studies))
})

# ---- Plot functions with NAs ------------------------------------------------

test_that("reviewBar works with NAs dropped (default)", {
  p <- reviewBar(df_na, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar works with NAs kept", {
  p <- reviewBar(df_na, Design, na.rm = FALSE, na_label = "Missing")
  expect_s3_class(p, "ggplot")
})

test_that("reviewTable works with NAs", {
  tbl <- reviewTable(df_na, Design, na.rm = FALSE)
  expect_s3_class(tbl, "gt_tbl")
})

test_that("reviewWaffle works with NAs kept", {
  p <- reviewWaffle(df_na, Design, na.rm = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewPie works with NAs kept", {
  p <- reviewPie(df_na, Design, na.rm = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap drops NAs by default", {
  p <- reviewOverlap(df_na, Design, Country)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap keeps NAs when na.rm = FALSE", {
  p <- reviewOverlap(df_na, Design, Country, na.rm = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend drops NAs by default", {
  p <- reviewTrend(df_na, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend keeps NAs", {
  p <- reviewTrend(df_na, Design, na.rm = FALSE, na_label = "Unknown")
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap drops NA countries by default", {
  p <- reviewMap(df_na)
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap with na.rm = FALSE keeps unknown countries", {
  p <- reviewMap(df_na, na.rm = FALSE)
  expect_s3_class(p, "ggplot")
})

# ---- Edge cases --------------------------------------------------------------

test_that("single non-NA value works", {
  df <- data.frame(StudyID = "S1", Design = "RCT", stringsAsFactors = FALSE)
  result <- summarize_data(df, Design)
  expect_equal(result$Frequency, 1)
  expect_equal(result$Percent, 100)
})

test_that("all same value with some NAs", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", NA, "RCT"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Design, na_in_percent = FALSE)
  expect_equal(result$Frequency, 2)
  expect_equal(result$Percent, 100)
})

test_that("multi-value cell where one part is empty", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Outcome = c("Pain\r\n\r\nFunction", "Pain"),
    stringsAsFactors = FALSE
  )
  # After split: Pain, "", Function, Pain → drop "" → Pain=2, Function=1
  result <- summarize_data(df, Outcome)
  expect_equal(nrow(result), 2)
  expect_equal(result$Frequency[result$Outcome == "Pain"], 2)
})

test_that("mixed NA and empty in same column", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4"),
    Design = c("RCT", NA, "", "RCT"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Design, na.rm = FALSE)
  expect_equal(result$Frequency[result$Design == "Not reported"], 2)
})

# ---- na_last ----------------------------------------------------------------

test_that("na_last = FALSE (default): NA row sorted by frequency", {
  result <- summarize_data(df_na, Design, na.rm = FALSE)
  # 3 NAs have higher frequency than Case-control (1), so NA is NOT last
  last_row <- result[nrow(result), ]
  expect_true(last_row$Design != "Not reported")
})

test_that("na_last = TRUE: NA row is placed first in data (bottom of chart)", {
  result <- summarize_data(df_na, Design, na.rm = FALSE, na_last = TRUE)
  first_row <- result[1, ]
  expect_equal(first_row$Design, "Not reported")
})

test_that("na_last = TRUE with custom label", {
  result <- summarize_data(df_na, Design, na.rm = FALSE,
                           na_label = "Missing", na_last = TRUE)
  first_row <- result[1, ]
  expect_equal(first_row$Design, "Missing")
})

test_that("na_last = TRUE has no effect when na.rm = TRUE", {
  r1 <- summarize_data(df_na, Design, na.rm = TRUE, na_last = FALSE)
  r2 <- summarize_data(df_na, Design, na.rm = TRUE, na_last = TRUE)
  expect_equal(r1, r2)
})

test_that("na_last = TRUE keeps other rows in frequency order", {
  result <- summarize_data(df_na, Design, na.rm = FALSE, na_last = TRUE)
  non_na <- result[result$Design != "Not reported", ]
  expect_true(all(diff(non_na$Frequency) >= 0))
})

# ---- All 8 combinations of na.rm x na_in_percent x na_last in plots --------

test_that("all na.rm/na_in_percent/na_last combos work in reviewBar", {
  combos <- expand.grid(na.rm = c(TRUE, FALSE), na_last = c(TRUE, FALSE),
                        na_in_percent = c(TRUE, FALSE))
  for (i in seq_len(nrow(combos))) {
    p <- reviewBar(df_na, Design, na.rm = combos$na.rm[i],
                   na_last = combos$na_last[i],
                   na_in_percent = combos$na_in_percent[i])
    expect_s3_class(p, "ggplot")
  }
})

test_that("all na.rm/na_in_percent/na_last combos work in reviewWaffle", {
  combos <- expand.grid(na.rm = c(TRUE, FALSE), na_last = c(TRUE, FALSE),
                        na_in_percent = c(TRUE, FALSE))
  for (i in seq_len(nrow(combos))) {
    p <- reviewWaffle(df_na, Design, na.rm = combos$na.rm[i],
                      na_last = combos$na_last[i],
                      na_in_percent = combos$na_in_percent[i])
    expect_s3_class(p, "ggplot")
  }
})

test_that("all na.rm/na_in_percent/na_last combos work in reviewPie", {
  combos <- expand.grid(na.rm = c(TRUE, FALSE), na_last = c(TRUE, FALSE),
                        na_in_percent = c(TRUE, FALSE))
  for (i in seq_len(nrow(combos))) {
    p <- reviewPie(df_na, Design, na.rm = combos$na.rm[i],
                   na_last = combos$na_last[i],
                   na_in_percent = combos$na_in_percent[i])
    expect_s3_class(p, "ggplot")
  }
})

test_that("all na.rm/na_in_percent/na_last combos work in reviewTable", {
  combos <- expand.grid(na.rm = c(TRUE, FALSE), na_last = c(TRUE, FALSE),
                        na_in_percent = c(TRUE, FALSE))
  for (i in seq_len(nrow(combos))) {
    tbl <- reviewTable(df_na, Design, na.rm = combos$na.rm[i],
                       na_last = combos$na_last[i],
                       na_in_percent = combos$na_in_percent[i])
    expect_s3_class(tbl, "gt_tbl")
  }
})
