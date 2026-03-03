library(shiny)
library(DBI)
library(RMariaDB)
library(dplyr)
library(plotly)
library(DT)
library(shinycssloaders)

`%||%` <- function(a, b) if (!is.null(a) && length(a) > 0 && !is.na(a)) a else b

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
    annotations = list(list(text = msg, x = 0.5, y = 0.5, showarrow = FALSE))
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
  # HOME (SESUAI KODING KAMU)
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
        
        h1(data$game_title[i]),
        
        p(substr(data$about[i] %||% "", 1, 200), "..."),
        
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
        h4(data$game_title[i]),
        p(data$age_rating[i])
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
        h4(data$game_title[i]),
        p(data$genre[i])   # <-- sesuai kode kamu (kalau error, biasanya kolomnya genre_name)
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
    ORDER BY score DESC
    LIMIT 10;
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

output$ov_most_popular_genre <- renderText({
  df <- safe_query(q_popular_genre)
  if ("error" %in% names(df) || nrow(df) == 0) "-" else as.character(df$genre_name[1])
})
output$ov_most_popular_genre_sub <- renderText({
  df <- safe_query(q_popular_genre)
  if ("error" %in% names(df) || nrow(df) == 0) "" else paste0("Total review: ", df$total_review[1])
})

output$ov_stat_2016 <- renderUI({
  df <- safe_query(q_popular_game_2016)
  if ("error" %in% names(df) || nrow(df) == 0) {
    return(div(class="mini-stat",
               div(class="mini-label","Game Populer (2016)"),
               div(class="mini-value","-"),
               div(class="mini-sub","Tidak ada data 2016 / belum ada review."),
               div(class="badge-soft","Analisis Tahun Rilis")
    ))
  }
  div(class="mini-stat",
      div(class="mini-label","Game Populer (2016)"),
      div(class="mini-value", df$game_title[1]),
      div(class="mini-sub", paste0("Total review: ", df$total_review[1])),
      div(class="badge-soft","Analisis Tahun Rilis")
  )
})

output$ov_stat_platform <- renderUI({
  df <- safe_query(q_top_platform_played)
  if ("error" %in% names(df) || nrow(df) == 0) {
    return(div(class="mini-stat",
               div(class="mini-label","Platform Paling Sering Dimainkan"),
               div(class="mini-value","-"),
               div(class="mini-sub","Data platform tidak tersedia."),
               div(class="badge-soft","Analisis Platform")
    ))
  }
  div(class="mini-stat",
      div(class="mini-label","Platform Paling Sering Dimainkan"),
      div(class="mini-value", df$platform_name[1]),
      div(class="mini-sub", paste0("Total kemunculan: ", df$total_usage[1])),
      div(class="badge-soft","Analisis Platform")
  )
})

output$ov_stat_age <- renderUI({
  df <- safe_query(q_top_age_rating)
  if ("error" %in% names(df) || nrow(df) == 0) {
    return(div(class="mini-stat",
               div(class="mini-label","Age Rating Terbanyak"),
               div(class="mini-value","-"),
               div(class="mini-sub","Data age rating tidak tersedia."),
               div(class="badge-soft","Analisis Audience")
    ))
  }
  div(class="mini-stat",
      div(class="mini-label","Age Rating Terbanyak"),
      div(class="mini-value", df$age_rating[1]),
      div(class="mini-sub", paste0("Total game: ", df$total_game[1])),
      div(class="badge-soft","Analisis Audience")
  )
})

output$ov_genre_pie <- renderPlotly({
  df <- safe_query(q_genre_pie)
  if ("error" %in% names(df) || nrow(df) == 0) return(plotly_empty("No genre pie data"))
  df <- df %>% arrange(desc(total_review))
  threshold <- 5
  df <- df %>% mutate(
    pct_label = ifelse(!is.na(percentage) & percentage >= threshold, paste0(percentage, "%"), ""),
    pull_val  = ifelse(!is.na(percentage) & percentage >= threshold, 0.07, 0.01)
  )
  
  plot_ly(
    df, labels = ~genre_name, values = ~total_review, type = "pie", hole = 0.55,
    text = ~pct_label, textinfo = "text", textposition = "inside",
    insidetextfont = list(color = "#ffffff", size = 13),
    pull = ~pull_val,
    marker = list(
      colors = c("#00ffd5", "#00c8ff", "#00f5ff", "#0099cc", "#00bfa5", "#14b8a6", "#22d3ee", "#0891b2"),
      line = list(color = "#0f172a", width = 3)
    ),
    hovertemplate = "<b>%{label}</b><br>Reviews: %{value}<br>Percent: %{percent}<extra></extra>"
  ) %>%
    layout(showlegend = TRUE, paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor  = "rgba(0,0,0,0)",
           legend = list(font = list(color = "#cbd5e1"), orientation = "v"),
           margin = list(t = 10, b = 10, l = 10, r = 10)) %>%
    config(displayModeBar = FALSE)
})

output$ov_top10_score_tbl <- renderDT({
  df <- safe_query(q_top10_score)
  validate(
    need(!("error" %in% names(df)), paste("Query gagal:", df$error[1])),
    need(nrow(df) > 0, "Data top 10 kosong.")
  )
  out <- df %>% transmute(Title = game_title, Score = score, TotalVote = total_vote, Metascore = metascore)
  datatable(out, rownames = FALSE, options = list(pageLength = 10, scrollX = TRUE))
})

output$ov_best_score_card <- renderUI({
  best <- safe_query(q_best_score)
  game  <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$game_title[1]
  value <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$score[1]
  div(class="score-card",
      div(class="rank-title", HTML("Status: <b>Score Tertinggi</b>")),
      div(class="rank-big", paste0("Game: ", game)),
      div(class="rank-pill", paste0("Score: ", value)),
      div(class="rank-note", "Catatan: Rating user terbaik di dataset.")
  )
})

output$ov_best_meta_card <- renderUI({
  best <- safe_query(q_best_metascore)
  game  <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$game_title[1]
  value <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$metascore[1]
  div(class="meta-card",
      div(class="rank-title", HTML("Status: <b>Metascore Tertinggi</b>")),
      div(class="rank-big", paste0("Game: ", game)),
      div(class="rank-pill", paste0("Metascore: ", value)),
      div(class="rank-note", "Catatan: Skor kritikus paling tinggi.")
  )
})

output$ov_stat_best_genre_score <- renderUI({
  df <- safe_query(q_best_avg_genre)
  if ("error" %in% names(df) || nrow(df) == 0) {
    return(div(class="mini-stat",
               div(class="mini-label","Genre Dengan Rata-Rata Score Tertinggi"),
               div(class="mini-value","-"),
               div(class="mini-sub","Data tidak tersedia."),
               div(class="badge-soft","Analisis Kualitas Genre")
    ))
  }
  div(class="mini-stat",
      div(class="mini-label","Genre Dengan Rata-Rata Score Tertinggi"),
      div(class="mini-value", df$genre_name[1]),
      div(class="mini-sub", paste0("Rata-rata score: ", df$avg_score[1])),
      div(class="badge-soft","Analisis Kualitas Genre")
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

output$ov_top10_review_bar <- renderPlotly({
  df <- top_reviewed()
  if ("error" %in% names(df) || nrow(df) == 0) return(plotly_empty("No review count data"))
  df <- df %>% arrange(total_review)
  
  p <- plot_ly(
    data = df,
    x = ~total_review,
    y = ~reorder(game_title, total_review),
    type = "bar",
    orientation = "h",
    source = "toprev",
    customdata = ~game_id,
    marker = list(color = "#00ffd5", line = list(color = "#0f172a", width = 1.5)),
    opacity = 0.9,
    hovertemplate = "<b>%{y}</b><br>Total Reviews: %{x:,}<extra></extra>"
  ) %>%
    layout(
      title = NULL,
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      xaxis = list(title = "Total Reviews", color = "#cbd5e1", gridcolor = "rgba(255,255,255,0.05)", zeroline = FALSE),
      yaxis = list(title = "", color = "#e2e8f0", automargin = TRUE),
      margin = list(t = 10, r = 20, l = 120, b = 40)
    ) %>%
    config(displayModeBar = FALSE)
  
  p <- event_register(p, "plotly_click")
  p
})

observeEvent(event_data("plotly_click", source = "toprev"), {
  ed <- event_data("plotly_click", source = "toprev")
  if (!is.null(ed) && "customdata" %in% names(ed)) {
    selected_review_game_id(as.numeric(ed$customdata[1]))
  }
}, ignoreInit = TRUE)

output$ov_latest_reviews_tbl <- renderDT({
  gid <- selected_review_game_id()
  validate(need(!is.null(gid), "Klik bar chart untuk memilih game."))
  df <- safe_query(q_latest5_reviews_by_game, params = list(gid))
  validate(need(!("error" %in% names(df)), paste("Query review gagal:", df$error[1])))
  
  if (nrow(df) == 0) {
    return(datatable(data.frame(Message = "Belum ada review untuk game ini."), rownames = FALSE, options = list(dom='t')))
  }
  
  out <- df %>% transmute(Username = username, Review = review_text, Date = review_date)
  datatable(out, rownames = FALSE, options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, scrollX = TRUE))
})

output$ov_score_dist <- renderPlotly({
  df <- safe_query(q_score_dist)
  if ("error" %in% names(df) || nrow(df) == 0) return(plotly_empty("No score distribution data"))
  df <- df %>% filter(!is.na(score))
  if (nrow(df) == 0) return(plotly_empty("No valid score data"))
  
  plot_ly(
    df, x = ~score, type = "histogram", nbinsx = 20,
    marker = list(color = "#00ffd5", line = list(color = "#0f172a", width = 1.5)),
    opacity = 0.85,
    hovertemplate = "<b>Score:</b> %{x}<br><b>Count:</b> %{y}<extra></extra>"
  ) %>%
    layout(
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      bargap = 0.05,
      xaxis = list(title = "Score", color = "#cbd5e1", gridcolor = "rgba(255,255,255,0.05)", zeroline = FALSE),
      yaxis = list(title = "Jumlah Game", color = "#cbd5e1", gridcolor = "rgba(255,255,255,0.05)", zeroline = FALSE),
      margin = list(t = 10, r = 10, l = 50, b = 40)
    ) %>%
    config(displayModeBar = FALSE)
})

output$ov_release_trend <- renderPlotly({
  df <- safe_query(q_release_trend)
  if ("error" %in% names(df) || nrow(df) == 0) return(plotly_empty("No release trend"))
  df <- df %>% arrange(release_year)
  
  plot_ly(
    df, x = ~release_year, y = ~total_game, type = "scatter", mode = "lines+markers",
    line = list(color = "#00ffd5", width = 3),
    marker = list(size = 8, color = "#00ffd5", line = list(color = "#0f172a", width = 2)),
    hovertemplate = "<b>Year:</b> %{x}<br><b>Total Games:</b> %{y}<extra></extra>"
  ) %>%
    layout(
      title = NULL,
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      xaxis = list(title = "Year", color = "#cbd5e1", gridcolor = "rgba(255,255,255,0.05)", zeroline = FALSE),
      yaxis = list(title = "Total Games", color = "#cbd5e1", gridcolor = "rgba(255,255,255,0.05)", zeroline = FALSE),
      margin = list(t = 10, r = 10, l = 50, b = 40)
    ) %>%
    config(displayModeBar = FALSE)
})

observe({
  g <- safe_query("SELECT DISTINCT genre_name FROM tbl_genres ORDER BY genre_name;")
  p <- safe_query("SELECT DISTINCT platform_name FROM tbl_platforms ORDER BY platform_name;")
  a <- safe_query("SELECT DISTINCT age_rating FROM tbl_games WHERE age_rating IS NOT NULL ORDER BY age_rating;")
  
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
        list(targets = c(0, 6), visible = FALSE)
      )
    ),
    callback = JS("
        var $s = $('#search_text');
        $s.off('keyup.dtsearch').on('keyup.dtsearch', function(){
          table.search(this.value).draw();
        });

        $('#tbl_search tbody').off('click.rowgo').on('click.rowgo', 'tr', function(){
          var row = table.row(this);
          if(!row || !row.data()) return;

          var d = row.data();
          var url = d[6];
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

server
