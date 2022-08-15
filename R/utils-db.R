db_connect <- function(...) {
  pool::dbPool(
    RPostgreSQL::PostgreSQL(),
    dbname = "monitordb",
    host = "monitordb.c34gb8x0kzzf.us-east-1.rds.amazonaws.com",
    port = 5432,
    user = "voltdatalab",
    password = Sys.getenv("DB_PASSWORD")
  )
}

# DBI::dbGetQuery(db, "SELECT table_name FROM information_schema.tables WHERE table_schema='azmina_monitora'")

# DBI::dbGetQuery(db, "select * from azmina_monitora.temp")
