df <- data.frame(
  StudyID  = c("A", "B", "C"),
  Type     = c("Journal", "Conference", "Journal"),
  Accuracy = c("O", "D", NA),
  Equity   = c("D", NA, "M"),
  Ethics   = c("O", "O", "D"),
  stringsAsFactors = FALSE
)
crit <- c("Accuracy", "Equity", "Ethics")

test_that("reviewMatrix returns a ggplot", {
  expect_s3_class(reviewMatrix(df, crit, color_by = "Type"), "ggplot")
})

test_that("reviewMatrix keeps every study as a row, even all-missing ones", {
  df2 <- df
  df2[3, crit] <- NA          # study C addresses nothing
  p <- reviewMatrix(df2, crit, color_by = "Type")
  expect_equal(length(unique(as.character(p$data$.study))), 3)
})

test_that("reviewMatrix draws a tile only for non-missing cells", {
  p <- reviewMatrix(df, crit, color_by = "Type")
  # long data carries a .present flag; 7 of the 9 cells are coded
  expect_equal(sum(p$data$.present), 7)
  expect_equal(nrow(p$data), 3 * length(crit))
})

test_that("reviewMatrix works without color_by (single fill)", {
  expect_s3_class(reviewMatrix(df, crit), "ggplot")
})

test_that("reviewMatrix appends counts to column headers when show_counts = TRUE", {
  p <- reviewMatrix(df, crit, color_by = "Type", show_counts = TRUE)
  labs <- levels(p$data$.criterion)
  expect_true(any(grepl("Accuracy \\(N=2\\)", labs)))   # A, B coded Accuracy
  expect_true(any(grepl("Ethics \\(N=3\\)", labs)))     # all three coded Ethics
})

test_that("reviewMatrix omits counts when show_counts = FALSE", {
  p <- reviewMatrix(df, crit, show_counts = FALSE)
  expect_false(any(grepl("N=", levels(p$data$.criterion))))
})

test_that("reviewMatrix accepts a custom study_id column", {
  df2 <- df
  names(df2)[1] <- "Ref"
  expect_s3_class(reviewMatrix(df2, crit, color_by = "Type", study_id = Ref), "ggplot")
})

test_that("reviewMatrix builds a Level legend from the `levels` mapping", {
  p <- reviewMatrix(df, crit, color_by = "Type",
                    levels = c(O = "Operationalized", D = "Discussed", M = "Mention"))
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("reviewMatrix errors on non-character cols", {
  expect_error(reviewMatrix(df, 1, color_by = "Type"), "character vector")
})

test_that("reviewMatrix errors on a missing column", {
  expect_error(reviewMatrix(df, c("Accuracy", "Nope"), color_by = "Type"), "not found")
  expect_error(reviewMatrix(df, crit, color_by = "Nope"), "not found")
})

test_that("reviewMatrix errors on a missing study_id column", {
  expect_error(reviewMatrix(df, crit, study_id = NoSuchId), "not found")
})

test_that("reviewMatrix builds without error end to end", {
  expect_no_error(ggplot2::ggplot_build(reviewMatrix(df, crit, color_by = "Type")))
})
