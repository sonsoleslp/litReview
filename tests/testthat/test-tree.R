df <- data.frame(
  StudyID = paste0("S", 1:6),
  Author  = paste0("A", 1:6),
  Top     = c("Alpha", "Alpha", "Alpha", "Beta", "Beta", "Beta"),
  Sub     = c("A1", "A1", "A2", "B1", "B1", "B2"),
  stringsAsFactors = FALSE
)

test_that("reviewTree returns a ggplot", {
  expect_s3_class(reviewTree(df, c("Top", "Sub")), "ggplot")
})

test_that("reviewTree works at one, two and three levels", {
  expect_s3_class(reviewTree(df, "Top"), "ggplot")
  expect_s3_class(reviewTree(df, c("Top", "Sub")), "ggplot")
  df3 <- df; df3$Leaf <- c("x", "y", "x", "y", "x", "y")
  expect_s3_class(reviewTree(df3, c("Top", "Sub", "Leaf")), "ggplot")
})

test_that("reviewTree builds without error, with and without members", {
  expect_no_error(ggplot2::ggplot_build(reviewTree(df, c("Top", "Sub"))))
  expect_no_error(ggplot2::ggplot_build(
    reviewTree(df, c("Top", "Sub"), show_members = FALSE)))
})

test_that("reviewTree splits multi-value cells across branches", {
  dfm <- data.frame(
    StudyID = c("S1", "S2"),
    Cat     = c("X\r\nY", "Y"),
    stringsAsFactors = FALSE
  )
  # S1 belongs to both X and Y -> two level-1 branches from one row
  p <- reviewTree(dfm, "Cat", show_members = FALSE)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("reviewTree annotates nodes with counts and percentages", {
  p <- reviewTree(df, c("Top", "Sub"), counts = "both", show_members = FALSE)
  nodelab <- p$layers[[2]]$data$label
  # Branches carry count and percent; the root is left un-annotated
  expect_true(any(grepl("\\(3, 50%\\)", nodelab)))     # Alpha: S1-S3
  expect_false(any(grepl("\\(6, 100%\\)", nodelab)))   # root has no total

  pc <- reviewTree(df, "Top", counts = "count", show_members = FALSE)
  expect_true(any(grepl("Alpha \\(3\\)", pc$layers[[2]]$data$label)))

  pp <- reviewTree(df, "Top", counts = "percent", show_members = FALSE)
  expect_true(any(grepl("50%", pp$layers[[2]]$data$label)))
})

test_that("reviewTree honours a custom root label", {
  p <- reviewTree(df, c("Top", "Sub"), root_label = "Corpus", show_members = FALSE)
  expect_true(any(grepl("Corpus", p$layers[[2]]$data$label)))
})

test_that("reviewTree rejects an invalid counts value", {
  expect_error(reviewTree(df, "Top", counts = "nope"))
})

test_that("reviewTree collects study members at the leaves", {
  p <- reviewTree(df, c("Top", "Sub"), study_id = Author)
  # The member layer's labels should mention the collected authors
  lab <- p$layers[[3]]$data$label
  expect_true(any(grepl("A1", lab)))
})

test_that("reviewTree honours a custom study_id", {
  expect_s3_class(reviewTree(df, c("Top", "Sub"), study_id = Author), "ggplot")
})

test_that("reviewTree errors on non-character cols", {
  expect_error(reviewTree(df, 1), "character vector")
})

test_that("reviewTree errors on a missing column", {
  expect_error(reviewTree(df, c("Top", "Nope")), "not found")
})

test_that("reviewTree errors on a missing study_id column", {
  expect_error(reviewTree(df, c("Top", "Sub"), study_id = NoSuchId), "not found")
})

test_that("reviewTree works on the bundled studies data", {
  data(studies)
  expect_s3_class(
    reviewTree(studies, c("InterventionType", "Intervention"), study_id = Author),
    "ggplot")
})
