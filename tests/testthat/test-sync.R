test_that("sync() errors with no inputs", {
  expect_error(sync(), "At least one")
})

test_that("sync() returns a data frame with a single source", {
  df <- data.frame(participant_id = 1:3, age = c(25, 30, 35))
  result <- sync(tallie = df)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3L)
})

test_that("sync() joins two sources by participant_id", {
  tallie <- data.frame(participant_id = 1:3, age = c(25, 30, 35))
  zeit   <- data.frame(participant_id = 1:3, is5 = c(0.8, 0.7, 0.9))
  result <- sync(tallie = tallie, zeit = zeit)
  expect_equal(ncol(result), 3L)
  expect_true("age" %in% names(result))
  expect_true("is5" %in% names(result))
})

test_that("sync() respects custom id_col", {
  tallie <- data.frame(pid = 1:2, sex = c("M", "F"))
  slumb  <- data.frame(pid = 1:2, tst = c(420, 390))
  result <- sync(tallie = tallie, slumb = slumb, id_col = "pid")
  expect_equal(names(result), c("pid", "sex", "tst"))
})
