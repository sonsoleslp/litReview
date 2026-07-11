skip_if_not_installed("RColorBrewer")

test_that("is_brewer_palette recognises palette names only", {
  expect_true(litReview:::is_brewer_palette("Set2"))
  expect_true(litReview:::is_brewer_palette("Blues"))
  expect_false(litReview:::is_brewer_palette("#ff0000"))
  expect_false(litReview:::is_brewer_palette(c("Set2", "Set1")))
  expect_false(litReview:::is_brewer_palette("NotAPalette"))
  expect_false(litReview:::is_brewer_palette(NA_character_))
})

test_that("resolve_palette expands a brewer name and passes vectors through", {
  cols <- litReview:::resolve_palette("Set2", 4)
  expect_length(cols, 4)
  expect_true(all(grepl("^#", cols)))
  # A literal colour vector is returned unchanged
  expect_identical(litReview:::resolve_palette(c("#111111", "#222222"), 2),
                   c("#111111", "#222222"))
  # Non-brewer single strings pass through untouched
  expect_identical(litReview:::resolve_palette("#7BB0D1", 5), "#7BB0D1")
})

test_that("recycle_colors resolves brewer names", {
  cols <- litReview:::recycle_colors("Dark2", 3)
  expect_length(cols, 3)
  expect_true(all(grepl("^#", cols)))
})

test_that("discrete plots accept a ColorBrewer palette name", {
  data(studies)
  expect_s3_class(reviewWaffle(studies, Design, colors = "Set2"), "ggplot")
  expect_s3_class(reviewPie(studies, Design, colors = "Dark2"), "ggplot")
  expect_s3_class(reviewTrend(studies, Design, colors = "Set1"), "ggplot")
  expect_s3_class(
    reviewStackedBar(studies, Design, RiskOfBias, fill = "Set2"), "ggplot")
  expect_s3_class(
    reviewTree(studies, c("InterventionType", "Intervention"),
               study_id = Author, colors = "Paired"), "ggplot")
})

test_that("reviewBar expands a brewer palette across bars", {
  data(studies)
  p <- reviewBar(studies, Design, fill = "Set2")
  b <- ggplot2::ggplot_build(p)
  bar_fills <- unique(b$data[[2]]$fill)
  expect_gt(length(bar_fills), 1)          # one colour per bar, not a single fill
})

test_that("gradient fills accept a sequential brewer palette", {
  data(studies)
  expect_no_error(ggplot2::ggplot_build(
    reviewOverlap(studies, Design, Setting, fill = "Blues")))
})

test_that("treemap and alluvial accept brewer names when available", {
  skip_if_not_installed("treemapify")
  data(studies)
  expect_s3_class(reviewTreemap(studies, Design, colors = "Accent"), "ggplot")
})

test_that("reviewMap accepts a sequential brewer palette when available", {
  skip_if_not_installed("maps")
  data(studies)
  expect_no_error(ggplot2::ggplot_build(reviewMap(studies, fill = "YlGnBu")))
})
