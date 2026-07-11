skip_if_not_installed("ggupset")

df <- data.frame(
  StudyID = paste0("S", 1:5),
  Outcome = c("Pain\r\nFunction", "Pain", "Function",
              "Pain\r\nFunction\r\nQoL", "QoL"),
  stringsAsFactors = FALSE
)

test_that("reviewUpset returns a ggplot", {
  expect_s3_class(reviewUpset(df, Outcome), "ggplot")
})

test_that("reviewUpset builds one distinct-value set per study", {
  p <- reviewUpset(df, Outcome)
  expect_true(all(c("StudyID", "Sets") %in% names(p$data)))
  expect_type(p$data$Sets, "list")
  expect_equal(nrow(p$data), 5)
  # S1 reports Pain + Function; stored sorted and de-duplicated
  s1 <- p$data$Sets[[which(p$data$StudyID == "S1")]]
  expect_setequal(s1, c("Function", "Pain"))
  s4 <- p$data$Sets[[which(p$data$StudyID == "S4")]]
  expect_setequal(s4, c("Function", "Pain", "QoL"))
})

test_that("reviewUpset accepts both sort orders", {
  expect_s3_class(reviewUpset(df, Outcome, sort_by = "freq"), "ggplot")
  expect_s3_class(reviewUpset(df, Outcome, sort_by = "degree"), "ggplot")
})

test_that("reviewUpset errors on invalid sort_by", {
  expect_error(reviewUpset(df, Outcome, sort_by = "nope"))
})

test_that("reviewUpset errors on a missing column", {
  expect_error(reviewUpset(df, NoSuchCol), "not found")
})

test_that("reviewUpset errors when everything is missing", {
  df_empty <- data.frame(StudyID = c("S1", "S2"), Outcome = c(NA, NA),
                         stringsAsFactors = FALSE)
  expect_error(reviewUpset(df_empty, Outcome), "No non-missing")
})

test_that("reviewUpset keeps NAs as a set member when na.rm = FALSE", {
  df_na <- df
  df_na$Outcome[2] <- NA
  p <- reviewUpset(df_na, Outcome, na.rm = FALSE, na_label = "Not reported")
  expect_true("Not reported" %in% unique(unlist(p$data$Sets)))
})

test_that("reviewUpset honours a custom study_id column", {
  df2 <- df
  names(df2)[1] <- "ID"
  p <- reviewUpset(df2, Outcome, study_id = ID)
  expect_s3_class(p, "ggplot")
  expect_true("ID" %in% names(p$data))
})

test_that("reviewUpset builds without error", {
  expect_no_error(ggplot2::ggplot_build(reviewUpset(df, Outcome)))
})

test_that("reviewUpset is composable with ggplot2 layers", {
  p <- reviewUpset(df, Outcome) + ggplot2::labs(title = "Combinations")
  expect_equal(p$labels$title, "Combinations")
})

test_that("reviewUpset works on the bundled studies data", {
  data(studies)
  expect_s3_class(reviewUpset(studies, Outcome), "ggplot")
})
