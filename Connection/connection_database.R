library(DBI)
library(RMariaDB)

con <- dbConnect(
  RMariaDB::MariaDB(),
  dbname = "game",
  user = "root",
  password = "",
  host = "127.0.0.1",
  port = 3306
)

print("Koneksi database berhasil")
