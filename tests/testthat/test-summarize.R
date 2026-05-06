test_that("summarize_data counts frequencies correctly", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4"),
    Design = c("RCT", "Cohort", "RCT", "Case-control"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Design)

  expect_s3_class(result, "data.frame")
  expect_true("Frequency" %in% names(result))
  expect_true("Percent" %in% names(result))
  expect_true("Studies" %in% names(result))

  rct_row <- result[result$Design == "RCT", ]
  expect_equal(rct_row$Frequency, 2)
  expect_equal(rct_row$Percent, 50)
})

test_that("Percent is numeric, not character", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Design = c("RCT", "Cohort"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Design)
  expect_type(result$Percent, "double")
})

test_that("summarize_data handles multi-value cells", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Method = c("A\r\nB", "B", "A\r\nC"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Method, sep = "\r\n")

  expect_equal(nrow(result), 3)
  expect_equal(result$Frequency[result$Method == "B"], 2)
  expect_equal(result$Frequency[result$Method == "A"], 2)
  expect_equal(result$Frequency[result$Method == "C"], 1)
})

test_that("summarize_data uses custom separator", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("x; y", "y; z"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Tags, sep = "; ")

  expect_equal(nrow(result), 3)
  expect_equal(result$Frequency[result$Tags == "y"], 2)
})

test_that("summarize_data concatenates StudyIDs", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", "RCT", "Cohort"),
    stringsAsFactors = FALSE
  )

  result <- summarize_data(df, Design)

  rct_row <- result[result$Design == "RCT", ]
  expect_true(grepl("S1", rct_row$Studies))
  expect_true(grepl("S2", rct_row$Studies))
})

test_that("summarize_data returns ordered by Frequency ascending", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4"),
    Type = c("A", "A", "A", "B"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Type)

  expect_equal(result$Type[1], "B")
  expect_equal(result$Type[2], "A")
})

test_that("summarize_data accepts quoted col name", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Design = c("RCT", "Cohort"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, "Design")
  expect_equal(nrow(result), 2)
})

test_that("summarize_data works with custom study_id column", {
  df <- data.frame(
    ID = c("A1", "A2", "A3"),
    Design = c("RCT", "Cohort", "RCT"),
    stringsAsFactors = FALSE
  )
  result <- summarize_data(df, Design, study_id = ID)
  rct_row <- result[result$Design == "RCT", ]
  expect_true(grepl("A1", rct_row$Studies))
})

test_that("summarize_data errors on missing column", {
  df <- data.frame(StudyID = "S1", X = "a", stringsAsFactors = FALSE)
  expect_error(summarize_data(df, NoSuchCol), "not found")
})

test_that("summarize_data errors on missing study_id column", {
  df <- data.frame(x = 1, Design = "RCT", stringsAsFactors = FALSE)
  expect_error(summarize_data(df, Design), "not found")
})

test_that("summarize_data errors on empty data", {
  df <- data.frame(StudyID = character(), Design = character())
  expect_error(summarize_data(df, Design), "0 rows")
})
