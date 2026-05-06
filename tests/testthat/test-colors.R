df <- data.frame(
  StudyID = paste0("S", 1:8),
  Design  = c("RCT", "Cohort", "RCT", "Case-control", "RCT", "Cohort", "RCT", "Cohort"),
  Year    = c(2020, 2021, 2020, 2021, 2022, 2022, 2023, 2023),
  stringsAsFactors = FALSE
)

named_colors <- c("RCT" = "red", "Cohort" = "blue", "Case-control" = "green")
unnamed_3 <- c("red", "blue", "green")

# ---- reviewBar ---------------------------------------------------------------

test_that("reviewBar: single fill color", {
  p <- reviewBar(df, Design, fill = "#59a14f")
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar: unnamed color vector", {
  p <- reviewBar(df, Design, fill = unnamed_3)
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar: named color vector", {
  p <- reviewBar(df, Design, fill = named_colors)
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar: PALETTE subset", {
  p <- reviewBar(df, Design, fill = PALETTE[1:3])
  expect_s3_class(p, "ggplot")
})

test_that("reviewBar: named colors with NA category", {
  df_na <- data.frame(
    StudyID = c("S1", "S2", "S3", "S4"),
    Design = c("RCT", NA, "Cohort", "RCT"),
    stringsAsFactors = FALSE
  )
  cols <- c("RCT" = "red", "Cohort" = "blue", "Missing" = "grey50")
  p <- reviewBar(df_na, Design, fill = cols, na.rm = FALSE, na_label = "Missing")
  expect_s3_class(p, "ggplot")
})

# ---- reviewWaffle ------------------------------------------------------------

test_that("reviewWaffle: single color (recycled)", {
  p <- reviewWaffle(df, Design, colors = "#59a14f")
  expect_s3_class(p, "ggplot")
})

test_that("reviewWaffle: unnamed color vector", {
  p <- reviewWaffle(df, Design, colors = unnamed_3)
  expect_s3_class(p, "ggplot")
})

test_that("reviewWaffle: named color vector", {
  p <- reviewWaffle(df, Design, colors = named_colors)
  expect_s3_class(p, "ggplot")
})

# ---- reviewPie ---------------------------------------------------------------

test_that("reviewPie: single color (recycled)", {
  p <- reviewPie(df, Design, colors = "#59a14f")
  expect_s3_class(p, "ggplot")
})

test_that("reviewPie: unnamed color vector", {
  p <- reviewPie(df, Design, colors = unnamed_3)
  expect_s3_class(p, "ggplot")
})

test_that("reviewPie: named color vector", {
  p <- reviewPie(df, Design, colors = named_colors)
  expect_s3_class(p, "ggplot")
})

# ---- reviewTrend -------------------------------------------------------------

test_that("reviewTrend: single color (recycled)", {
  p <- reviewTrend(df, Design, colors = "#59a14f")
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend: unnamed color vector", {
  p <- reviewTrend(df, Design, colors = unnamed_3)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend: named color vector", {
  p <- reviewTrend(df, Design, colors = named_colors)
  expect_s3_class(p, "ggplot")
})

# ---- reviewOverlap (gradient, single fill) -----------------------------------

test_that("reviewOverlap: custom fill color", {
  p <- reviewOverlap(df, Design, Year, fill = "#FF0000")
  expect_s3_class(p, "ggplot")
})

# ---- reviewMap (gradient, single fill) ---------------------------------------

test_that("reviewMap: custom fill color", {
  df_map <- data.frame(
    StudyID = c("S1", "S2"), Country = c("Spain", "Germany"),
    stringsAsFactors = FALSE
  )
  p <- reviewMap(df_map, fill = "#FF0000")
  expect_s3_class(p, "ggplot")
})
