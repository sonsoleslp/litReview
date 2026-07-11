df <- data.frame(
  StudyID = c("S1", "S2", "S3", "S4", "S5"),
  Year    = c(2020, 2021, 2021, 2022, 2022),
  Design  = c("RCT", "Cohort", "RCT", "Case-control", "RCT"),
  Country = c("Spain", "UK", "Spain", "Germany", "UK"),
  Outcome = c("Pain\r\nFunction", "Pain", "Function", "Pain\r\nFunction", "Pain"),
  stringsAsFactors = FALSE
)

# -- theme_litreview ----------------------------------------------------------

test_that("theme_litreview returns a ggplot theme", {
  th <- theme_litreview()
  expect_s3_class(th, "theme")
})

test_that("theme_litreview accepts base_size", {
  th <- theme_litreview(base_size = 16)
  expect_s3_class(th, "theme")
})

# -- reviewWaffle -------------------------------------------------------------

test_that("reviewWaffle returns a ggplot", {
  p <- reviewWaffle(df, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewWaffle accepts custom ncol and colors", {
  p <- reviewWaffle(df, Design, ncol = 3, colors = c("red", "blue", "green"))
  expect_s3_class(p, "ggplot")
})

# -- reviewPie ----------------------------------------------------------------

test_that("reviewPie returns a ggplot (donut)", {
  p <- reviewPie(df, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewPie returns a ggplot (pie)", {
  p <- reviewPie(df, Design, donut = FALSE)
  expect_s3_class(p, "ggplot")
})

# -- reviewOverlap ------------------------------------------------------------

test_that("reviewOverlap returns a ggplot", {
  p <- reviewOverlap(df, Design, Country)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap handles multi-value columns", {
  p <- reviewOverlap(df, Outcome, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap errors on missing column", {
  expect_error(reviewOverlap(df, Design, NoSuchCol), "not found")
})

test_that("reviewOverlap studlabs = TRUE shows study IDs", {
  p <- reviewOverlap(df, Design, Country, studlabs = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap studlabs with custom study_id", {
  df2 <- df
  names(df2)[1] <- "ID"
  p <- reviewOverlap(df2, Design, Country, studlabs = TRUE, study_id = ID)
  expect_s3_class(p, "ggplot")
})

test_that("reviewOverlap accepts label_wrap (wrap and disable)", {
  expect_s3_class(reviewOverlap(df, Design, Country, label_wrap = 8), "ggplot")
  expect_s3_class(reviewOverlap(df, Design, Country, label_wrap = NULL), "ggplot")
})

test_that("wrap_labels wraps long strings and passes short ones through", {
  w <- litReview:::wrap_labels(10)
  expect_equal(w("short"), "short")
  expect_match(w("a very long label indeed"), "\n")
  # non-positive / non-finite / NULL widths disable wrapping
  expect_identical(litReview:::wrap_labels(NULL), identity)
  expect_identical(litReview:::wrap_labels(Inf), identity)
  expect_identical(litReview:::wrap_labels(0), identity)
})

# -- reviewTrend --------------------------------------------------------------

test_that("reviewTrend returns a ggplot", {
  p <- reviewTrend(df, Design)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend handles multi-value columns", {
  p <- reviewTrend(df, Outcome)
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend errors on missing year column", {
  expect_error(reviewTrend(df, Design, year_col = NoYear), "not found")
})

test_that("reviewTrend labels = 'count'", {
  p <- reviewTrend(df, Design, labels = "count")
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend labels = 'percent'", {
  p <- reviewTrend(df, Design, labels = "percent")
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend labels = 'both'", {
  p <- reviewTrend(df, Design, labels = "both")
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend labels = 'studies'", {
  p <- reviewTrend(df, Design, labels = "studies")
  expect_s3_class(p, "ggplot")
})

test_that("reviewTrend labels = 'studies' with custom study_id", {
  df2 <- data.frame(
    ID = paste0("A", 1:4),
    Year = c(2020, 2021, 2021, 2022),
    Type = c("X", "Y", "X", "Y"),
    stringsAsFactors = FALSE
  )
  p <- reviewTrend(df2, Type, labels = "studies", study_id = ID)
  expect_s3_class(p, "ggplot")
})

# -- reviewMap ----------------------------------------------------------------

test_that("reviewMap returns a ggplot", {
  p <- reviewMap(df)
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap accepts custom fill", {
  p <- reviewMap(df, fill = "#FF0000")
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap resolves country aliases", {
  df2 <- data.frame(
    StudyID = c("S1", "S2"),
    Country = c("United States", "United Kingdom"),
    stringsAsFactors = FALSE
  )
  p <- reviewMap(df2)
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap resolves ISO 2- and 3-letter codes without warning", {
  df2 <- data.frame(
    StudyID = paste0("S", 1:4),
    Country = c("USA", "GBR", "DE", "ES"),
    stringsAsFactors = FALSE
  )
  expect_no_warning(p <- reviewMap(df2))
  expect_s3_class(p, "ggplot")
})

test_that("reviewMap warns about unrecognised countries", {
  df2 <- data.frame(
    StudyID = c("S1", "S2"),
    Country = c("Spain", "Freedonia"),
    stringsAsFactors = FALSE
  )
  expect_warning(reviewMap(df2), "not recognised")
})

test_that("normalise_countries resolves ISO codes against world regions", {
  wr <- unique(ggplot2::map_data("world")$region)
  expect_equal(
    litReview:::normalise_countries(c("US", "GBR", "DEU", "USA"), wr),
    c("USA", "UK", "Germany", "USA"))
})

# -- composability ------------------------------------------------------------

test_that("new plots are composable with ggplot2 layers", {
  p <- reviewWaffle(df, Design) + ggplot2::labs(title = "Waffle")
  expect_equal(p$labels$title, "Waffle")

  p2 <- reviewTrend(df, Design) + ggplot2::labs(title = "Trend")
  expect_equal(p2$labels$title, "Trend")
})

# -- country aliases ----------------------------------------------------------

test_that("normalise_countries resolves known aliases", {
  expect_equal(
    litReview:::normalise_countries(c("United States", "UK", "Czechia")),
    c("USA", "UK", "Czech Republic")
  )
})

test_that("normalise_countries passes through unknown names unchanged", {
  expect_equal(litReview:::normalise_countries("Narnia"), "Narnia")
})
