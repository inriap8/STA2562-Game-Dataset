# =========================
# LIBRARY
# =========================
library(DBI)
library(RMariaDB)
library(dplyr)

# =========================
# HELPER
# =========================
`%||%` <- function(a, b) {
  if (!is.null(a) && length(a) > 0 && !is.na(a)) a else b
}

safe_query_factory <- function(con) {
  function(sql, params = NULL) {
    tryCatch({
      if (!DBI::dbIsValid(con)) stop("Koneksi database tidak valid / terputus.")
      df <- if (is.null(params)) DBI::dbGetQuery(con, sql) else DBI::dbGetQuery(con, sql, params = params)
      for (nm in names(df)) if (inherits(df[[nm]], "integer64")) df[[nm]] <- suppressWarnings(as.numeric(df[[nm]]))
      df
    }, error = function(e) data.frame(error = conditionMessage(e), stringsAsFactors = FALSE))
  }
}

plotly_empty <- function(msg = "No data") {
  plot_ly() %>% layout(
    xaxis = list(visible = FALSE),
    yaxis = list(visible = FALSE),
    annotations = list(
      list(text = msg, x = 0.5, y = 0.5, showarrow = FALSE)
    )
  )
}

make_stat_card <- function(label, value, sub, badge, color){
  stat_class  <- paste0("mini-", color)
  badge_class <- paste0("badge-", color)
  
  div(class = paste("mini-stat", stat_class),
      div(class="mini-label", label),
      div(class="mini-value", value),
      div(class="mini-sub", sub),
      div(class=paste("badge-soft", badge_class), badge)
  )
}

make_rank_card <- function(card_class, status, game, value, note, label){
  div(class = card_class,
      div(class="rank-title", HTML(paste0("Status: <b>", status, "</b>"))),
      div(class="rank-big", paste0("Game: ", game)),
      div(class="rank-pill", paste0(label, ": ", value)),
      div(class="rank-note", note)
  )
}

# =========================
# SERVER
# =========================
server <- function(input, output, session) {
  
  con <- dbConnect(
    RMariaDB::MariaDB(),
    host     = "127.0.0.1",
    port     = 3306,
    user     = "root",
    password = "",
    dbname   = "game"
  )
  
  onStop(function() if (DBI::dbIsValid(con)) DBI::dbDisconnect(con))
  
  safe_query <- safe_query_factory(con)
  
  # =============================
  # HOME
  # =============================
  output$total_game <- renderText({
    df <- safe_query("SELECT COUNT(*) AS total FROM tbl_games")
    if ("error" %in% names(df) || nrow(df) == 0) "-" else df$total[1]
  })
  
  output$total_review <- renderText({
    df <- safe_query("SELECT COUNT(*) AS total FROM tbl_reviews")
    if ("error" %in% names(df) || nrow(df) == 0) "-" else df$total[1]
  })
  
  top_games <- reactive({
    safe_query("
      SELECT game_title, about, game_image_url, game_video_preview_url, game_url
      FROM tbl_games
      ORDER BY metascore DESC
      LIMIT 5
    ")
  })
  
  games_by_age <- reactive({
    safe_query("
      SELECT *
      FROM (
          SELECT 
              g.game_id,
              g.game_title,
              g.age_rating,
              g.game_image_url,
              g.game_url,
      
              ROUND(
                  (
                      (g.rating_exceptional * 4) +
                      (g.rating_recommended * 3) +
                      (g.rating_meh * 2) +
                      (g.rating_skip * 1)
                  ) /
                  NULLIF(
                      (g.rating_exceptional +
                       g.rating_recommended +
                       g.rating_meh +
                       g.rating_skip), 0
                  ), 2
              ) AS game_score,
      
              ROW_NUMBER() OVER (
                  PARTITION BY g.age_rating
                  ORDER BY
                      ROUND(
                          (
                              (g.rating_exceptional * 4) +
                              (g.rating_recommended * 3) +
                              (g.rating_meh * 2) +
                              (g.rating_skip * 1)
                          ) /
                          NULLIF(
                              (g.rating_exceptional +
                               g.rating_recommended +
                               g.rating_meh +
                               g.rating_skip), 0
                          ), 2
                      ) DESC
              ) AS rn
      
          FROM tbl_games g
          WHERE g.age_rating NOT IN ('Not Rated', 'Rating Pending')
      
      ) ranked
      WHERE rn = 1
      ORDER BY game_score DESC;
          ")
  })
  
  games_by_genre <- reactive({
    safe_query("
      SELECT *
      FROM (
          SELECT 
              ge.genre_name,
              g.game_id,
              g.game_title,
              g.game_image_url,
              g.game_url,
      
              ROUND(
                  (
                      (g.rating_exceptional * 4) +
                      (g.rating_recommended * 3) +
                      (g.rating_meh * 2) +
                      (g.rating_skip * 1)
                  ) /
                  NULLIF(
                      (g.rating_exceptional +
                       g.rating_recommended +
                       g.rating_meh +
                       g.rating_skip), 0
                  ), 2
              ) AS game_score,
      
              ROW_NUMBER() OVER (
                  PARTITION BY ge.genre_id
                  ORDER BY
                      ROUND(
                          (
                              (g.rating_exceptional * 4) +
                              (g.rating_recommended * 3) +
                              (g.rating_meh * 2) +
                              (g.rating_skip * 1)
                          ) /
                          NULLIF(
                              (g.rating_exceptional +
                               g.rating_recommended +
                               g.rating_meh +
                               g.rating_skip), 0
                          ), 2
                      ) DESC
              ) AS rn
      
          FROM tbl_games g
          JOIN tbl_game_genres gg ON g.game_id = gg.game_id
          JOIN tbl_genres ge ON gg.genre_id = ge.genre_id
      
      ) ranked
      WHERE rn = 1
      ORDER BY game_score DESC
      LIMIT 6;")
  })
  
  # Output Banner
  current_index <- reactiveVal(1)
  
  observe({
    
    invalidateLater(5000, session)  # 5 detik
    
    data <- top_games()
    
    req(!is.null(data))
    req(nrow(data) > 0)
    req(!("error" %in% names(data)))
    
    isolate({
      
      i <- current_index()
      
      if (i < nrow(data)) {
        current_index(i + 1)
      } else {
        current_index(1)
      }
      
    })
    
  })
  
  observeEvent(input$next_btn, {
    data <- top_games()
    if (is.null(data) || nrow(data) == 0 || ("error" %in% names(data))) return(NULL)
    i <- current_index()
    if (i < nrow(data)) current_index(i + 1) else current_index(1)
  })
  
  observeEvent(input$prev_btn, {
    data <- top_games()
    if (is.null(data) || nrow(data) == 0 || ("error" %in% names(data))) return(NULL)
    i <- current_index()
    if (i > 1) current_index(i - 1) else current_index(nrow(data))
  })
  
  output$banner_container <- renderUI({
    
    data <- top_games()
    
    if (is.null(data) || nrow(data) == 0) {
      return(div("Data kosong"))
    }
    
    i <- current_index()
    
    video_url <- data$game_video_preview_url[i]
    image_url <- data$game_image_url[i]
    
    div(
      class = "banner-container",
      
      if (!is.null(video_url) && video_url != "") {
        tags$video(
          class = "banner-video",
          src = video_url,
          autoplay = NA,
          loop = NA,
          muted = NA
        )
      } else {
        tags$img(
          class = "banner-video",
          src = image_url
        )
      },
      
      div(class = "banner-overlay"),
      
      div(
        class = "banner-content",
        
        div(class = "banner-title", data$game_title[i]),
        
        div(class = "banner-desc",
            paste0(substr(data$about[i] %||% "", 1, 200), "...")
        ),
        
        br(),
        
        a("More Info",
          href = data$game_url[i],
          target = "_blank",
          class = "btn-modern"
        )
      )
    )
  })
  
  # Output Age Recommendation 
  output$age_recommendation <- renderUI({
    
    data <- games_by_age()
    
    if (is.null(data) || nrow(data) == 0) {
      return(div("Data kosong"))
    }
    
    cards <- lapply(1:min(6, nrow(data)), function(i) {
      div(
        class = "card-age",
        onclick = paste0("window.open('", data$game_url[i], "', '_blank')"),
        style = "cursor:pointer;",
        
        tags$img(src = data$game_image_url[i]),
        div(class="game-title", data$game_title[i]),
        div(class="game-desc", data$age_rating[i])
      )
    })
    
    div(class = "card-container", cards)
  })
  
  # Output Genre Recommendation
  output$genre_recommendation <- renderUI({
    
    data <- games_by_genre()
    
    if (is.null(data) || nrow(data) == 0) {
      return(div("Data kosong"))
    }
    
    cards <- lapply(1:min(6, nrow(data)), function(i) {
      div(
        class = "card-age", 
        onclick = paste0("window.open('", data$game_url[i], "', '_blank')"),
        style = "cursor:pointer;",
        
        tags$img(src = data$game_image_url[i]),
        div(class="game-title", data$game_title[i]),
        div(class="game-desc", data$genre[i])
      )
    })
    
    div(class = "card-container", cards)
  })
  
  # =============================
  # SEARCH + OVERVIEW 
  # =============================
  
  q_search <- "
  SELECT 
    g.game_id,
    g.game_title,
    g.game_url,
    g.age_rating,

    ROUND(
        (
            (g.rating_exceptional * 4) +
            (g.rating_recommended * 3) +
            (g.rating_meh * 2) +
            (g.rating_skip * 1)
        ) /
        NULLIF(
            (g.rating_exceptional +
             g.rating_recommended +
             g.rating_meh +
             g.rating_skip), 0
        ), 2
    ) AS game_score,

    GROUP_CONCAT(DISTINCT ge.genre_name SEPARATOR ', ') AS genres,
    GROUP_CONCAT(DISTINCT p.platform_name SEPARATOR ', ') AS platforms

FROM tbl_games g
LEFT JOIN tbl_game_genres gg ON g.game_id = gg.game_id
LEFT JOIN tbl_genres ge ON gg.genre_id = ge.genre_id
LEFT JOIN tbl_game_platforms gp ON g.game_id = gp.game_id
LEFT JOIN tbl_platforms p ON gp.platform_id = p.platform_id

WHERE
    (? IS NULL OR ge.genre_name = ?)
AND (? IS NULL OR p.platform_name = ?)
AND (? IS NULL OR g.age_rating = ?)
AND (
    ? IS NULL OR
    ROUND(
        (
            (g.rating_exceptional * 4) +
            (g.rating_recommended * 3) +
            (g.rating_meh * 2) +
            (g.rating_skip * 1)
        ) /
        NULLIF(
            (g.rating_exceptional +
             g.rating_recommended +
             g.rating_meh +
             g.rating_skip), 0
        ), 2
    ) >= ?
)

GROUP BY g.game_id
ORDER BY g.game_title;
"

q_popular_genre <- "
    SELECT ge.genre_name, COUNT(r.review_id) AS total_review
    FROM tbl_genres ge
    JOIN tbl_game_genres gg ON ge.genre_id = gg.genre_id
    JOIN tbl_reviews r ON gg.game_id = r.game_id
    GROUP BY ge.genre_id
    ORDER BY total_review DESC
    LIMIT 1;
  "

q_genre_pie <- "
    SELECT
      ge.genre_name,
      COUNT(r.review_id) AS total_review,
      ROUND(COUNT(r.review_id) * 100.0 / (SELECT COUNT(*) FROM tbl_reviews), 2) AS percentage
    FROM tbl_genres ge
    JOIN tbl_game_genres gg ON ge.genre_id = gg.genre_id
    JOIN tbl_reviews r ON gg.game_id = r.game_id
    GROUP BY ge.genre_id
    ORDER BY total_review DESC;
  "

q_top10_score <- "
    SELECT
      g.game_id,
      g.game_title,
      ROUND(
        (
          (g.rating_exceptional * 4) +
          (g.rating_recommended * 3) +
          (g.rating_meh * 2) +
          (g.rating_skip * 1)
        ) /
        NULLIF(
          (g.rating_exceptional +
           g.rating_recommended +
           g.rating_meh +
           g.rating_skip), 0
        ), 2
      ) AS score,
      (g.rating_exceptional + g.rating_recommended + g.rating_meh + g.rating_skip) AS total_vote,
      g.metascore
    FROM tbl_games g
    ORDER BY score DESC;
  "

q_best_score <- "
    SELECT g.game_title,
      ROUND(
        (
          (g.rating_exceptional * 4) +
          (g.rating_recommended * 3) +
          (g.rating_meh * 2) +
          (g.rating_skip * 1)
        ) /
        NULLIF(
          (g.rating_exceptional +
           g.rating_recommended +
           g.rating_meh +
           g.rating_skip), 0
        ), 2
      ) AS score
    FROM tbl_games g
    ORDER BY score DESC
    LIMIT 1;
  "

q_best_metascore <- "
    SELECT game_title, metascore
    FROM tbl_games
    WHERE metascore IS NOT NULL
    ORDER BY metascore DESC
    LIMIT 1;
  "

q_top10_reviewed <- "
    SELECT g.game_id, g.game_title, COUNT(r.review_id) AS total_review
    FROM tbl_games g
    JOIN tbl_reviews r ON g.game_id = r.game_id
    GROUP BY g.game_id, g.game_title
    ORDER BY total_review DESC
    LIMIT 10;
  "

q_latest5_reviews_by_game <- "
    SELECT u.username, r.review_text, r.review_date
    FROM tbl_reviews r
    JOIN tbl_users u ON r.user_id = u.user_id
    WHERE r.game_id = ?
    ORDER BY r.review_date DESC
    LIMIT 5;
  "

q_release_trend <- "
    SELECT YEAR(release_date) AS release_year, COUNT(*) AS total_game
    FROM tbl_games
    WHERE release_date IS NOT NULL
    GROUP BY YEAR(release_date)
    ORDER BY release_year;
  "

q_popular_game_2016 <- "
    SELECT g.game_title, COUNT(r.review_id) AS total_review
    FROM tbl_games g
    JOIN tbl_reviews r ON g.game_id = r.game_id
    WHERE g.release_date IS NOT NULL AND YEAR(g.release_date) = 2016
    GROUP BY g.game_id, g.game_title
    ORDER BY total_review DESC
    LIMIT 1;
  "

q_top_platform_played <- "
    SELECT p.platform_name, COUNT(*) AS total_usage
    FROM tbl_game_platforms gp
    JOIN tbl_platforms p ON gp.platform_id = p.platform_id
    GROUP BY p.platform_id, p.platform_name
    ORDER BY total_usage DESC
    LIMIT 1;
  "

q_top_age_rating <- "
    SELECT age_rating, COUNT(*) AS total_game
    FROM tbl_games
    WHERE age_rating IS NOT NULL AND TRIM(age_rating) <> ''
    GROUP BY age_rating
    ORDER BY total_game DESC
    LIMIT 1;
  "

q_score_dist <- "
    SELECT
      ROUND(
        (
          (rating_exceptional * 4) +
          (rating_recommended * 3) +
          (rating_meh * 2) +
          (rating_skip * 1)
        ) /
        NULLIF((rating_exceptional + rating_recommended + rating_meh + rating_skip), 0), 2
      ) AS score
    FROM tbl_games
    WHERE (rating_exceptional + rating_recommended + rating_meh + rating_skip) > 0;
  "
q_best_avg_genre <- "
SELECT 
  ge.genre_name,
  ROUND(AVG(
    (
      (g.rating_exceptional * 4) +
      (g.rating_recommended * 3) +
      (g.rating_meh * 2) +
      (g.rating_skip * 1)
    ) /
    NULLIF(
      (g.rating_exceptional +
       g.rating_recommended +
       g.rating_meh +
       g.rating_skip), 0
    )
  ), 2) AS avg_score
FROM tbl_games g
JOIN tbl_game_genres gg ON g.game_id = gg.game_id
JOIN tbl_genres ge ON gg.genre_id = ge.genre_id
WHERE (g.rating_exceptional + g.rating_recommended + g.rating_meh + g.rating_skip) > 0
GROUP BY ge.genre_name
ORDER BY avg_score DESC
LIMIT 1;
"


# Platform Popularity
q_platform_popularity <- "
SELECT 
  p.platform_name,
  COUNT(*) AS total_game
FROM tbl_game_platforms gp
JOIN tbl_platforms p ON gp.platform_id = p.platform_id
GROUP BY p.platform_name
ORDER BY total_game DESC
LIMIT 10;
"

# Genre Average Score
q_genre_avg_score <- "
SELECT 
  ge.genre_name,
  ROUND(AVG(
    (
      (g.rating_exceptional * 4) +
      (g.rating_recommended * 3) +
      (g.rating_meh * 2) +
      (g.rating_skip * 1)
    ) /
    NULLIF(
      (g.rating_exceptional +
       g.rating_recommended +
       g.rating_meh +
       g.rating_skip),0
    )
  ),2) AS avg_score
FROM tbl_games g
JOIN tbl_game_genres gg ON g.game_id = gg.game_id
JOIN tbl_genres ge ON gg.genre_id = ge.genre_id
GROUP BY ge.genre_name
ORDER BY avg_score DESC
LIMIT 10;
"

q_meta_vs_user <- "
SELECT 
  metascore,

  (
    (COALESCE(rating_exceptional,0) * 4) +
    (COALESCE(rating_recommended,0) * 3) +
    (COALESCE(rating_meh,0) * 2) +
    (COALESCE(rating_skip,0) * 1)
  ) /
  (
    COALESCE(rating_exceptional,0) +
    COALESCE(rating_recommended,0) +
    COALESCE(rating_meh,0) +
    COALESCE(rating_skip,0)
  ) AS user_score

FROM tbl_games

WHERE metascore IS NOT NULL
AND (
  COALESCE(rating_exceptional,0) +
  COALESCE(rating_recommended,0) +
  COALESCE(rating_meh,0) +
  COALESCE(rating_skip,0)
) > 0
"

# ===== OVERVIEW OUTPUTS =====

# Most Popular Genre
output$ov_most_popular_genre <- renderUI({
  df <- safe_query(q_popular_genre)
  if ("error" %in% names(df) || nrow(df) == 0) {
    make_stat_card(
      "Most Popular Genre",
      "-",
      "Genre data not available.",
      "Top Genre",
      "blue"
    )
  } else {
    make_stat_card(
      "Most Popular Genre",
      df$genre_name[1],
      paste0("Total Reviews: ", df$total_review[1]),
      "Top Genre",
      "blue"
    )
  }
})


# Popular Game 2016
output$ov_stat_2016 <- renderUI({
  df <- safe_query(q_popular_game_2016)
  if ("error" %in% names(df) || nrow(df) == 0) {
    make_stat_card(
      "Top Game of 2016",
      "-",
      "No data available for 2016.",
      "Top Game",
      "green"
    )
  } else {
    make_stat_card(
      "Top Game of 2016",
      df$game_title[1],
      paste0("Total Reviews: ", df$total_review[1]),
      "Top Game",
      "green"
    )
  }
})

# Platform Terbanyak Dimainkan
output$ov_stat_platform <- renderUI({
  df <- safe_query(q_top_platform_played)
  if ("error" %in% names(df) || nrow(df) == 0) {
    make_stat_card(
      "Most Popular Platform",
      "-",
      "Platform data not available.",
      "Top Platform",
      "purple"
    )
  } else {
    make_stat_card(
      "Most Popular Platform",
      df$platform_name[1],
      paste0("Total Occurrences: ", df$total_usage[1]),
      "Top Platform",
      "purple"
    )
  }
})

# Age Rating Terbanyak
output$ov_stat_age <- renderUI({
  df <- safe_query(q_top_age_rating)
  if ("error" %in% names(df) || nrow(df) == 0) {
    make_stat_card(
      "Most Popular Age Rating",
      "-",
      "Age rating data not available.",
      "Top Audience",
      "orange"
    )
  } else {
    make_stat_card(
      "Most Popular Age Rating",
      df$age_rating[1],
      paste0("Total Games: ", df$total_game[1]),
      "Top Audience",
      "orange"
    )
  }
})

# Genre with Highest Average Score
output$ov_stat_best_genre_score <- renderUI({
  df <- safe_query(q_best_avg_genre)
  if ("error" %in% names(df) || nrow(df) == 0) {
    make_stat_card(
      "Genre with the Highest Average Score",
      "-",
      "Data is not available.",
      "Best Genre",
      "cyan"
    )
  } else {
    make_stat_card(
      "Genre with the Highest Average Score",
      df$genre_name[1],
      paste0("Average Score: ", round(df$avg_score[1],2)),
      "Best Genre",
      "cyan"
    )
  }
})

#### Pie Chart ####
output$ov_genre_pie <- renderPlotly({
  df <- safe_query(q_genre_pie)
  if ("error" %in% names(df) || nrow(df) == 0) return(plotly_empty("No genre pie data"))
  
  threshold <- 5
  df <- df %>% mutate(
    pct_label = ifelse(!is.na(percentage) & percentage >= threshold, 
                       paste0(percentage, "%"), ""),
    pull_val  = ifelse(!is.na(percentage) & percentage >= threshold, 
                       0.05, 0)
  )
  
  plot_ly(
    df,
    labels = ~genre_name,
    values = ~total_review,
    type = "pie",
    hole = 0.55,
    
    text = ~pct_label,
    textinfo = "text",
    textposition = "inside",
    
    insidetextfont = list(
      color = "#ffffff",
      size = 13
    ),
    
    pull = ~pull_val,
    
    marker = list(
      colors = c(
        "#22d3ee",
        "#06b6d4",
        "#38bdf8",
        "#3b82f6",  
        "#6366f1",  
        "#8b5cf6",
        "#a855f7",
        "#c084fc"
      ),
      
      line = list(
        color = "rgba(255,255,255,0.15)", 
        width = 1.5
      )
    ),
    
    hovertemplate = "<b>%{label}</b><br>Reviews: %{value}<br>Percent: %{percent}<extra></extra>"
    
  ) %>%
    
    layout(
      showlegend = TRUE,
      
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      
      legend = list(
        font = list(
          color = "#1e293b",
          size = 13
        ),
        orientation = "v"
      ),
      
      margin = list(t = 10, b = 10, l = 10, r = 10)
    ) %>%
    
    config(displayModeBar = FALSE)
})

# Tabel Top Games by Score
output$ov_top10_score_tbl <- renderDT({
  df <- safe_query(q_top10_score)
  validate(
    need(!("error" %in% names(df)), paste("Query failed:", df$error[1])),
    need(nrow(df) > 0, "Top 10 data is empty.")
  )
  out <- df %>% transmute(Title = game_title, Score = score, TotalVote = total_vote, Metascore = metascore)
  datatable(out, rownames = FALSE, options = list(pageLength = 10, scrollX = TRUE))
})

# Highest Score Card
output$ov_best_score_card <- renderUI({
  
  best <- safe_query(q_best_score)
  
  game  <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$game_title[1]
  value <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$score[1]
  
  make_rank_card(
    "score-card",
    "Highest Score",
    game,
    value,
    "Note: Highest user rating in the dataset.",
    "Score"
  )
  
})

# Highest Metascore Card
output$ov_best_meta_card <- renderUI({
  
  best <- safe_query(q_best_metascore)
  
  game  <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$game_title[1]
  value <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$metascore[1]
  
  make_rank_card(
    "meta-card",
    "Highest Metascore",
    game,
    value,
    "Note: Highest critic score.",
    "Metascore"
  )
  
})

top_reviewed <- reactive({
  df <- safe_query(q_top10_reviewed)
  if ("error" %in% names(df)) return(df)
  df
})

selected_review_game_id <- reactiveVal(NULL)

observeEvent(top_reviewed(), {
  df <- top_reviewed()
  if (!("error" %in% names(df)) && nrow(df) > 0 && is.null(selected_review_game_id())) {
    selected_review_game_id(df$game_id[1])
  }
}, ignoreInit = TRUE)

#### Top 10 Review Chart ####
output$ov_top10_review_bar <- renderPlotly({
  
  df <- top_reviewed()
  if ("error" %in% names(df) || nrow(df) == 0) 
    return(plotly_empty("No review count data"))
  
  p <- plot_ly(
    data = df,
    x = ~total_review,
    y = ~reorder(game_title, total_review),
    type = "bar",
    orientation = "h",
    source = "toprev",
    customdata = ~game_id,
    
    marker = list(
      color = "#00ffd5",
      line = list(
        color = "rgba(0,0,0,0.08)", 
        width = 1
      )
    ),
    
    opacity = 0.9,
    
    hoverlabel = list(
      bgcolor = "#ffffff",
      font = list(color = "#1e293b")
    ),
    
    hovertemplate = 
      "<b>%{y}</b><br>Total Reviews: %{x:,}<extra></extra>"
  ) %>%
    
    layout(
      title = NULL,
      
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      
      xaxis = list(
        title = list(text = "Total Reviews", font = list(color = "#0f172a")),
        tickfont = list(color = "#0f172a"),
        showline = TRUE,
        linecolor = "#64748b",
        linewidth = 1,
        ticks = "outside",
        tickcolor = "#64748b",
        gridcolor = "rgba(0,0,0,0.1)",
        zeroline = FALSE
      ),
      
      yaxis = list(
        title = "",
        tickfont = list(color = "#0f172a"),
        showline = TRUE,
        linecolor = "#64748b",
        linewidth = 1,
        ticks = "outside",
        tickcolor = "#64748b",
        automargin = TRUE
      ),
      
      margin = list(t = 10, r = 20, l = 120, b = 40)
    ) %>%
    
    config(displayModeBar = FALSE)
  
  p <- event_register(p, "plotly_click")
  p
})


observeEvent(event_data("plotly_click", source = "toprev"), ignoreInit = TRUE, {
  
  ed <- event_data("plotly_click", source = "toprev")
  
  if (is.null(ed)) return()
  
  if ("customdata" %in% names(ed)) {
    selected_review_game_id(as.numeric(ed$customdata[1]))
  }
  
})

output$ov_latest_reviews_tbl <- renderDT({
  gid <- selected_review_game_id()
  validate(need(!is.null(gid), "Click on the bar chart to select a game."))
  df <- safe_query(q_latest5_reviews_by_game, params = list(gid))
  validate(need(!("error" %in% names(df)), paste("Review query failed:", df$error[1])))
  
  if (nrow(df) == 0) {
    return(datatable(data.frame(Message = "There are no reviews for this game yet."), rownames = FALSE, options = list(dom='t')))
  }
  
  out <- df %>% transmute(Username = username, Review = review_text, Date = review_date)
  datatable(out, rownames = FALSE, options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, scrollX = TRUE))
})

#### Game Score Distribution (Bar Chart) ####
output$ov_score_dist <- renderPlotly({
  
  df <- safe_query(q_score_dist)
  if ("error" %in% names(df) || nrow(df) == 0) 
    return(plotly_empty("No score distribution data"))
  
  df <- df %>% filter(!is.na(score))
  if (nrow(df) == 0) 
    return(plotly_empty("No valid score data"))
  
  plot_ly(
    df,
    x = ~score,
    type = "histogram",
    nbinsx = 20,
    
    marker = list(
      color = "#00ffd5",
      line = list(color = "#0f172a", width = 1.5)
    ),
    
    opacity = 0.85,
    
    hovertemplate = 
      "<b>Score:</b> %{x}<br><b>Count:</b> %{y}<extra></extra>"
  ) %>%
    
    layout(
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      
      bargap = 0.05,
      
      xaxis = list(
        title = "Score",
        color = "#0f172a",
        gridcolor = "rgba(255,255,255,0.05)",
        zeroline = FALSE
      ),
      
      yaxis = list(
        title = "Jumlah Game",
        color = "#0f172a",
        gridcolor = "rgba(255,255,255,0.05)",
        zeroline = FALSE
      ),
      
      margin = list(t = 10, r = 10, l = 50, b = 40)
    ) %>%
    
    config(displayModeBar = FALSE)
})

#### Game Release Chart ####
output$ov_release_trend <- renderPlotly({
  
  df <- safe_query(q_release_trend)
  if ("error" %in% names(df) || nrow(df) == 0) 
    return(plotly_empty("No release trend"))
  
  df <- df %>% arrange(release_year)
  
  plot_ly(
    df,
    x = ~release_year,
    y = ~total_game,
    type = "scatter",
    mode = "lines+markers",
    
    line = list(
      color = "#a855f7",
      width = 3
    ),
    
    marker = list(
      size = 8,
      color = "#00ffd5",
      line = list(color = "#0f172a", width = 2)
    ),
    
    hovertemplate = 
      "<b>Year:</b> %{x}<br><b>Total Games:</b> %{y}<extra></extra>"
    
  ) %>%
    
    layout(
      title = NULL,
      
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      
      xaxis = list(
        title = "Year",
        color = "#0f172a",
        gridcolor = "rgba(255,255,255,0.05)",
        zeroline = FALSE
      ),
      
      yaxis = list(
        title = "Total Games",
        color = "#0f172a",
        gridcolor = "rgba(255,255,255,0.05)",
        zeroline = FALSE
      ),
      
      margin = list(t = 10, r = 10, l = 50, b = 40)
    ) %>%
    
    config(displayModeBar = FALSE)
})


## Tambahan Key Insights
output$insight_release <- renderText({
  
  df <- safe_query(q_release_trend)
  
  if("error" %in% names(df) || nrow(df)==0)
    return("No insight available.")
  
  peak_year <- df$release_year[which.max(df$total_game)]
  
  paste0(
    "Game releases reached their peak in ", peak_year,
    ", indicating the most active publishing period."
  )
})

output$insight_score_dist <- renderText({
  
  df <- safe_query(q_score_dist)
  
  if("error" %in% names(df) || nrow(df)==0)
    return("No insight available.")
  
  avg_score <- round(mean(df$score, na.rm = TRUE),2)
  
  paste0(
    "Most games tend to have moderate ratings, with an average score around ",
    avg_score,"."
  )
})

output$insight_reviews <- renderText({
  
  df <- safe_query(q_top10_reviewed)
  
  if("error" %in% names(df) || nrow(df)==0)
    return("No insight available.")
  
  top_game <- df$game_title[1]
  
  paste0(
    top_game,
    " receives the highest number of reviews, indicating strong player engagement."
  )
})

output$insight_score_gap <- renderText({
  
  best_user <- safe_query(q_best_score)
  best_meta <- safe_query(q_best_metascore)
  
  if("error" %in% names(best_user) || "error" %in% names(best_meta))
    return("No insight available.")
  
  paste0(
    "User ratings and critic scores may highlight different perspectives on game quality."
  )
})



# ===== PENCARIAN: choices =====
observe({
  g <- safe_query("SELECT DISTINCT genre_name FROM tbl_genres ORDER BY genre_name;")
  p <- safe_query("SELECT DISTINCT platform_name FROM tbl_platforms ORDER BY platform_name;")
  a <- safe_query("
  SELECT DISTINCT age_rating
  FROM tbl_games
  WHERE age_rating IS NOT NULL
    AND TRIM(age_rating) <> ''
  ORDER BY FIELD(
    age_rating,
    'Everyone (0+)',
    'Everyone 10+ (10+)',
    'Teen (13+)',
    'Mature (17+)',
    'Adults Only (18+)',
    'Not rated',
    'Rating Pending'
  );
")
  
  if (!("error" %in% names(g)) && "genre_name" %in% names(g))
    updateSelectInput(session, "f_genre", choices = c("All", g$genre_name), selected = "All")
  if (!("error" %in% names(p)) && "platform_name" %in% names(p))
    updateSelectInput(session, "f_platform", choices = c("All", p$platform_name), selected = "All")
  if (!("error" %in% names(a)) && "age_rating" %in% names(a))
    updateSelectInput(session, "f_age", choices = c("All", a$age_rating), selected = "All")
})

search_result <- reactiveVal(NULL)

observeEvent(TRUE, {
  df <- safe_query(q_search, params = list(NA, NA, NA, NA, NA, NA, 1, 1))
  search_result(df)
}, once = TRUE)

observeEvent(input$btn_reset, {
  updateSelectInput(session, "f_genre", selected = "All")
  updateSelectInput(session, "f_platform", selected = "All")
  updateSelectInput(session, "f_age", selected = "All")
  updateSliderInput(session, "f_score", value = 1)
  updateTextInput(session, "search_text", value = "")
  
  df <- safe_query(q_search, params = list(NA, NA, NA, NA, NA, NA, 1, 1))
  search_result(df)
}, ignoreInit = TRUE)

observeEvent(input$btn_ok, {
  genre <- if (is.null(input$f_genre) || input$f_genre == "All") NA_character_ else as.character(input$f_genre)
  plat  <- if (is.null(input$f_platform) || input$f_platform == "All") NA_character_ else as.character(input$f_platform)
  age   <- if (is.null(input$f_age) || input$f_age == "All") NA_character_ else as.character(input$f_age)
  
  minsc <- suppressWarnings(as.numeric(input$f_score))
  if (length(minsc) == 0 || is.na(minsc)) minsc <- 1
  
  df <- safe_query(q_search, params = list(genre, genre, plat, plat, age, age, minsc, minsc))
  search_result(df)
}, ignoreInit = TRUE)
search_table_data <- reactive({
  df <- search_result()
  validate(
    need(!is.null(df), "Data belum tersedia."),
    need(!("error" %in% names(df)), paste("Query gagal:", df$error[1])),
    need(nrow(df) > 0, "Tidak ada data. Coba Reset.")
  )
  
  df %>%
    transmute(
      game_id = game_id,
      Title = game_title,
      Genre = genres,
      `Age Rating` = age_rating,
      Platform = platforms,
      `Score Game` = game_score,
      URL = trimws(ifelse(is.na(game_url), "", game_url))  
    )
})

output$tbl_search <- renderDT({
  out <- search_table_data()
  
  datatable(
    out,
    escape = FALSE,
    rownames = FALSE,
    selection = list(mode = "single", target = "row"),
    options = list(
      pageLength = 10,
      autoWidth = TRUE,
      scrollX = TRUE,
      dom = "<'row'<'col-sm-6'l><'col-sm-6'>>rt<'row'<'col-sm-6'i><'col-sm-6'p>>",
      columnDefs = list(
        list(targets = c(0, 6), visible = FALSE) # sembunyikan game_id dan URL
      )
    ),
    callback = JS("
      // SEARCH luar tabel -> table.search()
      var $s = $('#search_text');
      $s.off('keyup.dtsearch').on('keyup.dtsearch', function(){
        table.search(this.value).draw();
      });

      // ROW CLICK -> buka url langsung
      $('#tbl_search tbody').off('click.rowgo').on('click.rowgo', 'tr', function(){
        var row = table.row(this);
        if(!row || !row.data()) return;

        var d = row.data();
        var url = d[6];  // kolom URL (hidden)
        var title = d[1];

        if(url && url.trim() !== ''){
          if(!/^https?:\\/\\//i.test(url)) url = 'https://' + url;
          window.open(url, '_blank');
        } else {
          Shiny.setInputValue('row_click_no_url', {title: title}, {priority: 'event'});
        }
      });
    ")
  )
})

# ===== DOWNLOAD CSV =====
output$download_csv <- downloadHandler(
  
  filename = function() {
    paste0("game_search_", Sys.Date(), ".csv")
  },
  
  content = function(file) {
    
    df <- search_table_data()
    
    write.csv(
      df,
      file,
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
    
  }
)

observeEvent(input$row_click_no_url, {
  ttl <- input$row_click_no_url$title %||% "Detail Game"
  showModal(modalDialog(
    title = ttl,
    p("URL game tidak tersedia di database."),
    easyClose = TRUE,
    footer = modalButton("Tutup")
  ))
}, ignoreInit = TRUE)
}
