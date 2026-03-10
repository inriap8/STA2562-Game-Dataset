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
Menampilkan analisis statistik dan visualisasi utama dari data game untuk memahami tren, performa, dan popularitas. Berikut detail setiap visualisasi:

---

### 1. Game Releases Over Time
Menunjukkan tren jumlah rilis game per tahun sehingga dapat mengidentifikasi periode dengan aktivitas rilis tertinggi.
<p align="center">
  <img src="Images/Game Releases Over Time.jpeg" width="600">
</p>

---

### 2. Game Score Distribution
Distribusi skor game membantu melihat persebaran kualitas game berdasarkan rating pengguna.
<p align="center">
  <img src="Images/Game Score Distribution.jpeg" width="600">
</p>

---

### 3. Games Highest Metascore
Menampilkan game dengan nilai kritikus tertinggi, berguna untuk analisis kualitas review profesional.
<p align="center">
  <img src="Images/Games Highest Metascore.png" width="500">
</p>

---

### 4. Games Highest Score
Menunjukkan game dengan skor pengguna tertinggi, membantu menilai kepuasan pemain.
<p align="center">
  <img src="Images/Games Highest Score.png" width="500">
</p>

---

### 5. Genre Highest Average Score
Mengidentifikasi genre dengan rata-rata skor tertinggi, berguna untuk rekomendasi genre populer.
<p align="center">
  <img src="Images/Genre Highest Average Score.png" width="500">
</p>

---

### 6. Genre Popularity Based on Reviews
Visualisasi genre paling populer berdasarkan jumlah review, menilai engagement komunitas.
<p align="center">
  <img src="Images/Genre Popularity Based on Reviews.jpeg" width="500">
</p>

---

### 7. Most Popular Age Rating
Menampilkan age rating dengan jumlah game terbanyak untuk mengetahui target audiens dominan.
<p align="center">
  <img src="Images/Most Popular Age Rating.png" width="500">
</p>

---

### 8. Most Popular Genre
Menunjukkan genre dengan total review terbanyak, berguna untuk analisis popularitas.
<p align="center">
  <img src="Images/Most Popular Genre.png" width="500">
</p>

---

### 9. Most Popular Platform
Menampilkan platform game paling populer berdasarkan jumlah occurrences/total review.
<p align="center">
  <img src="Images/Most Popular Platform.png" width="500">
</p>

---

### 10. Review Overview
Memberikan overview jumlah review per game, membandingkan review user vs critic.
<p align="center">
  <img src="Images/Review Overview.jpeg" width="600">
</p>

---

### 11. Top Game 2016
Menunjukkan game terbaik tahun 2016 berdasarkan skor dan jumlah review.
<p align="center">
  <img src="Images/Top Game 2016.png" width="500">
</p>

---

### 12. Top Games by Score
Menampilkan daftar 10 game terbaik berdasarkan skor, termasuk perbandingan skor pengguna dan kritikus.
<p align="center">
  <img src="Images/Top Games by Score.jpeg" width="600">
</p>

---

### 13. Key Insights
Menyediakan ringkasan insight utama dari data game seperti peak release, score distribution, dan review concentration.
<p align="center">
  <img src="Images/Key Insights.png" width="600">
</p>

---

## About Team
Menampilkan profil anggota tim dan peran masing-masing.

---

# 3. Database Schema & ERD

<p align="center">
  <img src="Images/Skema Tabel.png" width="900">
</p>


Database relasional dengan tabel utama:

- `tbl_games`: Menyimpan informasi dasar tentang setiap game, termasuk id, judul, tanggal rilis, rating pengguna (exceptional, recommended, meh, skip), age rating, metascore, about, link url, dan link gambar dan video preview.  
- `tbl_reviews`: Mencatat review yang diberikan oleh pengguna, termasuk ID review, ID game terkait, ID pengguna, isi review dan tanggal review.  
- `tbl_users`: Berisi informasi tentang pengguna yang membuat review, termasuk username, dan ID pengguna.  
- `tbl_genres`: Menyimpan daftar ID genre dan jenis genre game yang ada di database, misal Action, RPG, Adventure, dan lain-lain. 
- `tbl_platforms`: Mencatat ID platform dan jenis platform tempat game dirilis/dimainkan, misal PC, PlayStation, Xbox, Nintendo Switch, dan sebagainya.  
- `tbl_developers`: Menampung informasi ID pengembang game (developer) dan termasuk nama dan detail perusahaan/pengelola studio.  
- `tbl_publisher`: Berisi informasi ID penerbit (publisher) game dan termasuk nama dan detail perusahaan yang merilis game ke pasar.
 

### ERD

![ERD](Images/ERD.png)

*ERD menunjukkan relasi antar tabel utama dan foreign key.*

| Tabel Relasi     | Atribut                | Primary Key (PK)         | Foreign Key (FK)                       | Keterangan Singkat |
|-----------------|-----------------------|------------------------|---------------------------------------|-----------------|
| DEVELOPED_BY     | developer_id, game_id | (developer_id, game_id) | developer_id → DEVELOPER.developer_id, game_id → GAME.game_id | Menghubungkan game dengan developer |
| PUBLISHED_BY     | publisher_id, game_id | (publisher_id, game_id) | publisher_id → PUBLISHER.publisher_id, game_id → GAME.game_id | Menghubungkan game dengan publisher |
| HAS              | genre_id, game_id     | (genre_id, game_id)    | genre_id → GENRE.genre_id, game_id → GAME.game_id | Menghubungkan game dengan genre |
| AVAILABLE_ON     | platform_id, game_id  | (platform_id, game_id) | platform_id → PLATFORM.platform_id, game_id → GAME.game_id | Menghubungkan game dengan platform |

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
