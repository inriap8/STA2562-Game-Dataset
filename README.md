<p align="center">
  <img src="Images/Header Github.jpeg" width="900">
</p>

<h1 align="center">Game Platform Dashboard</h1>

<p align="center">
Explore insights and trends from game data
</p>

---

<h2 align="center">Menu</h2>

<table align="center" cellspacing="12">
<tr>

<td align="center">
<a href="#1-description-about-dashboard" style="text-decoration:none;">
<div style="background-color:#A5D8FF; color:#1f2937; padding:10px 18px; border-radius:8px; width:190px; font-size:13px;">
<b>1</b><br>
DESCRIPTION
</div>
</a>
</td>

<td align="center">
<a href="#2-dashboard-section" style="text-decoration:none;">
<div style="background-color:#B2F2BB; color:#1f2937; padding:10px 18px; border-radius:8px; width:190px; font-size:13px;">
<b>2</b><br>
DASHBOARD
</div>
</a>
</td>

<td align="center">
<a href="#3-database-schema--data-structure" style="text-decoration:none;">
<div style="background-color:#FFD6A5; color:#1f2937; padding:10px 18px; border-radius:8px; width:190px; font-size:13px;">
<b>3</b><br>
DATABASE
</div>
</a>
</td>

</tr>

<tr>

<td align="center">
<a href="#4-team-contribution" style="text-decoration:none;">
<div style="background-color:#FFADAD; color:#1f2937; padding:10px 18px; border-radius:8px; width:190px; font-size:13px;">
<b>4</b><br>
TEAM
</div>
</a>
</td>

<td align="center">
<a href="#5-project-folder-structure" style="text-decoration:none;">
<div style="background-color:#CDB4DB; color:#1f2937; padding:10px 18px; border-radius:8px; width:190px; font-size:13px;">
<b>5</b><br>
STRUCTURE
</div>
</a>
</td>

<td align="center">
<a href="#6-nama-kelompok" style="text-decoration:none;">
<div style="background-color:#90DBF4; color:#1f2937; padding:10px 18px; border-radius:8px; width:190px; font-size:13px;">
<b>6</b><br>
KELOMPOK
</div>
</a>
</td>

</tr>
</table>

---

# 1. Description About Dashboard

Game Platform Dashboard adalah aplikasi interaktif berbasis **R Shiny** yang dirancang untuk menganalisis dan memvisualisasikan data game dari berbagai aspek.

Dashboard ini terhubung dengan database **MariaDB** dan memanfaatkan:

- 📊 Visualisasi interaktif menggunakan **Plotly**
- 📋 Tabel dinamis menggunakan **DT**
- 🔄 Reactive programming pada Shiny
- 🗄️ Integrasi database menggunakan **DBI + RMariaDB**

Tujuan utama dashboard:

- Menampilkan performa game berdasarkan score dan review
- Menyediakan rekomendasi game berdasarkan genre dan age rating
- Menganalisis tren rilis game
- Mengidentifikasi pola distribusi review

---

# 2. Dashboard Section

Dashboard terdiri dari beberapa menu utama:

---

## 🔹 Home

Menampilkan:

- Total Game
- Total Review
- Banner Top Game (Video Preview / Image)
- Rekomendasi Game berdasarkan:
  - Age Rating
  - Genre

---

## 🔹 Search

Fitur pencarian dan filter interaktif berdasarkan:

- Genre
- Platform
- Age Rating
- Minimum Score

Fitur tambahan:

- Tabel interaktif
- Klik baris untuk membuka halaman game
- Filter dinamis berbasis query database

---

## 🔹 Overview

Berisi analisis statistik dan visualisasi:

- Genre paling populer berdasarkan review
- Distribusi score game
- Top 10 game berdasarkan score
- Top 10 game berdasarkan jumlah review
- Game dengan metascore tertinggi
- Genre dengan rata-rata score tertinggi
- Tren rilis game per tahun

---

## 🔹 About Team

Menampilkan:

- Profil anggota tim
- Peran dan tanggung jawab masing-masing

---

# 3. Database Schema & Data Structure

Dashboard menggunakan database relasional dengan tabel utama:

- `tbl_games`
- `tbl_reviews`
- `tbl_users`
- `tbl_genres`
- `tbl_platforms`
- `tbl_game_genres`
- `tbl_game_platforms`

Struktur relasi dan ERD dapat dilihat pada:

📄 [`doc/erd.pdf`](doc/erd.pdf)

---

# 4. Team Contribution

## 👩‍💻 Database Manager
**Fokus:** Database & Query

### Tanggung Jawab:
- Mendesain struktur database (tabel, relasi, primary–foreign key)
- Menyusun ERD
- Menyiapkan database
- Menulis dan menguji query SQL:
  - JOIN antar tabel
  - WHERE, GROUP BY
  - Agregasi (COUNT, SUM, AVG)
- Optimasi dasar query (index/view bila diperlukan)
- Menyediakan query SQL siap pakai untuk backend RShiny

### Batasan:
- Tidak mengerjakan UI
- Tidak menulis server logic Shiny

### Output Wajib:
- ERD
- Skema tabel
- Query SQL tervalidasi

---

## ⚙️ Backend Developer
**Fokus:** Logika Aplikasi RShiny (Server)

### Tanggung Jawab:
- Menghubungkan R dengan database menggunakan DBI dan driver terkait
- Menjalankan query SQL dari database
- Membuat fungsi backend untuk pengambilan dan pengolahan data
- Mengelola reaktivitas Shiny:
  - reactive()
  - observeEvent()
- Menyediakan output ke frontend:
  - renderPlot()
  - renderTable()
- Menangani error dan validasi input

### Batasan:
- Tidak mengatur layout UI
- Tidak menentukan desain visual

### Output Wajib:
- File server.R sebagai input dalam app.R
- Backend berjalan stabil dan efisien

---

## 🎨 Frontend Developer
**Fokus:** Tampilan & Interaksi Pengguna

### Tanggung Jawab:
- Mendesain struktur UI dashboard (Sidebar, navbar, tabPanel)
- Membuat komponen input:
  - selectInput()
  - dateRangeInput()
- Menyusun placeholder output:
  - plotOutput()
  - tableOutput()
- Mengatur tata letak dan alur interaksi pengguna
- Mengintegrasikan output server ke UI
- Menjaga konsistensi layout dan keterbacaan visual

### Batasan:
- Tidak mengakses database
- Tidak menulis logika data di server

### Output Wajib:
- File ui.R sebagai input dalam app.R
- Dashboard tampil rapi dan mudah digunakan

---

## 📊 Data Analyst
**Fokus:** Insight, Validasi, dan Evaluasi

### Tanggung Jawab:
- Menentukan KPI dan kebutuhan analitik dashboard
- Memvalidasi hasil dashboard dengan data database
- Melakukan pengujian dashboard (filter ekstrem, data kosong)
- Menyusun interpretasi hasil dan insight utama
- Menyusun dokumentasi dan laporan akhir

### Batasan:
- Tidak bertanggung jawab atas UI dan server utama

### Output Wajib:
- Daftar KPI dan insight
- Dokumentasi project

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
```

# 6. Nama Kelompok

---

<h2 align="center">Kelompok 1 — Victory Team</h2>

<br>

<table align="center" cellspacing="20">
<tr>

<td align="center">
<img src="Images/team1.jpg" width="140" style="border-radius:12px;"><br><br>
<b>Dwi Erzalianti</b><br>
<sub>M0501251010</sub><br>
<sub>Database Manager</sub>
</td>

<td align="center">
<img src="Images/team2.jpg" width="140" style="border-radius:12px;"><br><br>
<b>Inria Purwaningsih</b><br>
<sub>M0501251025</sub><br>
<sub>Database Manager</sub>
</td>

<td align="center">
<img src="Images/team3.jpg" width="140" style="border-radius:12px;"><br><br>
<b>Dinda A.R Kusuma</b><br>
<sub>M0501251046</sub><br>
<sub>Data Analyst</sub>
</td>

<td align="center">
<img src="Images/team4.jpg" width="140" style="border-radius:12px;"><br><br>
<b>Izzul Haq</b><br>
<sub>M0501251048</sub><br>
<sub>Backend Developer</sub>
</td>

</tr>
</table>

---

<div align="center">

## Academic Information

STA2562 – Pemrosesan Data Besar  
Magister Statistika dan Sains Data  
IPB University  
2026  

</div>
