db_connect <- function(senha_db = Sys.getenv("DB_PASSWORD")) {
  pool::dbPool(
    RPostgreSQL::PostgreSQL(),
    dbname = "monitordb",
    host = "monitordb.c34gb8x0kzzf.us-east-1.rds.amazonaws.com",
    port = 5432,
    user = "voltdatalab",
    password = senha_db
  )
}

# DBI::dbGetQuery(db, "SELECT table_name FROM information_schema.tables WHERE table_schema='azmina_monitora'")

# DBI::dbGetQuery(db, "select * from azmina_monitora.temp")
