test_that("reviewBar returns a ggplot", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4"),
    Design = c("RCT", "Cohort", "RCT", "Case-control"),
    stringsAsFactors = FALSE
  )

  p <- reviewBar(df, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar accepts quoted col name", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Design = c("RCT", "Cohort"),
    stringsAsFactors = FALSE
  )
  p <- reviewBar(df, "Design")
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar accepts custom fill and width", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Design = c("RCT", "Cohort"),
    stringsAsFactors = FALSE
  )

  p <- reviewBar(df, Design, fill = "#FF0000", width = 0.8)
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar works with studlabs = TRUE", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", "Cohort", "RCT"),
    stringsAsFactors = FALSE
  )

  p <- reviewBar(df, Design, studlabs = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar is composable with ggplot2 layers", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", "Cohort", "RCT"),
    stringsAsFactors = FALSE
  )

  p <- reviewBar(df, Design) + ggplot2::labs(title = "Test")
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Test")
})

test_that("reviewBar works with custom study_id", {
  df <- data.frame(
    ID = c("A1", "A2", "A3"),
    Design = c("RCT", "Cohort", "RCT"),
    stringsAsFactors = FALSE
  )
  p <- reviewBar(df, Design, study_id = ID)
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar label_space parameter works", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Design = c("RCT", "Cohort"),
    stringsAsFactors = FALSE
  )
  p <- reviewBar(df, Design, label_space = 2.0)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTable returns a gt table", {
  df <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design = c("RCT", "Cohort", "RCT"),
    stringsAsFactors = FALSE
  )

  tbl <- reviewTable(df, Design)
  expect_s3_class(tbl, "gt_tbl")
})

test_that("reviewTable uses custom separator", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Tags = c("A; B", "B; C"),
    stringsAsFactors = FALSE
  )

  tbl <- reviewTable(df, Tags, sep = "; ")
  expect_s3_class(tbl, "gt_tbl")
})

test_that("reviewTable formats Percent with % symbol", {
  df <- data.frame(
    StudyID = c("S1", "S2"),
    Design = c("RCT", "Cohort"),
    stringsAsFactors = FALSE
  )
  tbl <- reviewTable(df, Design)
  # Extract underlying data from gt
  tbl_data <- tbl[["_data"]]
  expect_true(all(grepl("%$", tbl_data$Percent)))
})

test_that("PALETTE has 8 colors", {
  expect_length(PALETTE, 8)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", PALETTE)))
})
