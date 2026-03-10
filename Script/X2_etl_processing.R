source("scripts/connection.R")

library(tidyverse)
library(lubridate)
library(stringr)

options(scipen = 999)

# ================================

# EXTRACT DATA

# ================================

raw_df <- dbReadTable(con, "dataset_game_raw")

colnames(raw_df) <- tolower(gsub(" ", "_", colnames(raw_df)))

# ================================

# DATA CLEANING

# ================================

clean_df <- raw_df %>%
  mutate(across(
    c(game_title, developers, publishers, genres, platforms, age_rating, username),
    ~ str_squish(.)
  ))

clean_df <- clean_df %>%
  mutate(across(where(is.character), ~ na_if(., "")))

clean_df <- clean_df %>%
  mutate(
    release_date = dmy(release_date),
    review_date  = ymd(review_date)
  )

clean_df <- clean_df %>%
  mutate(metascore = as.integer(metascore))

clean_df <- clean_df %>%
  mutate(
    developers = if_else(is.na(developers),
                         "Unknown Developer",
                         developers),
    publishers = if_else(is.na(publishers),
                         "Unknown Publisher",
                         publishers)
  )

# ================================

# FILTER REVIEW

# ================================

review_filtered <- clean_df %>%
  filter(!is.na(review)) %>%
  mutate(
    char_count = nchar(review),
    has_letter = str_detect(review, "[A-Za-z]"),
    rating_only = str_detect(
      review,
      "^\s*[0-9]+([\.,][0-9]+)?\s*/\s*[0-9]+([\.,][0-9]+)?\s*$"
    )
  ) %>%
  filter(char_count >= 3 & (has_letter | rating_only)) %>%
  select(-char_count, -has_letter, -rating_only)

# ================================

# NORMALISASI

# ================================

clean_df <- clean_df %>%
  mutate(game_id = dense_rank(game_title))

game_developers_long <- clean_df %>%
  select(game_id, developers) %>%
  separate_rows(developers, sep = ",") %>%
  mutate(developers = str_trim(developers)) %>%
  distinct()

game_publishers_long <- clean_df %>%
  select(game_id, publishers) %>%
  separate_rows(publishers, sep = ",") %>%
  mutate(publishers = str_trim(publishers)) %>%
  distinct()

game_genres_long <- clean_df %>%
  select(game_id, genres) %>%
  separate_rows(genres, sep = ",") %>%
  mutate(genres = str_trim(genres)) %>%
  distinct()

game_platforms_long <- clean_df %>%
  select(game_id, platforms) %>%
  separate_rows(platforms, sep = ",") %>%
  mutate(platforms = str_trim(platforms)) %>%
  distinct()

# ================================

# MASTER TABLE

# ================================

tbl_developers <- game_developers_long %>%
  distinct(developers) %>%
  arrange(developers) %>%
  mutate(developer_id = row_number()) %>%
  select(developer_id, developer_name = developers)

tbl_publishers <- game_publishers_long %>%
  distinct(publishers) %>%
  arrange(publishers) %>%
  mutate(publisher_id = row_number()) %>%
  select(publisher_id, publisher_name = publishers)

tbl_genres <- game_genres_long %>%
  distinct(genres) %>%
  arrange(genres) %>%
  mutate(genre_id = row_number()) %>%
  select(genre_id, genre_name = genres)

tbl_platforms <- game_platforms_long %>%
  distinct(platforms) %>%
  arrange(platforms) %>%
  mutate(platform_id = row_number()) %>%
  select(platform_id, platform_name = platforms)

tbl_games <- clean_df %>%
  select(
    game_id,
    game_title,
    game_url,
    game_image_url,
    game_video_preview_url,
    about,
    metascore,
    release_date,
    age_rating,
    rating_exceptional,
    rating_recommended,
    rating_meh,
    rating_skip
  ) %>%
  distinct(game_id, .keep_all = TRUE)

tbl_users <- review_filtered %>%
  select(username) %>%
  distinct() %>%
  arrange(username) %>%
  mutate(user_id = row_number()) %>%
  select(user_id, username)

tbl_reviews <- review_filtered %>%
  left_join(tbl_users, by = "username") %>%
  mutate(review_id = row_number()) %>%
  select(review_id, game_id, user_id, review_text = review, review_date)

# ================================

# SIMPAN KE PROCESSED

# ================================

write_csv(tbl_games, "data/processed/tbl_games.csv")
write_csv(tbl_users, "data/processed/tbl_users.csv")
write_csv(tbl_reviews, "data/processed/tbl_reviews.csv")

write_csv(tbl_developers, "data/processed/tbl_developers.csv")
write_csv(tbl_publishers, "data/processed/tbl_publishers.csv")
write_csv(tbl_genres, "data/processed/tbl_genres.csv")
write_csv(tbl_platforms, "data/processed/tbl_platforms.csv")

print("Data berhasil diproses dan disimpan ke folder processed")

dbDisconnect(con)
