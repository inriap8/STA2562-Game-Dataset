# =========================
# LIBRARY
# =========================
library(shiny)
library(plotly)
library(DT)
library(shinycssloaders)


# =========================
# FOOTER
# =========================
footer_ui <- div(
  style = "
    background: rgba(255,255,255,0.35);
    backdrop-filter: blur(12px);
    padding: 30px;
    border-radius: 20px;
    text-align: center;
    margin-top: 25px;

    border: 1px solid rgba(139,92,246,0.25);

    box-shadow: 
      0 10px 30px rgba(0,0,0,0.15),
      0 0 20px rgba(139,92,246,0.15);

    line-height: 1.3;
    color: #1e293b;
    font-size: 14px;
  ",
  tags$div(
    style = "
      font-size:18px; 
      font-weight:700; 
      color:#7c3aed; 
      text-shadow:0 0 10px rgba(139,92,246,0.35); 
      margin-bottom:8px;
    ",
    "Kelompok 1 — Game Dataset Analytics"
  ),
  tags$div(
    style="color:#4c1d95;",
    "Magister Statistika dan Sains Data"
  ),
  tags$div(
    style="color:#5b21b6;",
    "Departemen Statistika dan Data Sains — SSMI IPB University"
  ),
  tags$div(
    style="margin-top:8px; color:#6366f1;",
    "Kampus IPB Dramaga, Bogor 16680, Indonesia"
  ),
  tags$hr(
    style="border-color:rgba(139,92,246,0.25); margin:15px 0;"
  ),
  tags$div(
    style="color:#06b6d4;",
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
@keyframes gradientMove {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

html, body {
  background: linear-gradient(
  135deg,
  #eef2ff,
  #e0e7ff,
  #dbeafe,
  #e0f2fe
  ) !important;

  background-size: 200% 200%;
  background-attachment: fixed;
  min-height: 100vh;
  color: #1e293b;
}

h1, h2, h3, h4 {
  color: #6d28d9;
  text-shadow: 0 2px 10px rgba(109,40,217,0.2);
}

p {
  color: rgba(30,41,59,0.75);
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
  background: rgba(255, 255, 255, 0.35) !important;

  border: 1px solid rgba(139, 92, 246, 0.35);

  box-shadow:
    0 0 20px rgba(139, 92, 246, 0.25),
    inset 0 0 10px rgba(255,255,255,0.4);
}

.navbar-nav > li > a {
  color: rgba(79, 70, 229, 0.75) !important;
  border-radius: 20px;
  transition: 0.3s;
}

.navbar-nav > li > a:hover {
  color: #06b6d4 !important;
  text-shadow: 0 0 10px rgba(6,182,212,0.6);
}

.navbar-nav > .active > a {
  background: rgba(139,92,246,0.15) !important;
  box-shadow: 0 0 12px rgba(139,92,246,0.35);
  color: #7c3aed !important;
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
    linear-gradient(135deg, #6366f1 0%, #a855f7 40%, #22d3ee 100%);

  border: none;

  box-shadow:
    0 30px 80px rgba(0,0,0,0.35),
    0 0 80px rgba(139,92,246,0.35);

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
    rgba(255,255,255,0.18),
    rgba(139,92,246,0.18),
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
    0 35px 90px rgba(0,0,0,0.4),
    0 0 100px rgba(139,92,246,0.45);
}

.hero-box h1 {
  font-size: 42px;
  font-weight: 800;

  text-shadow:
    0 0 25px rgba(255,255,255,0.7),
    0 0 50px rgba(139,92,246,0.9);
}

.hero-box p {
  font-size: 17px;
  color: #ffffff;
  opacity: 0.6;
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
    rgba(255,255,255,0.18),
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
    0 15px 40px rgba(0,0,0,0.35),
    0 0 40px rgba(139,92,246,0.18);

  transition: all 0.35s ease;
}

/* Hover subtle */
.card-soft:hover {
  transform: translateY(-4px) scale(1.01);
  box-shadow:
    0 20px 50px rgba(0,0,0,0.4),
    0 0 60px rgba(139,92,246,0.28);
}

.card-game {
  background: linear-gradient(
    135deg,
    #6366f1 0%,
    #8b5cf6 45%,
    #22d3ee 100%
  );
}

.card-review {
  background: linear-gradient(
    135deg,
    #22d3ee 0%,
    #67e8f9 50%,
    #a855f7 100%
  );
}

.card-title {
  font-size: 20px;
  font-weight: 550;
  color: #ffffff;
}
  
.card-value {
  font-size: 42px;
  font-weight: 900;
  color: #ffffff;

  text-shadow:
    0 0 15px rgba(255,255,255,0.6),
    0 0 25px rgba(139,92,246,0.7);
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
    0 0 20px rgba(139,92,246,0.35),
    0 0 60px rgba(139,92,246,0.2),
    0 20px 60px rgba(0,0,0,0.35);
}

.banner-container:hover {
  transform: scale(1.01);
  box-shadow: 
    0 0 30px rgba(139,92,246,0.6),
    0 0 80px rgba(139,92,246,0.35),
    0 30px 80px rgba(0,0,0,0.45);
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
    rgba(139,92,246,0.4),
    transparent
  );
  opacity: 0;
  transition: 0.5s;
}

.banner-content h1,
.banner-content h2 {
  color: #8b5cf6;
  text-shadow: 0 0 15px rgba(139,92,246,0.9);
}

.banner-content p {
  color: #e0e7ff;
}

/* VIDEO */
.banner-video {
  position: absolute;
  width: 100%;
  height: 100%;
  object-fit: cover;
  pointer-events: none;

  filter: brightness(0.75) contrast(1.1);
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
    rgba(30,27,75,0.6),
    rgba(30,27,75,0.2),
    rgba(30,27,75,0)
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

/* TITLE */
.banner-title {
  color: #ffffff;
  font-size: 42px;
  font-weight: 700;

  text-shadow: 0 0 15px rgba(139,92,246,0.8);
}

/* DESCRIPTION */
.banner-desc {
  color: #e0e7ff;
  font-size: 15px;
  margin-top: 10px;
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

  color: #ffffff;
  background: linear-gradient(135deg, #8b5cf6, #22d3ee);

  box-shadow: 
    0 0 15px rgba(139,92,246,0.7),
    0 0 30px rgba(139,92,246,0.4);

  transition: 0.3s;
}

.btn-modern:hover {
  transform: translateY(-3px);
  box-shadow: 
    0 0 30px rgba(139,92,246,1),
    0 0 60px rgba(139,92,246,0.8);
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

  color: #8b5cf6;
  font-size: 20px;

  background: rgba(255,255,255,0.35);

  box-shadow: 
    0 0 15px rgba(139,92,246,0.7),
    0 0 30px rgba(139,92,246,0.3);

  transition: 0.3s;
}

.nav-btn i {
  color: #8b5cf6;
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
  background: linear-gradient(90deg, #8b5cf6, #22d3ee);
  border-radius: 10px;
}

/* Card */
.card-age {
  width: 223px;
  flex: 0 0 auto;

  background: linear-gradient(
    145deg,
    rgba(139,92,246,0.12),
    rgba(34,211,238,0.10)
  );

  padding: 18px;
  border-radius: 22px;
  text-align: center;

  color: #1e293b;

  border: 1px solid rgba(255,255,255,0.35);

  box-shadow:
    0 12px 30px rgba(0,0,0,0.15),
    0 0 20px rgba(139,92,246,0.18);

  transition: all 0.35s ease;

  position: relative;
  overflow: hidden;

  backdrop-filter: blur(10px);
}

/* Soft inner glow */
.card-age::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 22px;

  background: radial-gradient(
    circle at top left,
    rgba(139,92,246,0.18),
    transparent 60%
  );

  pointer-events: none;
}

/* Hover Effect - subtle */
.card-age:hover {
  transform: translateY(-4px);

  box-shadow:
    0 18px 40px rgba(0,0,0,0.18),
    0 0 30px rgba(139,92,246,0.28);
}

/* Image */
.card-age img {
  width: 100%;
  height: 140px;
  object-fit: cover;
  border-radius: 14px;

  box-shadow:
    0 8px 18px rgba(0,0,0,0.25);
}

/* Title */
.game-title {
  font-size: 15px;
  margin-top: 12px;
  color: #4c1d95;
  font-weight: 700;

  text-shadow:
    0 0 12px rgba(139,92,246,0.5);
}

/* Description */
.game-desc {
  font-size: 12px;
  color: rgba(30,41,59,0.75);
}

/* ================= TAB SEARCH ================= */
body { 
  background:
    radial-gradient(circle at top, #0b132b, #050816 70%),
    linear-gradient(135deg, #0b132b, #0f172a, #111827);
}

.container-fluid { 
  padding-left: 22px; 
  padding-right: 22px; 
}

/* ===== CARD UTAMA ===== */
.cardX {
  background: linear-gradient(
    160deg,
    rgba(255,255,255,0.85) 0%,
    rgba(240,249,255,0.82) 100%
  );

  border-radius: 20px;
  padding: 22px;

  border: 1px solid rgba(120,255,255,0.35);

  backdrop-filter: blur(14px);

  box-shadow: 
    0 15px 35px rgba(0,0,0,0.15),
    0 0 20px rgba(120,255,255,0.08);

  margin-bottom: 24px;

  transition: all .35s ease;

  position: relative;
  overflow: hidden;
}

.cardX h3,
.cardX h4 { 
  color: #0f172a;
  font-weight: 900;
  letter-spacing: 1px;
}

/* ===== STAT BOX ===== */

.stat-box {
  flex: 1 1 220px;

  background: linear-gradient(
    150deg,
    rgba(255,255,255,0.9),
    rgba(241,245,249,0.85)
  );

  border-radius: 18px;
  padding: 20px;

  border: 1px solid rgba(120,255,255,0.35);

  box-shadow: 
    0 10px 25px rgba(0,0,0,0.12),
    0 0 15px rgba(120,255,255,0.05);

  transition: all .35s ease;

  position: relative;
  overflow: hidden;
}

.stat-title { 
  font-size: 13px; 
  opacity: 0.8; 
  font-weight:700; 
  color:#475569;
}

.stat-value { 
  font-size: 36px; 
  font-weight: 950; 
  margin-top: 6px; 
  color:#06b6d4;
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

  background: rgba(255,255,255,0.85);

  border: 1px solid rgba(120,255,255,0.25);

  box-shadow:
    0 10px 30px rgba(0,0,0,0.25),
    0 0 15px rgba(120,255,255,0.08);
}

table.dataTable thead th { 
  background: linear-gradient(
    90deg,
    #22d3ee,
    #a78bfa
  ) !important;

  color:#020617;
  font-weight:900;
  border:none !important;
}

table.dataTable tbody tr { 
  background-color: rgba(255,255,255,0.92) !important; 
  color:#0f172a; 
  cursor:pointer; 
  transition: all .2s ease;
}

table.dataTable tbody tr:hover { 
  background: rgba(34,211,238,0.18) !important; 
}

.dataTables_wrapper .dataTables_filter { 
  display:none !important; 
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

  background: rgba(255,255,255,0.85);

  border: 1px solid rgba(120,255,255,0.25);

  box-shadow:
    0 10px 30px rgba(0,0,0,0.25),
    0 0 15px rgba(120,255,255,0.08);
}

table.dataTable thead th { 
  background: linear-gradient(
    90deg,
    #22d3ee,
    #a78bfa
  ) !important;

  color:#020617;
  font-weight:900;
  border:none !important;
}

table.dataTable tbody tr { 
  background-color: rgba(255,255,255,0.92) !important; 
  color:#0f172a; 
  cursor:pointer; 
  transition: all .2s ease;
}

table.dataTable tbody tr:hover { 
  background: rgba(34,211,238,0.18) !important; 
}

.dataTables_wrapper .dataTables_filter { 
  display:none !important; 
}


/* ================= TAB OVERVIEW ================= */
/* ===== MINI STAT ===== */
.mini-stat {
  border-radius: 18px;
  padding: 18px;
  background: linear-gradient(150deg, #ffffff, #f0f4f8);
  border: 1px solid rgba(34, 211, 238, 0.35);
  box-shadow: 0 10px 25px rgba(0,0,0,0.1), 0 0 15px rgba(34,211,238,0.08);
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
  background: linear-gradient(to bottom, rgba(255,255,255,0.4), transparent 50%);
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
    rgba(128,128,128,0.08),
    transparent
  );
  transform: rotate(20deg);
  transition: all .8s ease;
}

.mini-stat:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 35px rgba(0,0,0,0.15), 0 0 25px rgba(34,211,238,0.2);
}

.mini-stat:hover::after {
  left: 120%;
}

/* Text styling */
.mini-label { 
  font-size: 12px; 
  font-weight: 800; 
  letter-spacing: .6px;
  color: #475569;
  opacity: 0.9;
}

.mini-value { 
  font-size: 24px; 
  font-weight: 950; 
  margin-top: 6px; 
}

.mini-sub { 
  margin-top: 6px; 
  font-size: 12px; 
  color: rgba(30,41,59,0.7);
}

/* ===== MINI STAT COLOR VARIANTS ===== */
.mini-cyan {background: linear-gradient(135deg, #cffafe, #67e8f9); border: 1px solid #06b6d4; }
.mini-cyan .mini-value {color: #06b6d4; }

.mini-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe); border:1px solid #3b82f6; }
.mini-blue .mini-value { color: #3b82f6; }

.mini-green { background: linear-gradient(135deg, #dcfce7, #bbf7d0); border:1px solid #22c55e; }
.mini-green .mini-value { color: #22c55e; }

.mini-purple { background: linear-gradient(135deg, #ede9fe, #ddd6fe); border:1px solid #a855f7; }
.mini-purple .mini-value { color: #a855f7; }

.mini-orange { background: linear-gradient(135deg, #ffedd5, #fed7aa); border:1px solid #f97316; }
.mini-orange .mini-value { color: #f97316; }

/* ===== BADGE ===== */
.badge-soft {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 999px;
  font-weight: 900;
  background: rgba(34,211,238,0.18);
  color: #0891b2;
  border: 1px solid rgba(34,211,238,0.4);
  margin-top: 8px;
  box-shadow: 0 0 8px rgba(34,211,238,0.25);
}

/* Badge color variants */
.badge-pink {background: rgba(236,72,153,0.15); color: #db2777; border: 1px solid rgba(236,72,153,0.4); }
.badge-blue { background: rgba(59,130,246,0.15); color: #2563eb; border: 1px solid rgba(59,130,246,0.4); }
.badge-green { background: rgba(34,197,94,0.15); color: #16a34a; border: 1px solid rgba(34,197,94,0.4); }
.badge-purple { background: rgba(168,85,247,0.15); color: #9333ea; border: 1px solid rgba(168,85,247,0.4); }
.badge-orange { background: rgba(249,115,22,0.15); color: #ea580c; border: 1px solid rgba(249,115,22,0.4); }

/* ===== SCORE / META CARDS ===== */
.score-card {
  background: linear-gradient(135deg, #6366f1, #22d3ee);
  border-radius: 20px;
  padding: 20px 18px;
  color: #ffffff;
  box-shadow: 0 10px 30px rgba(99,102,241,0.25), 0 10px 30px rgba(34,211,238,0.2);
  position: relative;
  overflow: hidden;
  min-height: 180px;
  margin-bottom: 18px;
  transition: all .3s ease;
}

.meta-card {
  background: linear-gradient(135deg, #22d3ee, #a78bfa);
  border-radius: 20px;
  padding: 20px 18px;
  color: #050816;
  box-shadow: 0 10px 30px rgba(34,211,238,0.25), 0 10px 30px rgba(167,139,250,0.2);
  position: relative;
  overflow: hidden;
  min-height: 180px;
  margin-bottom: 18px;
  transition: all .3s ease;
}

.score-card:hover,
.meta-card:hover {
  transform: translateY(-6px) scale(1.02);
  box-shadow: 0 15px 40px rgba(34,211,238,0.35), 0 15px 40px rgba(167,139,250,0.3);
}

.score-card::before,
.meta-card::before {
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
.rank-title { font-size: 28px; font-weight: 950; line-height: 1.15; margin: 0; letter-spacing: 1px; }
.rank-big { font-size: 20px; font-weight: 950; margin-top: 12px; }
.rank-pill { margin-top: 14px; background: rgba(255,255,255,0.35); border: 1px solid rgba(255,255,255,0.5); border-radius: 999px; padding: 10px 14px; font-weight: 900; display:inline-block; backdrop-filter: blur(6px); box-shadow: 0 0 10px rgba(255,255,255,0.25); }
.rank-note { margin-top: 12px; font-style: italic; font-weight: 900; opacity: .95; text-shadow: 0 0 8px rgba(255,255,255,0.5); }

/* ===== OPTIONAL: Reduce Motion ===== */
@media (prefers-reduced-motion: reduce){
  .score-card,
  .meta-card {
    transition: none !important;
  }
}

/* paksa warna axis plotly supaya terlihat di light dashboard */
.js-plotly-plot .xtick text,
.js-plotly-plot .ytick text {
  fill: #1e293b !important;
  font-weight: 500;
}

.js-plotly-plot .xaxislayer-above path,
.js-plotly-plot .yaxislayer-above path {
  stroke: #64748b !important;
}

.js-plotly-plot .gridlayer path {
  stroke: rgba(0,0,0,0.08) !important;
}

/* INSIGHT CARD */
.insight-card{
  position:relative;
  background:linear-gradient(
    135deg,
    rgba(34,211,238,0.06),
    rgba(59,130,246,0.05),
    rgba(168,85,247,0.06)
  );

  border-radius:16px;
  padding:20px 22px;

  border:1px solid rgba(0,0,0,0.06);

  transition:all .28s ease;

  backdrop-filter: blur(6px);

  overflow:hidden;
}

/* accent line kiri */
.insight-card::before{
  content:'';
  position:absolute;
  left:0;
  top:0;
  bottom:0;
  width:4px;

  background:linear-gradient(
    180deg,
    #22d3ee,
    #3b82f6,
    #a855f7
  );

  border-radius:4px 0 0 4px;
}

/* hover effect */
.insight-card:hover{
  transform:translateY(-4px);

  box-shadow:
    0 10px 22px rgba(0,0,0,0.08),
    0 0 10px rgba(34,211,238,0.15);
}

/* title */
.insight-card h4{
  font-size:16px;
  font-weight:600;
  margin-bottom:8px;

  color:#0f172a;
}

/* text insight */
.insight-card{
  font-size:14px;
  color:#334155;
  line-height:1.5;
}

/* ================= ABOUT TEAM ================= */
.cardX:has(.team-grid) h2 {
  text-align: center;
  font-weight: 950;
  letter-spacing: 1px;
  background: linear-gradient(90deg,#22d3ee,#3b82f6,#a855f7);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 20px;
}

/* TEAM GRID */
.team-grid { 
  display:flex; 
  flex-wrap:wrap; 
  gap:20px;
  justify-content:center; 
}

/* GLASS CARD */
.team-card {
  width: 260px;
  max-width: 100%;

  background: linear-gradient(
    135deg,
    rgba(34,211,238,0.14),
    rgba(59,130,246,0.12),
    rgba(168,85,247,0.14)
  );

  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);

  border: 1px solid rgba(255,255,255,0.12);
  border-radius: 20px;

  overflow: hidden;
  text-align: left;

  /* shadow tipis */
  box-shadow: 
    0 6px 18px rgba(0,0,0,0.35),
    0 0 12px rgba(34,211,238,0.18);

  transition: all .3s ease;
  position: relative;
}

/* glass shine */
.team-card::before{
  content:'';
  position:absolute;
  inset:0;
  border-radius:20px;

  background: linear-gradient(
    to bottom,
    rgba(255,255,255,0.18),
    transparent 60%
  );

  pointer-events:none;
}

/* hover effect */
.team-card:hover{ 
  transform: translateY(-5px);

  box-shadow: 
    0 10px 25px rgba(0,0,0,0.45),
    0 0 18px rgba(59,130,246,0.25);
}

/* PHOTO */
.team-photo { 
  width:100%; 
  height:260px; 
  object-fit:contain;   
  background:rgba(255,255,255,0.25); 
  padding:10px;
}

.team-card:hover .team-photo{ 
  transform: scale(1.05);
  filter: brightness(1.08);
}

/* glow line */
.team-card::after{
  content:'';
  position:absolute;
  top:260px;
  left:50%;
  transform:translateX(-50%);
  width:0%;
  height:2px;

  background: linear-gradient(
    90deg,
    transparent,
    #22d3ee,
    #3b82f6,
    #a855f7,
    transparent
  );

  box-shadow: 
    0 0 10px #22d3ee,
    0 0 20px #3b82f6,
    0 0 25px #a855f7;

  transition: width .4s ease;
}

.team-card:hover::after{
  width:70%;
}

/* NAME */
.team-name { 
  padding: 14px 14px 0 14px; 
  font-weight: 950; 
  font-size: 16px; 
  color:#6366f1;  
  text-align:center;
  text-shadow: 0 0 6px rgba(99,102,241,0.35);
}

/* ROLE BADGE (GLASS) */
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
    rgba(34,211,238,0.35),
    rgba(59,130,246,0.35),
    rgba(168,85,247,0.35)
  );

  backdrop-filter: blur(10px);

  border: 1px solid rgba(255,255,255,0.25);

  color:#ffffff;

  box-shadow:
    0 0 10px rgba(34,211,238,0.5),
    0 0 18px rgba(168,85,247,0.35);

  text-align:center;
}

/* META TEXT */
.team-meta{
  padding: 12px 14px 16px 14px;
  color: rgba(71,85,105,0.95);
  font-size: 12px;
  line-height: 1.4;
  text-align:center;
}

"))
  ),
  
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
          
          p(style="margin-top:10px;", "This dashboard provides insights into video game trends, 
            including genre popularity, platform usage, score distribution, and review analysis. 
            It helps users explore how the gaming industry evolves over time.")
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
        h3("Age-Based Recommendations"),
        
        div(
          class = "card-container",
          uiOutput("age_recommendation")
        ),
        
        # REKOMENDASI GAME BY GENRE
        h3("Genre-Based Recommendations"),
        
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
                tags$div(style="font-size:18px;font-weight:900;", "Game Table")
              ),
              
              div(
                style="display:flex; flex-direction:column; align-items:flex-end; gap:8px;",
                
                textInput(
                  "search_text",
                  NULL,
                  placeholder = "Search title...",
                  width = "320px"
                ),
                
                downloadButton(
                  "download_csv",
                  "Download CSV",
                  icon = icon("download"),
                  class = "btn btn-success"
                )
              )
              
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
            class = "cardX",
            h3("Summary Statistics"),
            
            # Best Genre
            uiOutput("ov_most_popular_genre"),
            
            # Year 2016 Stat
            uiOutput("ov_stat_2016"),
            
            # Platform Stat
            uiOutput("ov_stat_platform"), 
            
            # Age Stat
            uiOutput("ov_stat_age"), 
            
            # Best Genre Score Stat
            uiOutput("ov_stat_best_genre_score") 
          )
        ),
        
        column(
          8,
          div(
            class="cardX",
            h3("Genre Popularity (Based on Reviews)"),
            shinycssloaders::withSpinner(plotlyOutput("ov_genre_pie", height = 380))
          ),
          
          div(
            class="cardX",
            h3("Game Score Distribution"),
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
            h3("Top Games by Score"),
            DTOutput("ov_top10_score_tbl")
          )
        )
      ),
      
      
      fluidRow(
        column(
          7,
          div(
            class="cardX",
            h3("Review Overview"),
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
        h3("Game Releases Over Time"),
        shinycssloaders::withSpinner(plotlyOutput("ov_release_trend", height = 360))
      ),
      
      div(
        class="cardX",
        h3("Key Insights"),
        
        fluidRow(
          
          column(
            6,
            div(class="insight-card",
                h4("📅 Peak Release Period"),
                textOutput("insight_release")
            )
          ),
          
          column(
            6,
            div(class="insight-card",
                h4("📊 Score Distribution"),
                textOutput("insight_score_dist")
            )
          )
          
        ),
        
        br(),
        
        fluidRow(
          
          column(
            6,
            div(class="insight-card",
                h4("💬 Review Concentration"),
                textOutput("insight_reviews")
            )
          ),
          
          column(
            6,
            div(class="insight-card",
                h4("⭐ Critic vs User Score"),
                textOutput("insight_score_gap")
            )
          )
          
        )
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
        h2("Victory Team"),
        br(),
        div(
          class="team-grid",
          div(
            class="team-card",
            tags$img(src = "team1.png", class="team-photo"),
            div(class="team-name", "Inria Purwaningsih"),
            div(class="role-pill", "Database Manager"),
            div(class="team-meta", "Managing schemas, queries, index optimization, and data integrity.")
          ),
          div(
            class="team-card",
            tags$img(src = "team2.png", class="team-photo"),
            div(class="team-name", "Izzul Haq"),
            div(class="role-pill", "Backend Developer"),
            div(class="team-meta", "Server-side logic, data integration, and application process security.")
          ),
          div(
            class="team-card",
            tags$img(src = "team3.png", class="team-photo"),
            div(class="team-name", "Dwi Erzalianti"),
            div(class="role-pill", "Frontend Developer"),
            div(class="team-meta", "UI/UX in Shiny, layout design, animations, and interactive visual components.")
          ),
          div(
            class="team-card",
            tags$img(src = "team4.png", class="team-photo"),
            div(class="team-name", "Dinda A.R Kusuma"),
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