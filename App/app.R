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

## Footer
footer_ui <- div(
  style = "
    background: linear-gradient(135deg, #00141a, #000c12);
    padding: 30px;
    border-radius: 20px;
    text-align: center;
    margin-top: 25px;

    border: 1px solid rgba(0,245,255,0.4);

    box-shadow: 
      0 0 30px rgba(0,245,255,0.4),
      0 10px 40px rgba(0,0,0,0.8);

    line-height: 1.8;
    color: #cfffff;
    font-size: 14px;
  ",
  
  tags$div(
    style = "
      font-size:18px; 
      font-weight:700; 
      color:#00f5ff; 
      text-shadow:0 0 15px rgba(0,245,255,0.9); 
      margin-bottom:8px;
    ",
    "Kelompok 1 — Game Dataset Analytics"
  ),
  
  tags$div(
    style="color:#9befff;",
    "Magister Statistika dan Sains Data"
  ),
  
  tags$div(
    style="color:#6fe8ff;",
    "Departemen Statistika dan Data Sains — SSMI IPB University"
  ),
  
  tags$div(
    style="margin-top:8px; color:#3ddcff;",
    "Kampus IPB Dramaga, Bogor 16680, Indonesia"
  ),
  
  tags$hr(
    style="border-color:rgba(0,245,255,0.3); margin:15px 0;"
  ),
  
  tags$div(
    style="color:#22d3ee;",
    "© 2026 — STA2562 Dashboard Pemrosesan Data Besar"
  )
)


# =========================
# UI
# =========================
ui <- tagList(
  
  tags$head(
    tags$style(HTML("

/* ================= HOME STYLE ================= */
html, body {
  background: radial-gradient(circle at 20% 20%, #00151a, #000000 70%);
  background-attachment: fixed;
  min-height: 100vh;
  color: #e6ffff;
}

h1, h2, h3, h4 {
  color: #00f5ff;
  text-shadow: 0 0 15px rgba(0,245,255,0.9);
}

p {
  color: rgba(180,255,255,0.75);
}

/* ================= NAVBAR ================= */
.navbar {
  display: flex;
  justify-content: center;
  border-radius: 30px;
  margin: 20px auto;
  width: fit-content;
  padding: 10px 25px;

  backdrop-filter: blur(15px);
  background: rgba(0, 20, 25, 0.7) !important;

  border: 1px solid rgba(0,245,255,0.4);

  box-shadow:
    0 0 20px rgba(0,245,255,0.4),
    inset 0 0 10px rgba(0,245,255,0.2);
}

.navbar-nav > li > a {
  color: rgba(180,255,255,0.7) !important;
  border-radius: 20px;
  transition: 0.3s;
}

.navbar-nav > li > a:hover {
  color: #00f5ff !important;
  text-shadow: 0 0 12px #00f5ff;
}

.navbar-nav > .active > a {
  background: rgba(0,245,255,0.15) !important;
  box-shadow: 0 0 15px rgba(0,245,255,0.6);
  color: #00f5ff !important;
}

/* ================= HEADER BOX ================= */
.hero-box {
  position: relative;
  overflow: hidden;

  padding: 70px;
  border-radius: 30px;
  text-align: center;
  color: #ffffff;

  background:
    linear-gradient(135deg, #1a2a6c 0%, #1e3c72 40%, #22d3ee 100%);

  border: none;

  box-shadow:
    0 30px 80px rgba(0,0,0,0.75),
    0 0 80px rgba(0,245,255,0.35);

  transition: all 0.35s ease;
}

/* Glow focus tengah */
.hero-box::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 30px;

  background: radial-gradient(
    circle at center,
    rgba(255,255,255,0.15),
    rgba(0,245,255,0.15),
    transparent 65%
  );

  pointer-events: none;
}

/* Subtle pattern grid */
.hero-box::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 30px;

  background-image:
    linear-gradient(rgba(255,255,255,0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px);

  background-size: 40px 40px;

  opacity: 0.15;
  pointer-events: none;
}

/* Hover subtle */
.hero-box:hover {
  transform: translateY(-4px);

  box-shadow:
    0 35px 90px rgba(0,0,0,0.8),
    0 0 100px rgba(0,245,255,0.45);
}

.hero-box h1 {
  font-size: 42px;
  font-weight: 800;

  text-shadow:
    0 0 25px rgba(255,255,255,0.7),
    0 0 50px rgba(0,245,255,0.9);
}

.hero-box p {
  font-size: 17px;
  opacity: 0.9;
}

/* == Moving Light Sweep == */
.hero-box::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -150%;
  width: 200%;
  height: 200%;

  background: linear-gradient(
    120deg,
    transparent 30%,
    rgba(255,255,255,0.15),
    transparent 70%
  );

  transform: rotate(25deg);
  animation: lightSweep 6s linear infinite;

  pointer-events: none;
}

/* Animation */
@keyframes lightSweep {
  0% {
    left: -150%;
  }
  100% {
    left: 150%;
  }
}

/* ================= TOTAL CARD ================= */
.card-soft {
  border-radius: 25px;
  padding: 30px;
  text-align: center;
  color: #ffffff;

  border: none;

  box-shadow:
    0 15px 40px rgba(0,0,0,0.6),
    0 0 40px rgba(0,245,255,0.15);

  transition: all 0.35s ease;
}

/* Hover subtle */
.card-soft:hover {
  transform: translateY(-4px) scale(1.01);
  box-shadow:
    0 20px 50px rgba(0,0,0,0.7),
    0 0 60px rgba(0,245,255,0.25);
}

.card-game {
  background: linear-gradient(
    135deg,
    #5f2bff 0%,
    #3a6cf4 45%,
    #22d3ee 100%
  );
}

.card-review {
  background: linear-gradient(
    135deg,
    #00c6ff 0%,
    #00f5d4 50%,
    #00e0b8 100%
  );
}

.card-value {
  font-size: 42px;
  font-weight: 900;
  color: #ffffff;

  text-shadow:
    0 0 15px rgba(255,255,255,0.6),
    0 0 25px rgba(0,245,255,0.6);
}

/* ================= BANNER ================= */
.banner-container {
  position: relative;
  width: 100%;
  height: 520px;
  border-radius: 25px;
  overflow: hidden;
  cursor: default;
  transition: 0.4s;

  box-shadow: 
    0 0 20px rgba(0,245,255,0.3),
    0 0 60px rgba(0,245,255,0.15),
    0 20px 60px rgba(0,0,0,0.6);
}

.banner-container:hover {
  transform: scale(1.01);
  box-shadow: 
    0 0 30px rgba(0,245,255,0.6),
    0 0 80px rgba(0,245,255,0.3),
    0 30px 80px rgba(0,0,0,0.8);
}

.banner-container::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 25px;

  pointer-events: none;
  background: linear-gradient(
    120deg,
    transparent,
    rgba(0,245,255,0.4),
    transparent
  );
  opacity: 0;
  transition: 0.5s;
}

.banner-content h1,
.banner-content h2 {
  color: #00f5ff;
  text-shadow: 0 0 15px rgba(0,245,255,0.9);
}

.banner-content p {
  color: #ccffff;
}

/* VIDEO */
.banner-video {
  position: absolute;
  width: 100%;
  height: 100%;
  object-fit: cover;
  pointer-events: none;

  filter: brightness(0.7) contrast(1.1);
  transition: transform 0.8s ease;
}

.banner-container:hover .banner-content {
  transform: translateY(-5px);
}

/* OVERLAY CINEMATIC */
.banner-overlay {
  position: absolute;
  width: 100%;
  height: 100%;
  pointer-events: none;

  background: linear-gradient(
    to right,
    rgba(0,20,25,0.9),
    rgba(0,20,25,0.4),
    rgba(0,0,0,0.1)
  );
}
    
/* CONTENT */
.banner-content {
  position: relative;
  padding: 60px;
  max-width: 600px;
  position: relative;
  z-index: 10;
  
  transform: translateY(0);
  opacity: 1;

  transition: all 0.5s ease;
}

/* text glow */
.banner-content h1,
.banner-content h2 {
  color: #ffffff;
  text-shadow: 0 0 15px rgba(0,245,255,0.8);
}

.banner-content p {
  color: #d9ffff;
}

.banner-container:hover .banner-content {
  transform: translateY(0);
  opacity: 1;
}

/* BUTTON NEON */
.btn-modern {
  display: inline-block;
  padding: 12px 28px;
  border-radius: 12px;
  font-weight: 600;
  text-decoration: none;
  position: relative;
  z-index: 20;

  color: #001414;
  background: linear-gradient(135deg, #00f5ff, #00c8ff);

  box-shadow: 
    0 0 15px rgba(0,245,255,0.7),
    0 0 30px rgba(0,245,255,0.4);

  transition: 0.3s;
}

.btn-modern:hover {
  transform: translateY(-3px);
  box-shadow: 
    0 0 30px rgba(0,245,255,1),
    0 0 60px rgba(0,245,255,0.8);
}
    
/* NAV BUTTON (LEFT RIGHT) */
.nav-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  z-index: 20;

  width: 50px;
  height: 50px;
  border-radius: 50%;
  border: none;

  color: #00f5ff;
  font-size: 20px;

  background: rgba(0,20,25,0.6);

  box-shadow: 
    0 0 15px rgba(0,245,255,0.7),
    0 0 30px rgba(0,245,255,0.3);

  transition: 0.3s;
}

.nav-btn i {
  color: #00f5ff;
}

.left-btn {
  left: 20px;
}

.right-btn {
  right: 20px;
}

/* ============== AGE RECOMMENDATION CARD ============== */
.card-container {
  display: flex;
  gap: 20px;
  padding: 15px 0;
}

/* Scrollbar */
.card-container::-webkit-scrollbar {
  height: 6px;
}

.card-container::-webkit-scrollbar-thumb {
  background: linear-gradient(90deg, #00f5ff, #00c8ff);
  border-radius: 10px;
}

/* Card */
.card-age {
  width: 223px;
  flex: 0 0 auto;

  background: linear-gradient(
    145deg,
    #00262b,
    #00181c
  );

  padding: 18px;
  border-radius: 22px;
  text-align: center;

  color: #e6ffff;

  border: none;

  box-shadow:
    0 12px 30px rgba(0,0,0,0.65),
    0 0 20px rgba(0,245,255,0.12);

  transition: all 0.35s ease;

  position: relative;
  overflow: hidden;
}

/* Soft inner glow */
.card-age::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 22px;

  background: radial-gradient(
    circle at top left,
    rgba(0,245,255,0.15),
    transparent 60%
  );

  pointer-events: none;
}

/* Hover Effect - subtle */
.card-age:hover {
  transform: translateY(-4px);

  box-shadow:
    0 18px 40px rgba(0,0,0,0.75),
    0 0 30px rgba(0,245,255,0.25);
}

/* Image */
.card-age img {
  width: 100%;
  height: 140px;
  object-fit: cover;
  border-radius: 14px;

  box-shadow:
    0 8px 18px rgba(0,0,0,0.6);
}

/* Title */
.card-age h4 {
  font-size: 15px;
  margin-top: 12px;
  color: #ffffff;
  font-weight: 700;

  text-shadow:
    0 0 15px rgba(0,245,255,0.6);
}

/* Description */
.card-age p {
  font-size: 12px;
  color: rgba(200,255,255,0.8);
}

/* ================= TAB SEARCH ================= */
body { 
  background: radial-gradient(circle at top, #0f172a, #050816 70%);
  color: #e2e8f0;
}

.container-fluid { 
  padding-left: 22px; 
  padding-right: 22px; 
}

/* ===== CARD UTAMA ===== */
.cardX {
  background: linear-gradient(
    160deg,
    rgba(15, 23, 42, 0.95) 0%,
    rgba(2, 6, 23, 0.92) 100%
  );

  border-radius: 20px;
  padding: 22px;

  border: 1px solid rgba(0, 255, 200, 0.18);

  box-shadow: 
    0 20px 40px rgba(0,0,0,0.7),
    0 0 30px rgba(0,255,200,0.08);

  backdrop-filter: blur(14px);

  margin-bottom: 24px;

  transition: all .35s ease;

  position: relative;
  overflow: hidden;
}

/* Soft top lighting */
.cardX::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 20px;

  background: linear-gradient(
    to bottom,
    rgba(255,255,255,0.06),
    transparent 45%
  );

  pointer-events: none;
}

/*disini lighting sweep*/

.cardX:hover {
  transform: translateY(-6px);

  box-shadow: 
    0 25px 60px rgba(0,0,0,0.8),
    0 0 40px rgba(0,255,200,0.25);
}

.cardX:hover::after {
  left: 120%;
}

.cardX h3, 
.cardX h4 { 
  color: #00ffd5;
  font-weight: 900;
  letter-spacing: 1px;
}

.muted { 
  color: rgba(226,232,240,0.65); 
}

/* ===== STAT BOX ===== */
.stat-row { 
  display:flex; 
  gap:18px; 
  flex-wrap:wrap; 
}

.stat-box {
  flex: 1 1 220px;

  background: linear-gradient(
    150deg,
    rgba(2, 6, 23, 0.95),
    rgba(10, 15, 30, 0.9)
  );

  border-radius: 18px;
  padding: 20px;

  border: 1px solid rgba(0,255,200,0.22);

  box-shadow: 
    0 15px 30px rgba(0,0,0,0.7),
    0 0 20px rgba(0,255,200,0.1);

  transition: all .35s ease;

  position: relative;
  overflow: hidden;
}

.stat-box::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 18px;

  background: linear-gradient(
    to bottom,
    rgba(255,255,255,0.05),
    transparent 50%
  );

  pointer-events: none;
}

.stat-box:hover {
  transform: translateY(-5px);

  box-shadow: 
    0 20px 45px rgba(0,0,0,0.8),
    0 0 35px rgba(0,255,200,0.3);
}

.stat-title { 
  font-size: 13px; 
  opacity: 0.75; 
  font-weight:700; 
  color:#94a3b8;
}

.stat-value { 
  font-size: 36px; 
  font-weight: 950; 
  margin-top: 6px; 
  color:#00ffd5;
  text-shadow: 0 0 10px rgba(0,255,200,0.6);
}

/* ===== SEARCH LAYOUT ===== */
.search-grid { 
  display:flex; 
  gap:20px; 
  align-items:flex-start; 
}

.panel-left  { flex: 0 0 320px; }
.panel-mid   { flex: 1 1 auto; min-width: 0; }

@media (max-width: 1100px){
  .search-grid { flex-direction: column; }
  .panel-left { width:100%; }
}

/* ===== TABLE HEAD ===== */
.table-head {
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
  flex-wrap:wrap;
  margin-bottom: 14px;
}

/* ===== DATATABLE ===== */
table.dataTable{ 
  width:100% !important; 
  border-radius: 14px;
  overflow:hidden;
  background: rgba(15,23,42,0.9);
}

table.dataTable thead th { 
  background: linear-gradient(90deg, #00ffd5, #00bfff) !important; 
  color:#050816;
  font-weight:900;
  border:none !important;
}

table.dataTable tbody tr { 
  background-color: rgba(15,23,42,0.9) !important; 
  color:#e2e8f0; 
  cursor:pointer; 
  transition: all .2s ease;
}

table.dataTable tbody tr:hover { 
  background: rgba(0,255,200,0.15) !important; 
}

.dataTables_wrapper .dataTables_filter { 
  display:none !important; 
}


/* ================= TAB OVERVIEW ================= */
/* ===== MINI STAT ===== */
.mini-stat {
  border-radius: 18px;
  padding: 18px;

  background: linear-gradient(
    150deg,
    rgba(2, 6, 23, 0.95),
    rgba(10, 15, 30, 0.9)
  );

  border: 1px solid rgba(0,255,200,0.22);

  box-shadow:
    0 15px 30px rgba(0,0,0,0.7),
    0 0 20px rgba(0,255,200,0.08);

  margin-top: 16px;

  transition: all .35s ease;

  position: relative;
  overflow: hidden;
}

/* Soft top lighting */
.mini-stat::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 18px;

  background: linear-gradient(
    to bottom,
    rgba(255,255,255,0.05),
    transparent 50%
  );

  pointer-events: none;
}

/* Moving light sweep subtle */
.mini-stat::after {
  content: '';
  position: absolute;
  top: -100%;
  left: -50%;
  width: 60%;
  height: 300%;

  background: linear-gradient(
    120deg,
    transparent,
    rgba(0,255,200,0.08),
    transparent
  );

  transform: rotate(20deg);
  transition: all .8s ease;
}

.mini-stat:hover {
  transform: translateY(-5px);

  box-shadow:
    0 20px 40px rgba(0,0,0,0.8),
    0 0 30px rgba(0,255,200,0.25);
}

.mini-stat:hover::after {
  left: 120%;
}

/* Text styling */

.mini-label { 
  font-size: 12px; 
  font-weight: 800; 
  letter-spacing: .6px;
  color:#94a3b8;
  opacity: .8;
}

.mini-value { 
  font-size: 24px; 
  font-weight: 950; 
  margin-top: 6px; 
  color:#00ffd5; 
  text-shadow: 0 0 10px rgba(0,255,200,0.6);
}

.mini-sub { 
  margin-top: 6px; 
  font-size: 12px; 
  color: rgba(226,232,240,0.7);
}

/* ===== BADGE ===== */
.badge-soft{
  display:inline-block;
  padding:6px 12px;
  border-radius:999px;
  font-weight:900;
  background: rgba(0,255,200,0.15);
  color:#00ffd5;
  border:1px solid rgba(0,255,200,0.4);
  margin-top: 8px;
  box-shadow: 0 0 10px rgba(0,255,200,0.4);
}

/* ===== SCORE / META CARDS ===== */
.score-card{
  background: linear-gradient(135deg, #6A00FF, #00F5FF);
  border-radius: 20px;
  padding: 20px 18px;
  color: #ffffff;
  box-shadow: 
    0 0 25px rgba(106,0,255,0.35),
    0 0 45px rgba(0,245,255,0.25);
  position: relative;
  overflow: hidden;
  min-height: 180px;
  margin-bottom: 18px;
  transition: all .3s ease;
}

.meta-card{
  background: linear-gradient(135deg, #00F5FF, #00FFB3);
  border-radius: 20px;
  padding: 20px 18px;
  color: #050816;
  box-shadow: 
    0 0 25px rgba(0,245,255,0.35),
    0 0 45px rgba(0,255,179,0.25);
  position: relative;
  overflow: hidden;
  min-height: 180px;
  margin-bottom: 18px;
  transition: all .3s ease;
}

/* Glow Hover */
.score-card:hover,
.meta-card:hover{
  transform: translateY(-6px) scale(1.02);
  box-shadow: 
    0 0 40px rgba(0,255,255,0.6),
    0 0 70px rgba(106,0,255,0.4);
}

/* Decorative Neon Glow Circle */
.score-card::before,
.meta-card::before{
  content:'';
  position:absolute;
  right:-40px;
  top:-40px;
  width:160px;
  height:160px;
  background: radial-gradient(circle, rgba(255,255,255,0.35), transparent 70%);
  border-radius:50%;
  opacity:0.25;
}

/* ===== TEXT STYLE ===== */
.rank-title{ 
  font-size: 28px; 
  font-weight: 950; 
  line-height: 1.15; 
  margin: 0; 
  text-shadow: 0 0 15px rgba(255,255,255,0.6);
  letter-spacing: 1px;
}

.rank-big{ 
  font-size: 20px; 
  font-weight: 950; 
  margin-top: 12px; 
  text-shadow: 0 0 12px rgba(255,255,255,0.7);
}

.rank-pill{
  margin-top: 14px;
  background: rgba(255,255,255,0.15);
  border: 1px solid rgba(255,255,255,0.35);
  border-radius: 999px;
  padding: 10px 14px;
  font-weight: 900;
  display:inline-block;
  backdrop-filter: blur(6px);
  box-shadow: 0 0 10px rgba(255,255,255,0.25);
}

.rank-note{ 
  margin-top: 12px; 
  font-style: italic; 
  font-weight: 900; 
  opacity: .95; 
  text-shadow: 0 0 8px rgba(255,255,255,0.5);
}

/* ===== OPTIONAL: Reduce Motion ===== */
@media (prefers-reduced-motion: reduce){
  .score-card,
  .meta-card {
    transition: none !important;
  }
}

/* ================= ABOUT TEAM ================= */
.cardX:has(.team-grid) h3 {
  text-align: center;
  font-weight: 950;
  letter-spacing: 1px;
  color: #00ffd5;
  text-shadow: 0 0 12px rgba(0,255,200,0.5);
  margin-bottom: 20px;
}

.team-grid { 
  display:flex; 
  flex-wrap:wrap; 
  gap:20px;
  justify-content:center; 
}

.team-card {
  width: 260px;
  max-width: 100%;

  background: linear-gradient(
    160deg,
    rgba(15,23,42,0.95),
    rgba(2,6,23,0.92)
  );

  border: 1px solid rgba(0,255,200,0.18);
  border-radius: 20px;

  overflow:hidden;
  text-align:left;

  box-shadow: 
    0 20px 40px rgba(0,0,0,0.7),
    0 0 25px rgba(0,255,200,0.08);

  transition: all .35s ease;

  position:relative;
}

.team-card::before{
  content:'';
  position:absolute;
  inset:0;
  border-radius:20px;

  background: linear-gradient(
    to bottom,
    rgba(255,255,255,0.05),
    transparent 50%
  );

  pointer-events:none;
}

.team-card:hover{ 
  transform: translateY(-6px); 

  box-shadow: 
    0 25px 60px rgba(0,0,0,0.8),
    0 0 35px rgba(0,255,200,0.25);
}

/* Photo */

.team-photo { 
  width:100%; 
  height:220px; 
  object-fit:cover; 
  background:#0f172a; 
  transition: transform .3s ease, filter .3s ease;
}

.team-card:hover .team-photo{ 
  transform: scale(1.05);
  filter: brightness(1.05);
}

/* Glow line under photo */
.team-card::after{
  content:'';
  position:absolute;
  top:220px; /* tinggi foto */
  left:50%;
  transform:translateX(-50%);
  width:0%;
  height:2px;

  background: linear-gradient(
    90deg,
    transparent,
    #00ffd5,
    transparent
  );

  box-shadow: 0 0 10px rgba(0,255,200,0.8);

  transition: width .4s ease;
}

.team-card:hover::after{
  width:70%;
}

/* Name */
.team-name { 
  padding: 14px 14px 0 14px; 
  font-weight: 950; 
  font-size: 16px; 
  color:#e6fdfc;
  text-align:center;
}

/* Role Badge */
.role-pill{
  display:block;
  width:fit-content;
  margin: 10px auto 0 auto;

  padding: 7px 14px;

  border-radius: 999px;
  font-weight: 900;
  font-size: 11px;
  letter-spacing:.6px;

  background: linear-gradient(
    135deg,
    rgba(0,255,200,0.18),
    rgba(0,255,200,0.08)
  );

  border: 1px solid rgba(0,255,200,0.35);
  color:#00ffd5;

  box-shadow:
    0 0 15px rgba(0,255,200,0.2);

  text-align:center;
}

/* Meta text */
.team-meta{
  padding: 12px 14px 16px 14px;
  color: rgba(226,232,240,0.75);
  font-size: 12px;
  line-height: 1.4;
  text-align:center;
}

"))
  ),
  
  
  ### NAV BAR ### 
  navbarPage(
    title = "",
    
    # ================= HOME =================
    tabPanel(
      "Home",
      br(),
      fluidPage(
        
        div(
          class = "hero-box",
          
          h1(style="margin:0;", "Welcome to Game Dashboard"),
          
          p(style="margin-top:10px;", "Explore insights and trends from game data")
        ),
        
        br(),
        
        # TOTAL CARD
        fluidRow(
          
          column(6,
                 div(class="card-soft card-game",
                     div(class="card-title", "Total Game"),
                     div(class="card-value", textOutput("total_game"))
                 )
          ),
          
          column(6,
                 div(class="card-soft card-review",
                     div(class="card-title", "Total Review"),
                     div(class="card-value", textOutput("total_review"))
                 )
          )
        ),
        
        br(),
        br(),
        
        # GAME BANNER
        div(
          style="position:relative; width:100%;",
          
          div(
            style="position:relative; z-index:1;",
            uiOutput("banner_container")
          ),
          
          actionButton(
            "prev_btn", "",
            icon = icon("chevron-left"),
            class = "nav-btn left-btn"
          ),
          
          actionButton(
            "next_btn", "",
            icon = icon("chevron-right"),
            class = "nav-btn right-btn"
          )
        ),
        
        br(),
        
        # REKOMENDASI GAME BY AGE RATING
        h3("Age-Based Game Recommendations"),
        
        div(
          class = "card-container",
          uiOutput("age_recommendation")
        ),
        
        # REKOMENDASI GAME BY GENRE
        h3("Genre-Based Game Recommendations"),
        
        div(
          class = "card-container",
          uiOutput("genre_recommendation")
        ),
        
        br(),
        br(),
        
        footer_ui
      )
    ),
    
    # ================= SEARCH =================
    tabPanel(
      "Search",
      br(),
      div(
        class="search-grid",
        div(
          class="panel-left",
          div(
            class="cardX",
            h3("Filter"),
            selectInput("f_genre", "Genre", choices = c("All")),
            selectInput("f_platform", "Platform", choices = c("All")),
            selectInput("f_age", "Age Rating", choices = c("All")),
            sliderInput("f_score", "Score Game", min = 1, max = 4, value = 1, step = 0.1),
            br(),
            fluidRow(
              column(6, actionButton("btn_ok", "OK", class="btn btn-primary", icon = icon("check"), width="100%")),
              column(6, actionButton("btn_reset", "Reset", class="btn btn-default", icon = icon("rotate-left"), width="100%"))
            )
          )
        ),
        div(
          class="panel-mid",
          div(
            class="cardX",
            div(
              class="table-head",
              div(
                tags$div(style="font-size:18px;font-weight:900;", "Game Table"),
              ),
              textInput("search_text", NULL, placeholder = "Search title...", width = "320px")
            ),
            DTOutput("tbl_search", width = "100%")
          )
        )
      ),
      br(),
      br(),
      footer_ui
    ),
    
    # ================= OVERVIEW =================
    tabPanel(
      "Overview",
      br(),
      fluidRow(
        column(
          4,
          div(
            class="cardX",
            h3(""),
            div(
              class="stat-box",
              div(class="stat-title", "Most Popular Genre"),
              div(class="stat-value", textOutput("ov_most_popular_genre")),
              div(class="muted", textOutput("ov_most_popular_genre_sub"))
            ),
            uiOutput("ov_stat_2016"),
            uiOutput("ov_stat_platform"),
            uiOutput("ov_stat_age"),
            uiOutput("ov_stat_best_genre_score")
          )
        ),
        column(
          8,
          div(
            class="cardX",
            h3("Genre (based on reviews)"),
            shinycssloaders::withSpinner(plotlyOutput("ov_genre_pie", height = 380))
          ),
          div(
            class="cardX",
            h4("Game Score Distribution"),
            p(class="muted", "Viewing the distribution of all game scores (histogram)."),
            shinycssloaders::withSpinner(plotlyOutput("ov_score_dist", height = 300))
          )
        )
      ),
      br(),
      fluidRow(
        column(4, uiOutput("ov_best_score_card"), uiOutput("ov_best_meta_card")),
        column(
          8,
          div(
            class="cardX",
            h4("Top Games by Score"),
            DTOutput("ov_top10_score_tbl")
          )
        )
      ),
      br(),
      h3("Review Overview"),
      fluidRow(
        column(
          7,
          div(
            class="cardX",
            p(class="muted", "Click on a bar in the chart to select a game."),
            shinycssloaders::withSpinner(plotlyOutput("ov_top10_review_bar", height = 360))
          )
        ),
        column(
          5,
          div(
            class="cardX",
            h5("Review Content (5 most recent)"),
            DTOutput("ov_latest_reviews_tbl")
          )
        )
      ),
      div(
        class="cardX",
        h3("Game Release Trend"),
        shinycssloaders::withSpinner(plotlyOutput("ov_release_trend", height = 360))
      ),
      br(),
      br(),
      footer_ui
    ),
    
    # ================= TEAM =================
    tabPanel(
      "About Team",
      br(),
      div(
        class="cardX",
        h3("Victory Team"),
        br(),
        div(
          class="team-grid",
          div(
            class="team-card",
            tags$img(src = "team1.jpg", class="team-photo"),
            div(class="team-name", "Inria Purwaningsih"),
            div(class="role-pill", "Database Manager"),
            div(class="team-meta", "Managing schemas, queries, index optimization, and data integrity.")
          ),
          div(
            class="team-card",
            tags$img(src = "team2.jpg", class="team-photo"),
            div(class="team-name", "Izzul Haq"),
            div(class="role-pill", "Backend Developer"),
            div(class="team-meta", "Server-side logic, data integration, and application process security.")
          ),
          div(
            class="team-card",
            tags$img(src = "team3.jpg", class="team-photo"),
            div(class="team-name", "Dwi Erzalianti"),
            div(class="role-pill", "Frontend Developer"),
            div(class="team-meta", "UI/UX in Shiny, layout design, animations, and interactive visual components.")
          ),
          div(
            class="team-card",
            tags$img(src = "team4.jpg", class="team-photo"),
            div(class="team-name", "Dinda Ardhia Ramadhani Kusuma"),
            div(class="role-pill", "Data Analyst"),
            div(class="team-meta", "Trend analysis, genre/platform insights, and data & chart interpretation.")
          )
        )
      ),
      br(),
      br(),
      footer_ui
    )
  )
)

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
        p(data$genre[i])   # ← GANTI INI
      )
    })
    
    div(class = "card-container", cards)
  })
  
  # =============================
  # SEARCH + OVERVIEW (dari koding 2)
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

# ===== OVERVIEW OUTPUTS =====
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
               div(class="mini-label","Popular Games (2016)"),
               div(class="mini-value","-"),
               div(class="mini-sub","No data for 2016 / no reviews available yet."),
               div(class="badge-soft","Release Year Analysis")
    ))
  }
  div(class="mini-stat",
      div(class="mini-label","Popular Games (2016)"),
      div(class="mini-value", df$game_title[1]),
      div(class="mini-sub", paste0("Total Reviews: ", df$total_review[1])),
      div(class="badge-soft","Release Year Analysis")
  )
})

output$ov_stat_platform <- renderUI({
  df <- safe_query(q_top_platform_played)
  if ("error" %in% names(df) || nrow(df) == 0) {
    return(div(class="mini-stat",
               div(class="mini-label","Most Frequently Played Platform"),
               div(class="mini-value","-"),
               div(class="mini-sub","Platform data is not available."),
               div(class="badge-soft","Platform Analysis")
    ))
  }
  div(class="mini-stat",
      div(class="mini-label","Most Frequently Played Platform"),
      div(class="mini-value", df$platform_name[1]),
      div(class="mini-sub", paste0("Total Occurrences: ", df$total_usage[1])),
      div(class="badge-soft","Platform Analysis")
  )
})

output$ov_stat_age <- renderUI({
  df <- safe_query(q_top_age_rating)
  if ("error" %in% names(df) || nrow(df) == 0) {
    return(div(class="mini-stat",
               div(class="mini-label","Most Common Age Rating"),
               div(class="mini-value","-"),
               div(class="mini-sub","Age rating data is not available."),
               div(class="badge-soft","Audience Analysis")
    ))
  }
  div(class="mini-stat",
      div(class="mini-label","Most Common Age Rating"),
      div(class="mini-value", df$age_rating[1]),
      div(class="mini-sub", paste0("Total Games: ", df$total_game[1])),
      div(class="badge-soft","Audience Analysis")
  )
})

#### Pie Chart ####
output$ov_genre_pie <- renderPlotly({
  df <- safe_query(q_genre_pie)
  if ("error" %in% names(df) || nrow(df) == 0) return(plotly_empty("No genre pie data"))
  
  df <- df %>% 
    arrange(desc(total_review))
  
  threshold <- 5
  df <- df %>% mutate(
    pct_label = ifelse(!is.na(percentage) & percentage >= threshold, 
                       paste0(percentage, "%"), ""),
    pull_val  = ifelse(!is.na(percentage) & percentage >= threshold, 
                       0.07, 0.01)
  )
  
  plot_ly(
    df,
    labels = ~genre_name,
    values = ~total_review,
    type = "pie",
    hole = 0.55,   # <-- jadi donut (lebih modern)
    
    text = ~pct_label,
    textinfo = "text",
    textposition = "inside",
    
    insidetextfont = list(color = "#ffffff", size = 13),
    
    pull = ~pull_val,
    
    marker = list(
      colors = c(
        "#00ffd5", "#00c8ff", "#00f5ff",
        "#0099cc", "#00bfa5", "#14b8a6",
        "#22d3ee", "#0891b2"
      ),
      line = list(color = "#0f172a", width = 3)
    ),
    
    hovertemplate = "<b>%{label}</b><br>Reviews: %{value}<br>Percent: %{percent}<extra></extra>"
    
  ) %>%
    
    layout(
      showlegend = TRUE,
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      
      legend = list(
        font = list(color = "#cbd5e1"),
        orientation = "v"
      ),
      
      margin = list(t = 10, b = 10, l = 10, r = 10)
    ) %>%
    
    config(displayModeBar = FALSE)
})

output$ov_top10_score_tbl <- renderDT({
  df <- safe_query(q_top10_score)
  validate(
    need(!("error" %in% names(df)), paste("Query failed:", df$error[1])),
    need(nrow(df) > 0, "Top 10 data is empty.")
  )
  out <- df %>% transmute(Title = game_title, Score = score, TotalVote = total_vote, Metascore = metascore)
  datatable(out, rownames = FALSE, options = list(pageLength = 10, scrollX = TRUE))
})

output$ov_best_score_card <- renderUI({
  best <- safe_query(q_best_score)
  game  <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$game_title[1]
  value <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$score[1]
  div(class="score-card",
      div(class="rank-title", HTML("Status: <b>Highest Score</b>")),
      div(class="rank-big", paste0("Game: ", game)),
      div(class="rank-pill", paste0("Score: ", value)),
      div(class="rank-note", "Note: Highest user rating in the dataset.")
  )
})

output$ov_best_meta_card <- renderUI({
  best <- safe_query(q_best_metascore)
  game  <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$game_title[1]
  value <- if ("error" %in% names(best) || nrow(best)==0) "-" else best$metascore[1]
  div(class="meta-card",
      div(class="rank-title", HTML("Status: <b>Highest Metascore</b>")),
      div(class="rank-big", paste0("Game: ", game)),
      div(class="rank-pill", paste0("Metascore: ", value)),
      div(class="rank-note", "Note: Highest critic score.")
  )
})

output$ov_stat_best_genre_score <- renderUI({
  df <- safe_query(q_best_avg_genre)
  
  if ("error" %in% names(df) || nrow(df) == 0) {
    return(div(class="mini-stat",
               div(class="mini-label","Genre with the Highest Average Score"),
               div(class="mini-value","-"),
               div(class="mini-sub","Data is not available."),
               div(class="badge-soft","Genre Quality Analysis")
    ))
  }
  
  div(class="mini-stat",
      div(class="mini-label","Genre with the Highest Average Score"),
      div(class="mini-value", df$genre_name[1]),
      div(class="mini-sub", paste0("Average Score: ", df$avg_score[1])),
      div(class="badge-soft","Genre Quality Analysis")
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
  
  df <- df %>% arrange(total_review)
  
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
      line = list(color = "#0f172a", width = 1.5)
    ),
    
    opacity = 0.9,
    
    hovertemplate = 
      "<b>%{y}</b><br>Total Reviews: %{x:,}<extra></extra>"
  ) %>%
    
    layout(
      title = NULL,
      
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      
      xaxis = list(
        title = "Total Reviews",
        color = "#cbd5e1",
        gridcolor = "rgba(255,255,255,0.05)",
        zeroline = FALSE
      ),
      
      yaxis = list(
        title = "",
        color = "#e2e8f0",
        automargin = TRUE
      ),
      
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
  validate(need(!is.null(gid), "Click on the bar chart to select a game."))
  df <- safe_query(q_latest5_reviews_by_game, params = list(gid))
  validate(need(!("error" %in% names(df)), paste("Review query failed:", df$error[1])))
  
  if (nrow(df) == 0) {
    return(datatable(data.frame(Message = "There are no reviews for this game yet."), rownames = FALSE, options = list(dom='t')))
  }
  
  out <- df %>% transmute(Username = username, Review = review_text, Date = review_date)
  datatable(out, rownames = FALSE, options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, scrollX = TRUE))
})

#### Bar Chart ####
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
        color = "#cbd5e1",
        gridcolor = "rgba(255,255,255,0.05)",
        zeroline = FALSE
      ),
      
      yaxis = list(
        title = "Jumlah Game",
        color = "#cbd5e1",
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
      color = "#00ffd5",
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
        color = "#cbd5e1",
        gridcolor = "rgba(255,255,255,0.05)",
        zeroline = FALSE
      ),
      
      yaxis = list(
        title = "Total Games",
        color = "#cbd5e1",
        gridcolor = "rgba(255,255,255,0.05)",
        zeroline = FALSE
      ),
      
      margin = list(t = 10, r = 10, l = 50, b = 40)
    ) %>%
    
    config(displayModeBar = FALSE)
})

# ===== PENCARIAN: choices =====
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
      URL = trimws(ifelse(is.na(game_url), "", game_url))  # untuk klik (disembunyikan)
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

shinyApp(ui = ui, server = server)