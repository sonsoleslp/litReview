skip_if_not_installed("treemapify")

df <- data.frame(
  StudyID = paste0("S", 1:10),
  Design  = c("RCT", "Cohort", "RCT", "RCT", "Cohort",
              "RCT", "Cohort", "RCT", "Case-control", "RCT"),
  Quality = c("High", "Low", "High", "Low", "Low",
              "High", "Low", "High", "Low", "High"),
  stringsAsFactors = FALSE
)

test_that("reviewTreemap returns a ggplot (single col)", {
  p <- reviewTreemap(df, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap with color_by", {
  p <- reviewTreemap(df, Design, color_by = Quality)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap with studlabs", {
  p <- reviewTreemap(df, Design, studlabs = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap with color_by and studlabs", {
  p <- reviewTreemap(df, Design, color_by = Quality, studlabs = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap handles NAs", {
  df_na <- df
  df_na$Design[3] <- NA
  p <- reviewTreemap(df_na, Design, na.rm = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap with named colors", {
  cols <- c("RCT" = "red", "Cohort" = "blue", "Case-control" = "green")
  p <- reviewTreemap(df, Design, colors = cols)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap with single color", {
  p <- reviewTreemap(df, Design, colors = "#59a14f")
  expect_s3_class(p, "ggplot")
})

test_that("reviewTreemap composable with ggplot2", {
  p <- reviewTreemap(df, Design) + ggplot2::labs(title = "Test")
  expect_equal(p$labels$title, "Test")
})

test_that("reviewTreemap errors on missing column", {
  expect_error(reviewTreemap(df, NoSuchCol), "not found")
})
