# Consistency of keep-NA / na_last behavior across plot types

test_that("levels_na_last moves the NA label to the end when asked", {
  lv <- c("Low", "Not reported", "High")
  expect_equal(litReview:::levels_na_last(lv, "Not reported", TRUE),
               c("Low", "High", "Not reported"))
  expect_equal(litReview:::levels_na_last(lv, "Not reported", FALSE), lv)
  # absent label -> unchanged
  expect_equal(litReview:::levels_na_last(c("a", "b"), "Not reported", TRUE),
               c("a", "b"))
})

test_that("reviewMatrix keeps unaddressed cells as labelled tiles when na.rm = FALSE", {
  df <- data.frame(
    StudyID  = c("A", "B", "C"),
    Type     = c("J", "C", "J"),
    Accuracy = c("O", NA, "D"),
    Equity   = c(NA, "D", "M"),
    stringsAsFactors = FALSE
  )
  crit <- c("Accuracy", "Equity")
  # Default: only coded cells are tiles
  p_drop <- reviewMatrix(df, crit, color_by = "Type")
  expect_equal(sum(p_drop$data$.present), 4)          # 6 cells, 2 missing

  # na.rm = FALSE: every cell becomes a tile, missing labelled
  p_keep <- reviewMatrix(df, crit, color_by = "Type",
                         na.rm = FALSE, na_label = "NR")
  expect_true(all(p_keep$data$.present))
  expect_equal(nrow(p_keep$data), 3 * length(crit))
  expect_true("NR" %in% p_keep$data$.code)
})

test_that("reviewStackedBar na_last puts the NA category at the axis bottom", {
  data(studies)
  p <- reviewStackedBar(studies, RiskOfBias, OpenAccess,
                        na.rm = FALSE, na_label = "Not reported", na_last = TRUE)
  # First factor level maps to the bottom of a horizontal bar
  expect_equal(levels(p$data$RiskOfBias)[1], "Not reported")
})

test_that("reviewTrend na_last puts the NA category last in the stack order", {
  data(studies)
  p <- reviewTrend(studies, RiskOfBias, na.rm = FALSE,
                   na_label = "Not reported", na_last = TRUE)
  lv <- levels(p$data$RiskOfBias)
  expect_equal(lv[length(lv)], "Not reported")
})

test_that("reviewTree na_last orders the NA branch to the bottom", {
  data(studies)
  p <- reviewTree(studies, c("PubType", "FundingSource"), study_id = Author,
                  na.rm = FALSE, na_label = "Not reported", na_last = TRUE,
                  show_members = FALSE)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("na_last is a no-op when na.rm = TRUE", {
  data(studies)
  a <- reviewStackedBar(studies, Design, RiskOfBias, na_last = TRUE)
  b <- reviewStackedBar(studies, Design, RiskOfBias, na_last = FALSE)
  expect_equal(levels(a$data$Design), levels(b$data$Design))
})
