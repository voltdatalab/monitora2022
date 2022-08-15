test_that("db has password", {
  senha_db <- Sys.getenv("DB_PASSWORD")
  expect_gt(stringr::str_length(senha_db), 0)
})
