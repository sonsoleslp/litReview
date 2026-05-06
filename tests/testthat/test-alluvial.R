skip_if_not_installed("ggalluvial")

df <- data.frame(
  StudyID  = paste0("S", 1:8),
  Design   = c("RCT", "Cohort", "RCT", "RCT", "Cohort", "RCT", "Cohort", "RCT"),
  Quality  = c("High", "Low", "High", "Low", "Low", "High", "Low", "High"),
  Outcome  = c("Pos", "Neg", "Pos", "Neg", "Pos", "Pos", "Neg", "Pos"),
  stringsAsFactors = FALSE
)

df_na <- data.frame(
  StudyID = paste0("S", 1:6),
  Design  = c("RCT", "Cohort", NA, "RCT", "Cohort", NA),
  Quality = c("High", NA, "Low", "High", "Low", "High"),
  stringsAsFactors = FALSE
)

# -- basic usage ---------------------------------------------------------------

test_that("reviewAlluvial returns a ggplot", {
  p <- reviewAlluvial(df, c("Design", "Quality", "Outcome"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial works with two columns", {
  p <- reviewAlluvial(df, c("Design", "Outcome"))
  expect_s3_class(p, "ggplot")
})

# -- labels --------------------------------------------------------------------

test_that("reviewAlluvial labels = 'prop'", {
  p <- reviewAlluvial(df, c("Design", "Quality"), labels = "prop")
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial labels = 'count'", {
  p <- reviewAlluvial(df, c("Design", "Quality"), labels = "count")
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial flow_labels = TRUE", {
  p <- reviewAlluvial(df, c("Design", "Quality"), flow_labels = TRUE)
  expect_s3_class(p, "ggplot")
})

# -- colors --------------------------------------------------------------------

test_that("reviewAlluvial with named colors", {
  cols <- c("RCT" = "red", "Cohort" = "blue", "High" = "green",
            "Low" = "orange", "Pos" = "purple", "Neg" = "grey")
  p <- reviewAlluvial(df, c("Design", "Quality", "Outcome"), colors = cols)
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial with single color (recycled)", {
  p <- reviewAlluvial(df, c("Design", "Quality"), colors = "#59a14f")
  expect_s3_class(p, "ggplot")
})

# -- NA handling ---------------------------------------------------------------

test_that("reviewAlluvial drops NAs by default", {
  p <- reviewAlluvial(df_na, c("Design", "Quality"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial keeps NAs with na.rm = FALSE", {
  p <- reviewAlluvial(df_na, c("Design", "Quality"),
                      na.rm = FALSE, na_label = "Missing")
  expect_s3_class(p, "ggplot")
})

# -- custom options ------------------------------------------------------------

test_that("reviewAlluvial custom study_id", {
  df2 <- df
  names(df2)[1] <- "ID"
  p <- reviewAlluvial(df2, c("Design", "Quality"), study_id = ID)
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial custom axis_labels", {
  p <- reviewAlluvial(df, c("Design", "Quality", "Outcome"),
                      axis_labels = c("Study Design", "Quality", "Result"))
  expect_s3_class(p, "ggplot")
})

test_that("reviewAlluvial custom stratum_width and flow_alpha", {
  p <- reviewAlluvial(df, c("Design", "Outcome"),
                      stratum_width = 0.3, flow_alpha = 0.5)
  expect_s3_class(p, "ggplot")
})

# -- sep (multi-value columns) -------------------------------------------------

test_that("reviewAlluvial handles sep for multi-value columns", {
  crlf <- paste0("\r", "\n")
  df_mv <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Design  = c("RCT", "Cohort", "RCT"),
    Outcome = c(paste0("Pain", crlf, "Function"), "Pain",
                paste0("Function", crlf, "QoL")),
    stringsAsFactors = FALSE
  )
  p <- reviewAlluvial(df_mv, c("Design", "Outcome"), sep = crlf)
  expect_s3_class(p, "ggplot")
})

# -- validation ----------------------------------------------------------------

test_that("reviewAlluvial errors on missing column", {
  expect_error(reviewAlluvial(df, c("Design", "NoSuchCol")), "not found")
})

# -- composability -------------------------------------------------------------

test_that("reviewAlluvial is composable with ggplot2", {
  p <- reviewAlluvial(df, c("Design", "Quality")) +
    ggplot2::labs(title = "Test")
  expect_equal(p$labels$title, "Test")
})
