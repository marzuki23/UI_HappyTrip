<div align="center">
  <img src="assets/images/logo.png" alt="HappyTrip Logo" width="120" height="120">
  <h1 align="center">HappyTrip</h1>
  <p align="center">
    ✨ Rencanakan Perjalanan Impianmu dengan Cerdas ✨
  </p>
  <p align="center">
    Aplikasi smart travel planner berbasis Flutter dengan kecerdasan buatan,
    rekomendasi wisata personalized, dan itinerary generator otomatis.
  </p>
</div>

---

## Fitur Utama

<table>
  <tr>
    <td align="center" width="25%">
      <h3>🔐</h3>
      <b>Face Recognition Login</b>
      <p>Login aman dengan pengenalan wajah menggunakan MobileFaceNet + Google MLKit</p>
    </td>
    <td align="center" width="25%">
      <h3>🗺️</h3>
      <b>Trip Planner Cerdas</b>
      <p>Filter destinasi berdasarkan kategori wisata, lokasi, jenis kendaraan, & durasi perjalanan</p>
    </td>
    <td align="center" width="25%">
      <h3>🤖</h3>
      <b>Rekomendasi Personal</b>
      <p>Dapatkan rekomendasi wisata yang dipersonalisasi sesuai preferensi liburanmu</p>
    </td>
    <td align="center" width="25%">
      <h3>📋</h3>
      <b>Itinerary Generator</b>
      <p>Rencana perjalanan harian otomatis lengkap dengan estimasi biaya detail</p>
    </td>
  </tr>
  <tr>
    <td align="center">
      <h3>📊</h3>
      <b>Activity Log & Charts</b>
      <p>Riwayat perjalanan dengan grafik interaktif (bar chart, pie chart)</p>
    </td>
    <td align="center">
      <h3>☁️</h3>
      <b>Cloud Sync</b>
      <p>Sinkronisasi data perjalanan ke cloud — akses di mana saja</p>
    </td>
    <td align="center">
      <h3>💰</h3>
      <b>Estimasi Biaya</b>
      <p>Hitung otomatis biaya transportasi, tiket masuk, makan, & penginapan</p>
    </td>
    <td align="center">
      <h3>📱</h3>
      <b>Multi Platform</b>
      <p>Android, iOS, Web, Windows, Linux, macOS</p>
    </td>
  </tr>
</table>

---

## Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| [Flutter](https://flutter.dev) | Framework UI cross-platform |
| [GetX](https://pub.dev/packages/get) | State management, routing, dependency injection |
| [Google MLKit](https://pub.dev/packages/google_mlkit_face_detection) | Face detection |
| [TFLite](https://www.tensorflow.org/lite) | On-device face recognition (MobileFaceNet) |
| [MongoDB Atlas](https://www.mongodb.com/atlas) | Database destinasi wisata |
| [Neon DB](https://neon.tech) | Database log perjalanan (Postgres) |
| [fl_chart](https://pub.dev/packages/fl_chart) | Grafik interaktif |
| [GetStorage](https://pub.dev/packages/get_storage) | Local cache & offline support |
| [Apify](https://apify.com) | Web scraping data destinasi |

---

## Preview

| | | |
|---|---|---|
| **Splash & Login** | **Home & Trip Planner** | **Rekomendasi & Itinerary** |
| Face login, register, forgot password | Filter kategori, lokasi, kendaraan, durasi | Pilih destinasi, itinerary harian, estimasi biaya |

---

## Cara Install

### Prerequisites

- Flutter SDK (^3.11.5)
- Dart SDK (^3.11.5)
- Android Studio / Xcode (untuk build mobile)

### Langkah-langkah

```bash
# 1. Clone repository
git clone https://github.com/username/happytrip.git
cd happytrip

# 2. Install dependencies
flutter pub get

# 3. Konfigurasi environment
# Edit file .env dengan credential yang sesuai:
#   MONGO_URI=...
#   DB_NAME=happytrip
#   API_DESTINATIONS=...
#   APIFY_TOKEN=...

# 4. Jalankan aplikasi
flutter run
```

> **Catatan:** Model TFLite (`mobilefacenet.tflite`) sudah tersedia di `assets/ml/`. Pastikan koneksi internet aktif untuk pertama kali menjalankan agar data destinasi termuat dari MongoDB Atlas.

---

## Tersedia di Google Play Store

HappyTrip sudah tersedia dan dapat diunduh langsung dari Google Play Store. Silakan download sekarang untuk mulai merencanakan perjalanan impianmu.

[<img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" alt="Google Play Store" width="200">](https://play.google.com/store/apps/details?id=com.hn.happytrip)

---

## Struktur Proyek

```
happytrip/
├── android/                  # Konfigurasi Android
├── ios/                      # Konfigurasi iOS
├── lib/
│   ├── main.dart             # Entry point aplikasi
│   ├── app/
│   │   ├── modules/          # Modul fitur (GetX pattern)
│   │   │   ├── splash/       # Splash screen
│   │   │   ├── login/        # Login email/password
│   │   │   ├── register/     # Registrasi akun
│   │   │   ├── face_login/   # Face recognition login
│   │   │   ├── face_scan/    # Registrasi wajah
│   │   │   ├── home/         # Halaman utama + dashboard
│   │   │   ├── trip/         # Trip planner (filter)
│   │   │   ├── recommendation/ # Rekomendasi wisata
│   │   │   ├── itinerary/    # Itinerary generator
│   │   │   ├── activity_log/ # Log & grafik perjalanan
│   │   │   ├── profile/      # Profil pengguna
│   │   │   └── forgot_password/ # Lupa password
│   │   ├── models/           # Model data
│   │   ├── services/         # Service layer
│   │   ├── routes/           # Konfigurasi routing
│   │   └── widgets/          # Widget reusable
│   ├── backend/
│   │   └── scraper.py        # Web scraper Apify
│   └── assets/
│       ├── images/           # Gambar & ikon
│       └── ml/               # Model TFLite
├── test/                     # Unit test
└── pubspec.yaml              # Dependencies
```

---

## Arsitektur

Aplikasi menggunakan pola **GetX Pattern** dengan arsitektur modular:

- **View** — UI komponen (dipisah per modul)
- **Controller** — Logic & state management
- **Binding** — Dependency injection
- **Service** — Layer untuk API, database, & ML
- **Model** — Struktur data

Data mengalir: `View → Controller → Service → API/Database`

---

## Kontributor

- **Idris** — Developer & Designer
- **Briyan** — Developer & Designer

---

<div align="center">
  <p>Dibuat dengan ❤️ menggunakan Flutter</p>
  <p>
    <a href="https://flutter.dev">Flutter</a> •
    <a href="https://pub.dev/packages/get">GetX</a> •
    <a href="https://www.mongodb.com/atlas">MongoDB Atlas</a>
  </p>
</div>
