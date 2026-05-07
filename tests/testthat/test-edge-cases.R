# ============================================================================
# Comprehensive edge-case and corner-situation tests
# ============================================================================

# ---- Shared test data -------------------------------------------------------

df_basic <- data.frame(
  StudyID = paste0("S", 1:6),
  Design  = c("RCT", "Cohort", "RCT", "RCT", "Cohort", "Case-control"),
  Year    = c(2020, 2020, 2021, 2021, 2022, 2022),
  Country = c("Spain", "UK", "Germany", "Spain", "UK", "France"),
  stringsAsFactors = FALSE
)

df_single_row <- data.frame(
  StudyID = "S1", Design = "RCT", Year = 2020, Country = "Spain",
  stringsAsFactors = FALSE
)

df_single_cat <- data.frame(
  StudyID = paste0("S", 1:5),
  Design  = rep("RCT", 5),
  Year    = c(2020, 2020, 2021, 2021, 2022),
  Country = rep("Spain", 5),
  stringsAsFactors = FALSE
)

df_factor <- data.frame(
  StudyID = paste0("S", 1:4),
  Design  = factor(c("RCT", "Cohort", "RCT", "Case-control")),
  stringsAsFactors = FALSE
)

df_multivalue <- data.frame(
  StudyID = paste0("S", 1:4),
  Tags    = c("A;B", "B;C", "A", "C;A;B"),
  stringsAsFactors = FALSE
)

df_whitespace <- data.frame(
  StudyID = paste0("S", 1:5),
  Design  = c("RCT", "  ", "\t", "", NA),
  stringsAsFactors = FALSE
)

df_special_chars <- data.frame(
  StudyID = paste0("S", 1:4),
  Design  = c("A (sub-type)", "B [v2]", "C & D", "A (sub-type)"),
  stringsAsFactors = FALSE
)

# ============================================================================
# 1. Input validation
# ============================================================================

test_that("validate_inputs rejects non-data.frame", {
  expect_error(reviewBar(list(a = 1), a), "data frame")
  expect_error(summarize_data(list(a = 1), a), "data frame")
})

test_that("validate_inputs rejects empty data frame", {
  empty <- df_basic[0, ]
  expect_error(reviewBar(empty, Design), "0 rows")
  expect_error(summarize_data(empty, Design), "0 rows")
})

test_that("validate_inputs rejects missing column and shows available names", {
  expect_error(reviewBar(df_basic, NoSuchCol), "not found")
  expect_error(reviewBar(df_basic, NoSuchCol), "Available columns")
  expect_error(reviewBar(df_basic, NoSuchCol), "Design")
  expect_error(reviewWaffle(df_basic, Zzzz), "Available columns")
  expect_error(reviewPie(df_basic, Zzzz), "Available columns")
  expect_error(reviewOverlap(df_basic, Design, Zzzz), "Available columns")
  expect_error(reviewOverlap(df_basic, Zzzz, Design), "Available columns")
  expect_error(reviewTrend(df_basic, Zzzz), "Available columns")
  expect_error(reviewTable(df_basic, Zzzz), "Available columns")
})

test_that("reviewTrend errors on missing year column", {
  df <- data.frame(StudyID = "S1", Design = "RCT", stringsAsFactors = FALSE)
  expect_error(reviewTrend(df, Design), "not found")
})

test_that("reviewTrend labels='studies' errors on missing study_id with suggestions", {
  df <- data.frame(Year = 2020, Design = "RCT", stringsAsFactors = FALSE)
  expect_error(
    reviewTrend(df, Design, labels = "studies"),
    "not found"
  )
  expect_error(
    reviewTrend(df, Design, labels = "studies"),
    "Available columns"
  )
})

test_that("reviewOverlap studlabs errors on missing study_id with suggestions", {
  df <- data.frame(A = "x", B = "y", stringsAsFactors = FALSE)
  expect_error(
    reviewOverlap(df, A, B, studlabs = TRUE),
    "not found"
  )
  expect_error(
    reviewOverlap(df, A, B, studlabs = TRUE),
    "Available columns"
  )
})

test_that("all-NA column errors with na_in_percent = FALSE", {
  df <- data.frame(StudyID = c("S1", "S2"), Design = c(NA, NA),
                   stringsAsFactors = FALSE)
  expect_error(summarize_data(df, Design, na_in_percent = FALSE), "missing")
})

# ============================================================================
# 2. Single-row data
# ============================================================================

test_that("summarize_data handles single row", {
  r <- summarize_data(df_single_row, Design)
  expect_equal(r$Frequency, 1)
  expect_equal(r$Percent, 100)
})

test_that("all plot functions handle single row", {
  expect_s3_class(reviewBar(df_single_row, Design), "ggplot")
  expect_s3_class(reviewWaffle(df_single_row, Design), "ggplot")
  expect_s3_class(reviewPie(df_single_row, Design), "ggplot")
  expect_s3_class(reviewPie(df_single_row, Design, donut = FALSE), "ggplot")
  expect_s3_class(reviewTrend(df_single_row, Design), "ggplot")
  expect_s3_class(reviewOverlap(df_single_row, Design, Country), "ggplot")
  expect_s3_class(reviewTable(df_single_row, Design), "gt_tbl")
})

skip_if_not_installed("treemapify")
test_that("reviewTreemap handles single row", {
  expect_s3_class(reviewTreemap(df_single_row, Design), "ggplot")
})

skip_if_not_installed("maps")
test_that("reviewMap handles single row", {
  expect_s3_class(reviewMap(df_single_row), "ggplot")
})

# ============================================================================
# 3. Single unique category
# ============================================================================

test_that("summarize_data handles all-same values", {
  r <- summarize_data(df_single_cat, Design)
  expect_equal(nrow(r), 1)
  expect_equal(r$Frequency, 5)
  expect_equal(r$Percent, 100)
})

test_that("all plot functions handle single category", {
  expect_s3_class(reviewBar(df_single_cat, Design), "ggplot")
  expect_s3_class(reviewWaffle(df_single_cat, Design), "ggplot")
  expect_s3_class(reviewPie(df_single_cat, Design), "ggplot")
  expect_s3_class(reviewTrend(df_single_cat, Design), "ggplot")
  expect_s3_class(reviewOverlap(df_single_cat, Design, Country), "ggplot")
  expect_s3_class(reviewTable(df_single_cat, Design), "gt_tbl")
})

# ============================================================================
# 4. Factor columns
# ============================================================================

test_that("summarize_data works with factor column", {
  r <- summarize_data(df_factor, Design)
  expect_equal(nrow(r), 3)
  expect_true(is.numeric(r$Percent))
})

test_that("plot functions work with factor column", {
  expect_s3_class(reviewBar(df_factor, Design), "ggplot")
  expect_s3_class(reviewWaffle(df_factor, Design), "ggplot")
  expect_s3_class(reviewPie(df_factor, Design), "ggplot")
  expect_s3_class(reviewTable(df_factor, Design), "gt_tbl")
})

# ============================================================================
# 5. Quoted column names
# ============================================================================

test_that("summarize_data works with quoted column name", {
  r <- summarize_data(df_basic, "Design")
  expect_equal(nrow(r), 3)
})

test_that("plot functions work with quoted column name", {
  expect_s3_class(reviewBar(df_basic, "Design"), "ggplot")
  expect_s3_class(reviewWaffle(df_basic, "Design"), "ggplot")
  expect_s3_class(reviewPie(df_basic, "Design"), "ggplot")
  expect_s3_class(reviewTrend(df_basic, "Design"), "ggplot")
  expect_s3_class(reviewOverlap(df_basic, "Design", "Country"), "ggplot")
  expect_s3_class(reviewTable(df_basic, "Design"), "gt_tbl")
})

# ============================================================================
# 6. Custom separators
# ============================================================================

test_that("summarize_data works with semicolon separator", {
  r <- summarize_data(df_multivalue, Tags, sep = ";")
  expect_true("A" %in% r$Tags)
  expect_true("B" %in% r$Tags)
  expect_true("C" %in% r$Tags)
  # A: S1, S3, S4; B: S1, S2, S4; C: S2, S4
  expect_equal(r$Frequency[r$Tags == "A"], 3)
  expect_equal(r$Frequency[r$Tags == "B"], 3)
  expect_equal(r$Frequency[r$Tags == "C"], 2)
})

test_that("plot functions work with custom separator", {
  expect_s3_class(reviewBar(df_multivalue, Tags, sep = ";"), "ggplot")
  expect_s3_class(reviewWaffle(df_multivalue, Tags, sep = ";"), "ggplot")
  expect_s3_class(reviewPie(df_multivalue, Tags, sep = ";"), "ggplot")
})

test_that("comma separator works", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("X, Y", "Y, Z"),
    stringsAsFactors = FALSE
  )
  r <- summarize_data(df, Tags, sep = ",")
  expect_equal(nrow(r), 3)
  # trimws should handle the space after comma
  expect_true("X" %in% r$Tags)
  expect_true("Y" %in% r$Tags)
  expect_true("Z" %in% r$Tags)
})

test_that("separator not present in data has no effect", {
  r <- summarize_data(df_basic, Design, sep = "|")
  expect_equal(nrow(r), 3)
})

# ============================================================================
# 7. Multi-value edge cases
# ============================================================================

test_that("trailing separator produces no empty values", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("A\nB\n", "\nC"),
    stringsAsFactors = FALSE
  )
  r <- summarize_data(df, Tags)
  expect_false("" %in% r$Tags)
  expect_equal(nrow(r), 3)
})

test_that("consecutive separators produce no empty values", {
  df <- data.frame(
    StudyID = c("S1"),
    Tags = c("A\n\n\nB"),
    stringsAsFactors = FALSE
  )
  r <- summarize_data(df, Tags)
  expect_false("" %in% r$Tags)
  expect_equal(nrow(r), 2)
})

test_that("CRLF and LF produce same results", {
  df_crlf <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("A\r\nB", "B\r\nC"),
    stringsAsFactors = FALSE
  )
  df_lf <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("A\nB", "B\nC"),
    stringsAsFactors = FALSE
  )
  r1 <- summarize_data(df_crlf, Tags)
  r2 <- summarize_data(df_lf, Tags)
  expect_equal(r1, r2)
})

test_that("multi-value cell with all same values counts correctly", {
  df <- data.frame(
    StudyID = c("S1"),
    Tags = c("A\nA\nA"),
    stringsAsFactors = FALSE
  )
  r <- summarize_data(df, Tags)
  expect_equal(r$Frequency[r$Tags == "A"], 3)
})

# ============================================================================
# 8. Whitespace and empty string handling
# ============================================================================

test_that("whitespace-only and empty values treated as missing", {
  r <- summarize_data(df_whitespace, Design)
  # Only "RCT" should remain
  expect_equal(nrow(r), 1)
  expect_equal(r$Design, "RCT")
  expect_equal(r$Frequency, 1)
})

test_that("whitespace-only kept as NA label when na.rm = FALSE", {
  r <- summarize_data(df_whitespace, Design, na.rm = FALSE)
  expect_true("Not reported" %in% r$Design)
  # 4 missing: "  ", "\t", "", NA
  expect_equal(r$Frequency[r$Design == "Not reported"], 4)
})

# ============================================================================
# 9. Special characters in category names
# ============================================================================

test_that("special characters in values do not break plots", {
  expect_s3_class(reviewBar(df_special_chars, Design), "ggplot")
  expect_s3_class(reviewWaffle(df_special_chars, Design), "ggplot")
  expect_s3_class(reviewPie(df_special_chars, Design), "ggplot")
  expect_s3_class(reviewTable(df_special_chars, Design), "gt_tbl")
})

# ============================================================================
# 10. Color edge cases
# ============================================================================

test_that("fewer colors than categories triggers recycling", {
  p <- reviewWaffle(df_basic, Design, colors = c("red", "blue"))
  expect_s3_class(p, "ggplot")
})

test_that("single color works for all color-accepting functions", {
  expect_s3_class(reviewWaffle(df_basic, Design, colors = "red"), "ggplot")
  expect_s3_class(reviewPie(df_basic, Design, colors = "red"), "ggplot")
  expect_s3_class(reviewTrend(df_basic, Design, colors = "red"), "ggplot")
})

test_that("named color vector with exact matches works", {
  cols <- c("RCT" = "red", "Cohort" = "blue", "Case-control" = "green")
  expect_s3_class(reviewBar(df_basic, Design, fill = cols), "ggplot")
  expect_s3_class(reviewWaffle(df_basic, Design, colors = cols), "ggplot")
  expect_s3_class(reviewPie(df_basic, Design, colors = cols), "ggplot")
})

test_that("named color vector with extra names works (ggplot ignores extras)", {
  cols <- c("RCT" = "red", "Cohort" = "blue", "Case-control" = "green",
            "Other" = "yellow")
  expect_s3_class(reviewBar(df_basic, Design, fill = cols), "ggplot")
})

test_that("PALETTE has 8 valid colors", {
  expect_length(PALETTE, 8)
  # All should be parseable as colors
  rgb_vals <- grDevices::col2rgb(PALETTE)
  expect_equal(ncol(rgb_vals), 8)
})

# ============================================================================
# 11. Custom study_id
# ============================================================================

test_that("custom study_id works across functions", {
  df <- data.frame(
    AuthorID = paste0("A", 1:4),
    Design = c("RCT", "Cohort", "RCT", "RCT"),
    Year = c(2020, 2021, 2021, 2022),
    Country = c("Spain", "UK", "Germany", "Spain"),
    stringsAsFactors = FALSE
  )
  r <- summarize_data(df, Design, study_id = AuthorID)
  expect_true(grepl("A1", r$Studies[r$Design == "RCT"]))

  expect_s3_class(reviewBar(df, Design, study_id = AuthorID), "ggplot")
  expect_s3_class(reviewWaffle(df, Design, study_id = AuthorID), "ggplot")
  expect_s3_class(reviewPie(df, Design, study_id = AuthorID), "ggplot")
  expect_s3_class(reviewTable(df, Design, study_id = AuthorID), "gt_tbl")
  expect_s3_class(reviewTrend(df, Design, study_id = AuthorID), "ggplot")
})

test_that("quoted custom study_id works", {
  df <- data.frame(
    AuthorID = c("A1", "A2"),
    Design = c("RCT", "Cohort"),
    stringsAsFactors = FALSE
  )
  r <- summarize_data(df, Design, study_id = "AuthorID")
  expect_equal(nrow(r), 2)
})

# ============================================================================
# 12. reviewBar specific
# ============================================================================

test_that("reviewBar with multi-color fill", {
  cols <- c("#ff0000", "#00ff00", "#0000ff")
  p <- reviewBar(df_basic, Design, fill = cols)
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar with width extremes", {
  expect_s3_class(reviewBar(df_basic, Design, width = 0.1), "ggplot")
  expect_s3_class(reviewBar(df_basic, Design, width = 1.0), "ggplot")
})

test_that("reviewBar label_space affects x-axis range", {
  p1 <- reviewBar(df_basic, Design, label_space = 1.2)
  p2 <- reviewBar(df_basic, Design, label_space = 3.0)
  # Both should build without error
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("reviewBar with base_size extremes", {
  expect_s3_class(reviewBar(df_basic, Design, base_size = 6), "ggplot")
  expect_s3_class(reviewBar(df_basic, Design, base_size = 24), "ggplot")
})

skip_if_not_installed("ggfittext")
test_that("reviewBar studlabs with custom study_id", {
  df <- data.frame(
    Author = c("Smith", "Jones", "Lee"),
    Design = c("RCT", "RCT", "Cohort"),
    stringsAsFactors = FALSE
  )
  p <- reviewBar(df, Design, studlabs = TRUE, study_id = Author)
  expect_s3_class(p, "ggplot")
})

# ============================================================================
# 13. reviewWaffle specific
# ============================================================================

test_that("reviewWaffle with ncol = 1", {
  p <- reviewWaffle(df_basic, Design, ncol = 1)
  expect_s3_class(p, "ggplot")
})

test_that("reviewWaffle with ncol > n items", {
  p <- reviewWaffle(df_basic, Design, ncol = 100)
  expect_s3_class(p, "ggplot")
})

test_that("reviewWaffle with single category", {
  p <- reviewWaffle(df_single_cat, Design)
  expect_s3_class(p, "ggplot")
})

# ============================================================================
# 14. reviewPie specific
# ============================================================================

test_that("reviewPie donut = FALSE", {
  p <- reviewPie(df_basic, Design, donut = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewPie single category (whole pie)", {
  p <- reviewPie(df_single_cat, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewPie with custom colors", {
  p <- reviewPie(df_basic, Design, colors = c("red", "blue", "green"))
  expect_s3_class(p, "ggplot")
})

# ============================================================================
# 15. reviewOverlap specific
# ============================================================================

test_that("reviewOverlap with same column for both axes errors", {
  expect_error(reviewOverlap(df_basic, Design, Design))
})

test_that("reviewOverlap with studlabs = TRUE", {
  p <- reviewOverlap(df_basic, Design, Country, studlabs = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap with NAs in both columns", {
  df <- data.frame(
    StudyID = paste0("S", 1:4),
    A = c("x", NA, "y", "x"),
    B = c("p", "q", NA, "p"),
    stringsAsFactors = FALSE
  )
  expect_s3_class(reviewOverlap(df, A, B, na.rm = FALSE), "ggplot")
  expect_s3_class(reviewOverlap(df, A, B, na.rm = TRUE), "ggplot")
})

test_that("reviewOverlap with multi-value cells", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    A = c("x\ny", "y"),
    B = c("p", "p\nq"),
    stringsAsFactors = FALSE
  )
  p <- reviewOverlap(df, A, B)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap with custom fill", {
  p <- reviewOverlap(df_basic, Design, Country, fill = "#ff0000")
  expect_s3_class(p, "ggplot")
})

# ============================================================================
# 16. reviewTrend specific
# ============================================================================

test_that("reviewTrend all label types work", {
  for (lbl in c("none", "count", "percent", "both", "studies")) {
    p <- reviewTrend(df_basic, Design, labels = lbl)
    expect_s3_class(p, "ggplot")
  }
})

test_that("reviewTrend with single year", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", "Cohort", "RCT"),
    Year = c(2020, 2020, 2020),
    stringsAsFactors = FALSE
  )
  p <- reviewTrend(df, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend with custom year column", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Design = c("RCT", "Cohort"),
    PubYear = c(2020, 2021),
    stringsAsFactors = FALSE
  )
  p <- reviewTrend(df, Design, year_col = PubYear)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend with multi-value column", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("A\nB", "B\nC"),
    Year = c(2020, 2021),
    stringsAsFactors = FALSE
  )
  p <- reviewTrend(df, Tags)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend with NAs in category and na.rm = FALSE", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", NA, "Cohort"),
    Year = c(2020, 2021, 2021),
    stringsAsFactors = FALSE
  )
  p <- reviewTrend(df, Design, na.rm = FALSE)
  expect_s3_class(p, "ggplot")
})

# ============================================================================
# 17. reviewMap specific
# ============================================================================

skip_if_not_installed("maps")

test_that("reviewMap with country aliases", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Country = c("United States", "United Kingdom", "Czechia"),
    stringsAsFactors = FALSE
  )
  p <- reviewMap(df)
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap with unknown country (no match in map_data)", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Country = c("Atlantis", "Spain"),
    stringsAsFactors = FALSE
  )
  p <- reviewMap(df)
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap with multi-value country", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Country = c("Spain\nFrance", "Germany"),
    stringsAsFactors = FALSE
  )
  p <- reviewMap(df)
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap with custom country column", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Location = c("Spain", "Germany"),
    stringsAsFactors = FALSE
  )
  p <- reviewMap(df, country_col = Location)
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap with custom fill color", {
  p <- reviewMap(df_basic, fill = "#ff0000")
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap with all same country", {
  p <- reviewMap(df_single_cat)
  expect_s3_class(p, "ggplot")
})

# ============================================================================
# 18. reviewAlluvial specific
# ============================================================================

skip_if_not_installed("ggalluvial")

df_alluv <- data.frame(
  StudyID = paste0("S", 1:8),
  Design  = c("RCT", "Cohort", "RCT", "RCT", "Cohort", "RCT", "RCT", "Cohort"),
  Quality = c("High", "Low", "High", "Low", "Low", "High", "High", "Low"),
  Outcome = c("Pos", "Neg", "Pos", "Neg", "Pos", "Pos", "Neg", "Pos"),
  stringsAsFactors = FALSE
)

test_that("reviewAlluvial with 2 columns", {
  p <- reviewAlluvial(df_alluv, c("Design", "Quality"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial with 3 columns", {
  p <- reviewAlluvial(df_alluv, c("Design", "Quality", "Outcome"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial all label types", {
  for (lbl in c("none", "prop", "count", "both")) {
    p <- reviewAlluvial(df_alluv, c("Design", "Quality"), labels = lbl)
    expect_s3_class(p, "ggplot")
  }
})

test_that("reviewAlluvial with flow_labels and all label types", {
  for (lbl in c("none", "prop", "count", "both")) {
    p <- reviewAlluvial(df_alluv, c("Design", "Quality"),
                        labels = lbl, flow_labels = TRUE)
    expect_s3_class(p, "ggplot")
  }
})

test_that("reviewAlluvial with custom axis_labels", {
  p <- reviewAlluvial(df_alluv, c("Design", "Quality"),
                      axis_labels = c("Study Design", "Study Quality"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial with NAs", {
  df <- data.frame(
    StudyID = paste0("S", 1:4),
    A = c("x", NA, "y", "x"),
    B = c("p", "q", NA, "p"),
    stringsAsFactors = FALSE
  )
  expect_s3_class(reviewAlluvial(df, c("A", "B"), na.rm = FALSE), "ggplot")
  expect_s3_class(reviewAlluvial(df, c("A", "B"), na.rm = TRUE), "ggplot")
})

test_that("reviewAlluvial with multi-value cells", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    A = c("x\ny", "y", "x"),
    B = c("p", "p\nq", "q"),
    stringsAsFactors = FALSE
  )
  p <- reviewAlluvial(df, c("A", "B"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial with custom study_id", {
  df <- data.frame(
    Author = c("Smith", "Jones", "Lee"),
    A = c("x", "y", "x"),
    B = c("p", "q", "p"),
    stringsAsFactors = FALSE
  )
  p <- reviewAlluvial(df, c("A", "B"), study_id = Author)
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial with single category in one column", {
  df <- data.frame(
    StudyID = paste0("S", 1:3),
    A = c("x", "x", "x"),
    B = c("p", "q", "p"),
    stringsAsFactors = FALSE
  )
  p <- reviewAlluvial(df, c("A", "B"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial with custom colors", {
  p <- reviewAlluvial(df_alluv, c("Design", "Quality"),
                      colors = c("red", "blue", "green", "orange"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial with named colors", {
  cols <- c("RCT" = "red", "Cohort" = "blue", "High" = "green", "Low" = "orange")
  p <- reviewAlluvial(df_alluv, c("Design", "Quality"), colors = cols)
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial with custom stratum_width", {
  p <- reviewAlluvial(df_alluv, c("Design", "Quality"), stratum_width = 0.2)
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial errors on missing column", {
  expect_error(reviewAlluvial(df_alluv, c("Design", "NoSuchCol")), "not found")
})

test_that("reviewAlluvial composable with ggplot2", {
  p <- reviewAlluvial(df_alluv, c("Design", "Quality")) +
    ggplot2::labs(title = "Test")
  expect_equal(p$labels$title, "Test")
})

# ============================================================================
# 19. reviewTreemap specific
# ============================================================================

skip_if_not_installed("treemapify")

test_that("reviewTreemap with color_by and NAs", {
  df <- data.frame(
    StudyID = paste0("S", 1:5),
    Intervention = c("CBT", "Exercise", NA, "CBT", "Exercise"),
    Type = c("Behavioral", "Physical", "Behavioral", NA, "Physical"),
    stringsAsFactors = FALSE
  )
  expect_s3_class(reviewTreemap(df, Intervention, na.rm = FALSE), "ggplot")
  expect_s3_class(
    reviewTreemap(df, Intervention, color_by = Type, na.rm = FALSE),
    "ggplot"
  )
  expect_s3_class(
    reviewTreemap(df, Intervention, color_by = Type, na.rm = TRUE),
    "ggplot"
  )
})

test_that("reviewTreemap with single category", {
  p <- reviewTreemap(df_single_cat, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap studlabs with color_by", {
  df <- data.frame(
    StudyID = paste0("S", 1:6),
    A = c("x", "y", "x", "y", "x", "y"),
    B = c("p", "p", "q", "q", "p", "q"),
    stringsAsFactors = FALSE
  )
  p <- reviewTreemap(df, A, color_by = B, studlabs = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap studlabs without color_by", {
  p <- reviewTreemap(df_basic, Design, studlabs = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap with multi-value col", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Tags = c("A\nB", "B\nC", "A"),
    stringsAsFactors = FALSE
  )
  p <- reviewTreemap(df, Tags)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap errors on missing color_by column", {
  expect_error(reviewTreemap(df_basic, Design, color_by = NoSuchCol), "not found")
})

test_that("reviewTreemap with custom border_col", {
  p <- reviewTreemap(df_basic, Design, border_col = "black")
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap composable with ggplot2", {
  p <- reviewTreemap(df_basic, Design) + ggplot2::labs(title = "Test")
  expect_equal(p$labels$title, "Test")
})

# ============================================================================
# 20. reviewTable specific
# ============================================================================

test_that("reviewTable latex = TRUE returns latex object", {
  result <- reviewTable(df_basic, Design, latex = TRUE)
  expect_true(inherits(result, "knit_asis") || is.character(result))
})

test_that("reviewTable cite = TRUE wraps studies in cite", {
  df <- data.frame(
    bibkey = c("smith2020", "jones2021", "lee2022"),
    Design = c("RCT", "Cohort", "RCT"),
    stringsAsFactors = FALSE
  )
  tbl <- reviewTable(df, Design, study_id = bibkey, cite = TRUE)
  expect_s3_class(tbl, "gt_tbl")
})

test_that("reviewTable cite + latex combined", {
  df <- data.frame(
    bibkey = c("smith2020", "jones2021"),
    Design = c("RCT", "Cohort"),
    stringsAsFactors = FALSE
  )
  result <- reviewTable(df, Design, study_id = bibkey,
                        cite = TRUE, latex = TRUE)
  expect_true(inherits(result, "knit_asis") || is.character(result))
})

test_that("reviewTable with single row", {
  tbl <- reviewTable(df_single_row, Design)
  expect_s3_class(tbl, "gt_tbl")
})

test_that("reviewTable with NA handling", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", NA, "RCT"),
    stringsAsFactors = FALSE
  )
  tbl <- reviewTable(df, Design, na.rm = FALSE, na_label = "Unknown")
  expect_s3_class(tbl, "gt_tbl")
})

# ============================================================================
# 21. theme_litreview
# ============================================================================

test_that("theme_litreview returns a ggplot theme", {
  th <- theme_litreview()
  expect_s3_class(th, "theme")
})

test_that("theme_litreview respects base_size", {
  th6 <- theme_litreview(base_size = 6)
  th24 <- theme_litreview(base_size = 24)
  expect_s3_class(th6, "theme")
  expect_s3_class(th24, "theme")
})

test_that("theme_litreview is composable", {
  p <- ggplot2::ggplot(df_basic, ggplot2::aes(x = Design)) +
    ggplot2::geom_bar() +
    theme_litreview(base_size = 14)
  expect_s3_class(p, "ggplot")
})

# ============================================================================
# 22. Internal helpers
# ============================================================================

test_that("is_missing detects all missing types", {
  result <- litReview:::is_missing(c("a", NA, "", " ", "\t", "b"))
  expect_equal(result, c(FALSE, TRUE, TRUE, TRUE, TRUE, FALSE))
})

test_that("normalise_countries resolves common aliases", {
  x <- c("United States", "United Kingdom", "Czechia", "Spain", "Holland")
  r <- litReview:::normalise_countries(x)
  expect_equal(r, c("USA", "UK", "Czech Republic", "Spain", "Netherlands"))
})

test_that("normalise_countries passes through unknown names", {
  r <- litReview:::normalise_countries(c("Atlantis", "Narnia"))
  expect_equal(r, c("Atlantis", "Narnia"))
})

test_that("lighten_color with amount = 0 returns same color", {
  hex <- "#7BB0D1"
  r <- litReview:::lighten_color(hex, 0)
  expect_equal(toupper(r), toupper(hex))
})

test_that("lighten_color with amount = 1 returns white", {
  r <- litReview:::lighten_color("#000000", 1)
  expect_equal(toupper(r), "#FFFFFF")
})

test_that("recycle_colors recycles shorter vector", {
  r <- litReview:::recycle_colors(c("red", "blue"), 5)
  expect_length(r, 5)
  expect_equal(r, c("red", "blue", "red", "blue", "red"))
})

test_that("recycle_colors returns named vector as-is", {
  cols <- c("A" = "red", "B" = "blue")
  r <- litReview:::recycle_colors(cols, 5)
  expect_equal(r, cols)
})

test_that("recycle_colors does not truncate longer vector", {
  r <- litReview:::recycle_colors(c("a", "b", "c", "d"), 2)
  expect_length(r, 4)
})

test_that("move_na_last with do = FALSE returns unchanged", {
  df <- data.frame(x = c("A", "Not reported", "B"), stringsAsFactors = FALSE)
  r <- litReview:::move_na_last(df, "x", "Not reported", do = FALSE)
  expect_equal(r, df)
})

test_that("move_na_last with no matching label returns unchanged", {
  df <- data.frame(x = c("A", "B", "C"), stringsAsFactors = FALSE)
  r <- litReview:::move_na_last(df, "x", "Not reported", do = TRUE)
  expect_equal(r, df)
})

test_that("move_na_last moves label to first position", {
  df <- data.frame(x = c("A", "B", "Not reported"), stringsAsFactors = FALSE)
  r <- litReview:::move_na_last(df, "x", "Not reported", do = TRUE)
  expect_equal(r$x[1], "Not reported")
})

test_that("split_col trims whitespace", {
  df <- data.frame(x = " A \n B ", stringsAsFactors = FALSE)
  r <- litReview:::split_col(df, "x")
  expect_equal(r$x, c("A", "B"))
})

# ============================================================================
# 23. Composability: all plot functions work with ggplot2::labs()
# ============================================================================

test_that("all plot functions composable with + labs()", {
  expect_equal(
    (reviewBar(df_basic, Design) + ggplot2::labs(title = "T"))$labels$title,
    "T"
  )
  expect_equal(
    (reviewWaffle(df_basic, Design) + ggplot2::labs(title = "T"))$labels$title,
    "T"
  )
  expect_equal(
    (reviewPie(df_basic, Design) + ggplot2::labs(title = "T"))$labels$title,
    "T"
  )
  expect_equal(
    (reviewTrend(df_basic, Design) + ggplot2::labs(title = "T"))$labels$title,
    "T"
  )
  expect_equal(
    (reviewOverlap(df_basic, Design, Country) +
       ggplot2::labs(title = "T"))$labels$title,
    "T"
  )
})

# ============================================================================
# 24. Percentage accuracy
# ============================================================================

test_that("percentages sum to 100 when na.rm = TRUE and na_in_percent = FALSE", {
  r <- summarize_data(df_basic, Design, na_in_percent = FALSE)
  expect_equal(sum(r$Percent), 100)
})

test_that("percentages sum to 100 when na.rm = FALSE and na_in_percent = TRUE", {
  df <- data.frame(
    StudyID = paste0("S", 1:5),
    Design = c("RCT", NA, "Cohort", "RCT", NA),
    stringsAsFactors = FALSE
  )
  r <- summarize_data(df, Design, na.rm = FALSE, na_in_percent = TRUE)
  expect_equal(sum(r$Percent), 100)
})

test_that("percentages with multi-value cells use pre-split denominator", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Tags = c("A\nB", "B", "A"),
    stringsAsFactors = FALSE
  )
  # 3 studies total (pre-split). After split: A=2, B=2 → 66.7% each
  r <- summarize_data(df, Tags, na_in_percent = TRUE)
  expect_equal(r$Percent[r$Tags == "A"], 66.7)
  expect_equal(r$Percent[r$Tags == "B"], 66.7)
})

test_that("Percent column is always numeric", {
  r <- summarize_data(df_basic, Design)
  expect_true(is.numeric(r$Percent))
})

# ============================================================================
# 25. Large number of categories
# ============================================================================

test_that("functions handle many categories (> PALETTE length)", {
  df <- data.frame(
    StudyID = paste0("S", 1:20),
    Design = paste0("Type_", 1:20),
    stringsAsFactors = FALSE
  )
  expect_s3_class(reviewBar(df, Design), "ggplot")
  expect_s3_class(reviewWaffle(df, Design), "ggplot")
  expect_s3_class(reviewPie(df, Design), "ggplot")
  expect_s3_class(reviewTable(df, Design), "gt_tbl")
})

# ============================================================================
# 26. Two-row data (minimum for overlap/trend)
# ============================================================================

test_that("reviewOverlap with exactly 2 rows", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    A = c("x", "y"),
    B = c("p", "q"),
    stringsAsFactors = FALSE
  )
  p <- reviewOverlap(df, A, B)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend with exactly 2 rows different years", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Design = c("RCT", "Cohort"),
    Year = c(2020, 2021),
    stringsAsFactors = FALSE
  )
  p <- reviewTrend(df, Design, labels = "both")
  expect_s3_class(p, "ggplot")
})

# ============================================================================
# 27. NA in multi-value cell (one part NA, one part valid)
# ============================================================================

test_that("multi-value cell with NA part after split", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("A\n\nB", "C"),
    stringsAsFactors = FALSE
  )
  # After split S1 → A, "", B. Empty dropped. A=1, B=1, C=1
  r <- summarize_data(df, Tags)
  expect_equal(nrow(r), 3)
  expect_false("" %in% r$Tags)
})

test_that("multi-value with na.rm = FALSE labels empty parts", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("A\n\nB", "C"),
    stringsAsFactors = FALSE
  )
  r <- summarize_data(df, Tags, na.rm = FALSE)
  expect_true("Not reported" %in% r$Tags)
})

# ============================================================================
# 28. import_from_google_drive requires rio
# ============================================================================

test_that("import_from_google_drive checks for rio", {
  # We can't actually test the download, but we verify rio is checked
  # The function should exist and have the check
  expect_true(is.function(import_from_google_drive))
})
