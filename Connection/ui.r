library(shiny)
library(DBI)
library(RMariaDB)
library(dplyr)
library(plotly)
library(DT)
library(shinycssloaders)

## Safe Query
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
        
        br(),
        
        # REKOMENDASI GAME BY GENRE
        h3("Genre-Based Game Recommendations"),
        
        div(
          class = "card-container",
          uiOutput("genre_recommendation")
        ),
        
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
                tags$div(style="font-size:18px;font-weight:900;", "Tabel Game"),
              ),
              textInput("search_text", NULL, placeholder = "Search title...", width = "320px")
            ),
            DTOutput("tbl_search", width = "100%")
          )
        )
      ),
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
            h3("Genre (berdasarkan review)"),
            shinycssloaders::withSpinner(plotlyOutput("ov_genre_pie", height = 380))
          ),
          div(
            class="cardX",
            h4("Distribusi Score Game"),
            p(class="muted", "Melihat sebaran score seluruh game (histogram)."),
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
            p(class="muted", "Klik bar di chart untuk memilih game."),
            shinycssloaders::withSpinner(plotlyOutput("ov_top10_review_bar", height = 360))
          )
        ),
        column(
          5,
          div(
            class="cardX",
            h5("Isi Review (5 terbaru)"),
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
            div(class="team-meta", "Mengelola skema, query, optimasi indeks, dan integritas data.")
          ),
          div(
            class="team-card",
            tags$img(src = "team2.jpg", class="team-photo"),
            div(class="team-name", "Izzul Haq"),
            div(class="role-pill", "Backend Developer"),
            div(class="team-meta", "Logika server, integrasi data, dan keamanan proses aplikasi.")
          ),
          div(
            class="team-card",
            tags$img(src = "team3.jpg", class="team-photo"),
            div(class="team-name", "Dwi Erzalianti"),
            div(class="role-pill", "Frontend Developer"),
            div(class="team-meta", "UI/UX Shiny, layout, animasi, dan komponen visual interaktif.")
          ),
          div(
            class="team-card",
            tags$img(src = "team4.jpg", class="team-photo"),
            div(class="team-name", "Dinda Ardhia Ramadhani Kusuma"),
            div(class="role-pill", "Data Analyst"),
            div(class="team-meta", "Analisis tren, insight genre/platform, serta interpretasi data & grafik.")
          )
        )
      ),
      br(),
      footer_ui
    )
  )
)
