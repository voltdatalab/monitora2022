update_ofensivos <- function(sql) {
  db <- db_connect()
  DBI::dbExecute(db, sql)
  pool::poolClose(db)
}
