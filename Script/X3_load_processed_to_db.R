source("scripts/connection.R")

library(tidyverse)

# ================================

# READ PROCESSED DATA

# ================================

tbl_games <- read_csv("data/processed/tbl_games.csv")
tbl_users <- read_csv("data/processed/tbl_users.csv")
tbl_reviews <- read_csv("data/processed/tbl_reviews.csv")

tbl_developers <- read_csv("data/processed/tbl_developers.csv")
tbl_publishers <- read_csv("data/processed/tbl_publishers.csv")
tbl_genres <- read_csv("data/processed/tbl_genres.csv")
tbl_platforms <- read_csv("data/processed/tbl_platforms.csv")

# ================================

# TRUNCATE TABLE

# ================================

dbExecute(con, "SET FOREIGN_KEY_CHECKS = 0")

dbExecute(con, "TRUNCATE TABLE tbl_reviews")
dbExecute(con, "TRUNCATE TABLE tbl_games")
dbExecute(con, "TRUNCATE TABLE tbl_users")
dbExecute(con, "TRUNCATE TABLE tbl_developers")
dbExecute(con, "TRUNCATE TABLE tbl_publishers")
dbExecute(con, "TRUNCATE TABLE tbl_genres")
dbExecute(con, "TRUNCATE TABLE tbl_platforms")

dbExecute(con, "SET FOREIGN_KEY_CHECKS = 1")

# ================================

# LOAD DATA KE DATABASE

# ================================

dbWriteTable(con, "tbl_games", tbl_games, append = TRUE, row.names = FALSE)
dbWriteTable(con, "tbl_users", tbl_users, append = TRUE, row.names = FALSE)

dbWriteTable(con, "tbl_developers", tbl_developers, append = TRUE, row.names = FALSE)
dbWriteTable(con, "tbl_publishers", tbl_publishers, append = TRUE, row.names = FALSE)
dbWriteTable(con, "tbl_genres", tbl_genres, append = TRUE, row.names = FALSE)
dbWriteTable(con, "tbl_platforms", tbl_platforms, append = TRUE, row.names = FALSE)

dbWriteTable(con, "tbl_reviews", tbl_reviews, append = TRUE, row.names = FALSE)

print("Data processed berhasil dimasukkan ke database")

dbDisconnect(con)
