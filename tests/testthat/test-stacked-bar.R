df <- data.frame(
  StudyID = paste0("S", 1:6),
  Design  = c("RCT", "Cohort", "RCT", "Cohort", "RCT", "Cohort"),
  Risk    = c("Low", "High", "Low", "Moderate", "High", "Low"),
  Outcome = c("Pain\r\nFunction", "Pain", "Function",
              "Pain\r\nFunction", "Pain", "Function"),
  stringsAsFactors = FALSE
)

test_that("reviewStackedBar returns a ggplot in both positions", {
  expect_s3_class(reviewStackedBar(df, Design, Risk), "ggplot")
  expect_s3_class(reviewStackedBar(df, Design, Risk, position = "stack"), "ggplot")
})

test_that("reviewStackedBar cross-tabulates the two columns correctly", {
  p <- reviewStackedBar(df, Design, Risk, position = "stack")
  d <- p$data
  # Neither column is multi-value here, so occurrences == number of rows
  expect_equal(sum(d$Frequency), nrow(df))
  # RCT has two Low + one High; Cohort has one each of Low/High/Moderate
  expect_equal(d$Frequency[d$Design == "RCT" & d$Risk == "Low"], 2)
  expect_equal(d$Frequency[d$Design == "Cohort" & d$Risk == "Moderate"], 1)
})

test_that("reviewStackedBar fill-mode percentages sum to 100 within each bar", {
  p <- reviewStackedBar(df, Design, Risk)
  sums <- tapply(p$data$Percent, p$data$Design, sum)
  expect_true(all(abs(sums - 100) < 1e-8))
})

test_that("reviewStackedBar splits multi-value cells", {
  p <- reviewStackedBar(df, Outcome, Risk, position = "stack")
  # Outcome has two-value cells, so total occurrences exceed the row count
  expect_gt(sum(p$data$Frequency), nrow(df))
})

test_that("reviewStackedBar drops NAs by default but keeps them when asked", {
  df_na <- df
  df_na$Risk[1] <- NA
  p_drop <- reviewStackedBar(df_na, Design, Risk)
  expect_false(any(is.na(as.character(p_drop$data$Risk))))

  p_keep <- reviewStackedBar(df_na, Design, Risk, na.rm = FALSE, na_label = "Missing")
  expect_true("Missing" %in% as.character(p_keep$data$Risk))
})

test_that("reviewStackedBar labels toggle adds/removes the text layer", {
  n_text <- function(p) sum(vapply(p$layers,
    function(l) inherits(l$geom, "GeomText"), logical(1)))
  expect_equal(n_text(reviewStackedBar(df, Design, Risk)), 1)
  expect_equal(n_text(reviewStackedBar(df, Design, Risk, labels = FALSE)), 0)
})

test_that("reviewStackedBar errors on invalid position", {
  expect_error(reviewStackedBar(df, Design, Risk, position = "nope"))
})

test_that("reviewStackedBar errors on a missing column", {
  expect_error(reviewStackedBar(df, NoSuchCol, Risk), "not found")
  expect_error(reviewStackedBar(df, Design, NoSuchCol), "not found")
})

test_that("reviewStackedBar is composable with ggplot2 layers", {
  p <- reviewStackedBar(df, Design, Risk) + ggplot2::labs(title = "Composition")
  expect_equal(p$labels$title, "Composition")
})

test_that("reviewStackedBar builds without error", {
  expect_no_error(ggplot2::ggplot_build(reviewStackedBar(df, Design, Risk)))
})

test_that("reviewStackedBar works on the bundled studies data", {
  data(studies)
  expect_s3_class(reviewStackedBar(studies, Design, RiskOfBias), "ggplot")
})
