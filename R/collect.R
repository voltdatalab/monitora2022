collect <- function(username) {
  tw <- get_tweets(username)
  db <- db_connect()
  db_upload(db, tw, "monitora2020_twitter")
  pool::poolClose(db)
}