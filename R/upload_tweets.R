upload_tweets <- function(tweets, sql_tweets) {
  db <- db_connect()

  # WRITE TABLE WITH TEMPORARY DATA FRESH FROM THE TWITTER API
  DBI::dbWriteTable(
    db, c("azmina_monitora", "temp"),
    tweets,
    row.names = FALSE
  )
  # CREATE INDEX FOR DATABASE TO INCREASE PERFORMANCE
  # DBI::dbExecute(db, "CREATE UNIQUE INDEX t_status_id_idx ON azmina_monitora.temp (id);")

  # INSERT TEMP DATA IN BASE
  DBI::dbExecute(db, "insert into azmina_monitora.base2022 select * from azmina_monitora.temp")

  # ADD TO TWEETS
  DBI::dbExecute(db, sql_tweets)

  DBI::dbExecute(db, "drop table azmina_monitora.temp")

  # DISCONNECT FROM DATABASE
  pool::poolClose(db)
}
