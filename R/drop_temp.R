drop_temp <- function() {
  db <- db_connect()
  DBI::dbExecute(db, "drop table azmina_monitora.temp")
  pool::poolClose(db)
}