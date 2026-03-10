<p align="center">
  <img src="Images/Header Github.jpeg" width="900">
</p>

<h1 align="center">Game Platform Dashboard</h1>

<p align="center">
<h3 align="center">Explore Insights and Trends from Game Data</h3>
</p>

---

<h2 align="center">📌 Menu</h2>

<br>

<table align="center" cellpadding="12">
<tr>
<td align="center">
<a href="#1-dashboard-description">
  <img src="https://img.shields.io/badge/1-Dashboard%20Description-A5D8FF?style=for-the-badge"/>
</a>
</td>

<td align="center">
<a href="#2-dashboard-section">
  <img src="https://img.shields.io/badge/2-Dashboard%20Section-B2F2BB?style=for-the-badge"/>
</a>
</td>
</tr>

<tr>
<td align="center">
<a href="#3-database-schema--data-structure">
  <img src="https://img.shields.io/badge/3-Database%20Schema%20&%20Data-FFD6A5?style=for-the-badge"/>
</a>
</td>

<td align="center">
<a href="#4-tools-used">
  <img src="https://img.shields.io/badge/4-Tools%20Used-FFADAD?style=for-the-badge"/>
</a>
</td>
</tr>

<tr>
<td align="center">
<a href="#5-project-folder-structure">
  <img src="https://img.shields.io/badge/5-Project%20Folder%20Structure-CDB4DB?style=for-the-badge"/>
</a>
</td>

<td align="center">
<a href="#6-team-contribution">
  <img src="https://img.shields.io/badge/6-Team%20Contribution-90DBF4?style=for-the-badge"/>
</a>
</td>
</tr>

<tr>
<td align="center">
<a href="#7-team-members">
  <img src="https://img.shields.io/badge/7-Team%20Members-7CE0F3?style=for-the-badge"/>
</a>
</td>
</tr>
</table>
---

# 1. Dashboard Description 

Game Platform Dashboard adalah aplikasi interaktif berbasis **R Shiny** yang dirancang untuk menganalisis dan memvisualisasikan data game dari berbagai aspek.

**Tujuan Proyek:**

- Memberikan insight performa dan popularitas game berdasarkan rating dan review
- Menyediakan rekomendasi game sesuai usia (Age Rating) dan genre
- Memvisualisasikan tren rilis game dan distribusi score
- Membantu analisis keputusan bisnis bagi pengembang dan pemain game

**Fitur utama:**

- 📊 Visualisasi interaktif menggunakan **Plotly**  
- 📋 Tabel dinamis menggunakan **DT**  
- 🔄 Reactive programming pada Shiny  
- 🗄️ Integrasi database menggunakan **DBI + RMariaDB**

---

# 2. Dashboard Section

## Home
Menampilkan:

- Total Game & Total Review  
- Banner Top Game (Video Preview / Image)  
- Rekomendasi Game berdasarkan Age Rating dan Genre  

## Search
Fitur pencarian dan filter interaktif:

- Genre, Platform, Age Rating, Minimum Score
- Tabel interaktif & klik row untuk membuka halaman game
- Download CSV hasil filter

## Overview
Menampilkan analisis statistik dan visualisasi:

- Genre paling populer berdasarkan review
- Distribusi score game
- Top 10 game berdasarkan score
- Top 10 game berdasarkan jumlah review
- Game dengan metascore tertinggi
- Genre dengan rata-rata score tertinggi
- Tren rilis game per tahun
- Insight Cards: Peak release, score distribution, review concentration, user vs critic score

## About Team
Menampilkan profil anggota tim dan peran masing-masing.

---

# 3. Database Schema & Data Structure

Database relasional dengan tabel utama:

- `tbl_games`  
- `tbl_reviews`  
- `tbl_users`  
- `tbl_genres`  
- `tbl_platforms`  
- `tbl_game_genres`  
- `tbl_game_platforms`  

### ERD

![ERD](Images/ERD.png)

*ERD menunjukkan relasi antar tabel utama dan foreign key.*

### Skema Tabel

![Skema Tabel](Images/Skema Tabel.png)

*Skema tabel menampilkan detail kolom, tipe data, dan constraints.*

---

# 4. Tools Used

| Tool | Fungsi | Gambar |
|------|-------|--------|
| **R Studio** | IDE & Language – Lingkungan utama pengembangan skrip R dan manajemen proyek | ![RStudio](Images/5325b05b-d07f-481a-abc2-84dec8849b19.png) |
| **R Shiny** | Web Framework – Membangun dashboard interaktif dan reaktivitas visualisasi | ![R Shiny](Images/R Shiny.png) |
| **DBngin** | DB Engine – Menjalankan mesin database lokal untuk penyimpanan data relasional | ![DBngin](Images/DBngin.png) |
| **TablePlus** | DB Management – Mengelola skema tabel, relasi, dan memvalidasi query SQL secara visual | ![TablePlus](Images/TablePlus.png) |

---

# 5. Project Folder Structure

```bash
project-dashboard/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── app/
│   ├── app.R
│   ├── ui.R
│   └── server.R
│
├── connection/
│   └── db_connection.R
│
├── doc/
│   └── erd.pdf
│
├── Images/
│
└── README.md
