crlf <- paste0("\r", "\n")

# Helper to build multi-value strings with real \r\n
mv <- function(...) paste(..., sep = crlf)

# ---- Percentages with multi-value cells ------------------------------------

test_that("multi-value percentages use nrow(data) as denominator", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4"),
    Outcome = c(mv("Pain", "Function"), "Pain", mv("Function", "QoL"), "Pain"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf)

  # 4 studies. Pain appears in S1,S2,S4 → 3. Function in S1,S3 → 2. QoL in S3 → 1.
  expect_equal(result$Frequency[result$Outcome == "Pain"], 3)
  expect_equal(result$Frequency[result$Outcome == "Function"], 2)
  expect_equal(result$Frequency[result$Outcome == "QoL"], 1)

  # Denominator = 4 (total rows), so: 75%, 50%, 25%
  expect_equal(result$Percent[result$Outcome == "Pain"], 75)
  expect_equal(result$Percent[result$Outcome == "Function"], 50)
  expect_equal(result$Percent[result$Outcome == "QoL"], 25)

  # Multi-value columns can exceed 100%
  expect_true(sum(result$Percent) > 100)
})

test_that("multi-value with NAs: na.rm=TRUE, na_in_percent=TRUE", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4", "S5"),
    Outcome = c(mv("Pain", "Function"), NA, "Pain", "", mv("Function", "QoL")),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf)

  # Denominator = 5 (all rows). Pain in S1,S3 → 2/5 = 40%
  expect_equal(result$Percent[result$Outcome == "Pain"], 40)
  expect_equal(result$Percent[result$Outcome == "Function"], 40)
  expect_equal(result$Percent[result$Outcome == "QoL"], 20)
})

test_that("multi-value with NAs: na.rm=TRUE, na_in_percent=FALSE", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4", "S5"),
    Outcome = c(mv("Pain", "Function"), NA, "Pain", "", mv("Function", "QoL")),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf, na_in_percent = FALSE)

  # Denominator = 3 (non-missing). Pain in S1,S3 → 2/3 = 66.7%
  expect_equal(result$Percent[result$Outcome == "Pain"], 66.7)
  expect_equal(result$Percent[result$Outcome == "Function"], 66.7)
  expect_equal(result$Percent[result$Outcome == "QoL"], 33.3)
})

test_that("multi-value with NAs: na.rm=FALSE, na_in_percent=TRUE", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4", "S5"),
    Outcome = c(mv("Pain", "Function"), NA, "Pain", "", mv("Function", "QoL")),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf, na.rm = FALSE)

  # Denominator = 5. "Not reported" from S2,S4 → 2/5 = 40%
  expect_equal(result$Percent[result$Outcome == "Not reported"], 40)
  expect_equal(result$Percent[result$Outcome == "Pain"], 40)
})

test_that("multi-value with NAs: na.rm=FALSE, na_in_percent=FALSE", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4", "S5"),
    Outcome = c(mv("Pain", "Function"), NA, "Pain", "", mv("Function", "QoL")),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf,
                           na.rm = FALSE, na_in_percent = FALSE)

  # Denominator = 3 (non-missing). Pain → 2/3 = 66.7%, NR → 2/3 = 66.7%
  expect_equal(result$Percent[result$Outcome == "Pain"], 66.7)
  expect_equal(result$Percent[result$Outcome == "Not reported"], 66.7)
})

# ---- Trailing / leading / double separators --------------------------------

test_that("trailing separator creates empty that is dropped", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Outcome = c(paste0("Pain", crlf), mv("Pain", "Function")),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf)

  # The trailing empty from S1 is dropped. Pain=2, Function=1.
  expect_equal(result$Frequency[result$Outcome == "Pain"], 2)
  expect_equal(result$Frequency[result$Outcome == "Function"], 1)
  expect_equal(result$Percent[result$Outcome == "Pain"], 100)
  expect_equal(result$Percent[result$Outcome == "Function"], 50)
})

test_that("leading separator creates empty that is dropped", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Outcome = c(paste0(crlf, "Pain"), "Function"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf)
  expect_equal(nrow(result), 2)
  expect_equal(result$Frequency[result$Outcome == "Pain"], 1)
  expect_equal(result$Frequency[result$Outcome == "Function"], 1)
})

test_that("double separator (empty between) drops the empty", {
  df <- data.frame(
    StudyID = c("S1"),
    Outcome = c(paste0("Pain", crlf, crlf, "Function")),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf)
  expect_equal(nrow(result), 2)
  expect_equal(result$Frequency[result$Outcome == "Pain"], 1)
  expect_equal(result$Frequency[result$Outcome == "Function"], 1)
})

# ---- LF-only separator (common in R-created data) -------------------------

test_that("LF-only separator works when sep is set correctly", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Outcome = c("Pain\nFunction", "Pain"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = "\n")
  expect_equal(result$Frequency[result$Outcome == "Pain"], 2)
  expect_equal(result$Frequency[result$Outcome == "Function"], 1)
})

test_that("CRLF sep does NOT split LF-only data", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Outcome = c("Pain\nFunction", "Pain"),
    stringsAsFactors = FALSE
  )
  # Wrong sep for this data — should NOT split
  result <- summarize_data(df, Outcome, sep = crlf)
  expect_equal(nrow(result), 2)  # not split
})

# ---- StudyID correctness after multi-value split ---------------------------

test_that("StudyIDs track correctly through multi-value split", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Outcome = c(mv("A", "B"), "A", mv("B", "C")),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Outcome, sep = crlf)

  a_row <- result[result$Outcome == "A", ]
  expect_true(grepl("S1", a_row$Studies))
  expect_true(grepl("S2", a_row$Studies))
  expect_false(grepl("S3", a_row$Studies))

  b_row <- result[result$Outcome == "B", ]
  expect_true(grepl("S1", b_row$Studies))
  expect_true(grepl("S3", b_row$Studies))
  expect_false(grepl("S2", b_row$Studies))
})

# ---- Plot functions with multi-value + NA ----------------------------------

test_that("reviewBar handles multi-value with NAs correctly", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Outcome = c(mv("Pain", "Function"), NA, "Pain"),
    stringsAsFactors = FALSE
  )
  p <- reviewBar(df, Outcome, sep = crlf, na.rm = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap handles multi-value in both columns", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", "Cohort", "RCT"),
    Outcome = c(mv("Pain", "Function"), "Pain", mv("Function", "QoL")),
    stringsAsFactors = FALSE
  )
  p <- reviewOverlap(df, Design, Outcome, sep = crlf)
  expect_s3_class(p, "ggplot")
})
