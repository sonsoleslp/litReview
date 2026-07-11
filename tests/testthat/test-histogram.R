df <- data.frame(
  StudyID = paste0("S", 1:20),
  Size    = c(30, 45, 60, 22, 88, 120, 35, 51, 74, 66,
              40, 95, 110, 28, 72, 58, 41, 33, 80, 105),
  Design  = rep(c("RCT", "Cohort", "Case-control", "Other"), 5),
  stringsAsFactors = FALSE
)

test_that("reviewHistogram returns a ggplot", {
  expect_s3_class(reviewHistogram(df, Size), "ggplot")
})

test_that("bins is passed through to the histogram stat", {
  p <- reviewHistogram(df, Size, bins = 8)
  expect_equal(p$layers[[1]]$stat_params$bins, 8)
})

test_that("binwidth overrides bins", {
  p <- reviewHistogram(df, Size, binwidth = 10)
  expect_equal(p$layers[[1]]$stat_params$binwidth, 10)
  expect_null(p$layers[[1]]$stat_params$bins)
})

test_that("fill sets a single bar colour when fill_by is NULL", {
  p <- reviewHistogram(df, Size, fill = "#59a14f")
  expect_equal(p$layers[[1]]$aes_params$fill, "#59a14f")
  expect_null(p$labels$fill)                       # no fill legend
})

test_that("fill_by stacks the bars and adds a fill legend", {
  p <- reviewHistogram(df, Size, fill_by = Design, bins = 8)
  expect_equal(p$labels$fill, "Design")
  b <- ggplot2::ggplot_build(p)
  expect_gt(length(unique(b$data[[1]]$fill)), 1)   # one colour per group
})

test_that("colors are applied and recycled with fill_by", {
  p <- reviewHistogram(df, Size, fill_by = Design, colors = c("red", "blue"))
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("fill_by multi-value cells are split on sep", {
  dfm <- data.frame(
    StudyID = c("S1", "S2", "S3"),
    Size    = c(10, 20, 30),
    Group   = c("A\r\nB", "A", "B"),
    stringsAsFactors = FALSE
  )
  p <- reviewHistogram(dfm, Size, fill_by = Group, bins = 3)
  # S1 contributes to both A and B, so its row is duplicated
  expect_equal(nrow(p$data), 4)
})

test_that("na.rm = TRUE (default) drops rows with a missing numeric value", {
  dna <- df
  dna$Size[c(1, 2)] <- NA
  p <- reviewHistogram(dna, Size, bins = 5)
  b <- ggplot2::ggplot_build(p)
  expect_equal(sum(b$data[[1]]$count), 18)         # 20 - 2 missing
})

test_that("na.rm = FALSE keeps fill_by NAs as a labelled category", {
  dna <- df
  dna$Design[1:2] <- NA
  p <- reviewHistogram(dna, Size, fill_by = Design, na.rm = FALSE,
                       na_label = "Missing")
  expect_true("Missing" %in% p$data$Design)
})

test_that("a character column of numbers is coerced to numeric", {
  dc <- df
  dc$Size <- as.character(dc$Size)
  expect_s3_class(reviewHistogram(dc, Size, bins = 5), "ggplot")
})

test_that("a genuinely non-numeric column errors", {
  dbad <- data.frame(StudyID = c("S1", "S2"),
                     Size = c("small", "large"),
                     stringsAsFactors = FALSE)
  expect_error(reviewHistogram(dbad, Size), "not numeric")
})

test_that("a missing column errors", {
  expect_error(reviewHistogram(df, NoSuchCol), "not found")
  expect_error(reviewHistogram(df, Size, fill_by = NoSuchGroup), "not found")
})

test_that("reviewHistogram is composable with ggplot2 layers", {
  p <- reviewHistogram(df, Size) + ggplot2::labs(title = "Sizes")
  expect_equal(p$labels$title, "Sizes")
})

test_that("reviewHistogram works on the bundled studies data", {
  data(studies)
  expect_s3_class(reviewHistogram(studies, SampleSize, bins = 12), "ggplot")
  # FollowUpWeeks has NAs; default na.rm drops them cleanly
  expect_s3_class(reviewHistogram(studies, FollowUpWeeks), "ggplot")
  expect_s3_class(
    reviewHistogram(studies, SampleSize, fill_by = Design), "ggplot")
})
