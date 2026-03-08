source("scripts/connection.R")

library(tidyverse)

options(scipen = 999)

# Read dataset raw

raw_df <- read_csv("data/raw/dataset_game_raw.csv")

# Standardisasi nama kolom

colnames(raw_df) <- tolower(gsub(" ", "_", colnames(raw_df)))

# Simpan ke database

dbWriteTable(
  con,
  "dataset_game_raw",
  raw_df,
  overwrite = TRUE,
  row.names = FALSE
)

print("Dataset raw berhasil dimasukkan ke database")

dbDisconnect(con)
