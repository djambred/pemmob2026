# pemrograman-mobile-2026

Materi praktikum mata kuliah **Pemrograman Mobile** dengan Flutter: modul praktikum, kode praktikum, contoh penyelesaian tugas, dan dokumentasinya.

Diuji dengan **Flutter 3.47.5** (channel stable). Pertemuan 8–14 juga memakai **Docker** (Compose), **FastAPI** + **MySQL 8.4**, dan **Laravel 13 + Filament 5**, yang semuanya berjalan di dalam container.

## Daftar Pertemuan

| Pert. | Topik | Modul | Praktikum | Tugas | Dokumentasi tugas |
|:---:|---|---|---|---|---|
| 1 | Pengenalan Flutter, instalasi, dan aplikasi pertama | [PDF](pert1/modul/modul-praktikum-flutter-pertemuan-1.pdf) | [praktikum1](pert1/praktikum1) | [Kartu Perkenalan](pert1/tugas1) | [docs](pert1/docs-tugas/README.md) |
| 2 | Layout, ListView, dan navigasi antarhalaman | [PDF](pert2/modul/modul-praktikum-flutter-pertemuan-2.pdf) | [praktikum2](pert2/praktikum2) | [Daftar Kontak](pert2/tugas2) | [docs](pert2/docs-tugas/README.md) |
| 3 | Form input dan state management (Provider) | [PDF](pert3/modul/modul-praktikum-flutter-pertemuan-3.pdf) | [praktikum3](pert3/praktikum3) | [Daftar Belanja](pert3/tugas3) | [docs](pert3/docs-tugas/README.md) |
| 4 | Mengambil data dari REST API (http, async, FutureBuilder) | [PDF](pert4/modul/modul-praktikum-flutter-pertemuan-4.pdf) | [praktikum4](pert4/praktikum4) | [Daftar Postingan](pert4/tugas4) | [docs](pert4/docs-tugas/README.md) |
| 5 | Penyimpanan lokal (SharedPreferences dan SQLite) | [PDF](pert5/modul/modul-praktikum-flutter-pertemuan-5.pdf) | [praktikum5](pert5/praktikum5) | [Pencatat Pengeluaran](pert5/tugas5) | [docs](pert5/docs-tugas/README.md) |
| 6 | Tema, routing dan navigasi, serta animasi | [PDF](pert6/modul/modul-praktikum-flutter-pertemuan-6.pdf) | [praktikum6](pert6/praktikum6) | [Galeri Wisata](pert6/tugas6) | [docs](pert6/docs-tugas/README.md) |
| 7 | Mini proyek terpadu: TabungKu (to-do list + keuangan) | [PDF](pert7/modul/modul-praktikum-flutter-pertemuan-7.pdf) | [praktikum7](pert7/praktikum7) (contoh solusi) | Mini proyek | [docs](pert7/docs/README.md) |
| 8 | Docker Compose, MySQL, dan kerangka FastAPI | [PDF](pert8/modul/modul-praktikum-flutter-pertemuan-8.pdf) | [praktikum8](pert8/praktikum8) | [Status Server + DB](pert8/tugas8) | [docs](pert8/docs-tugas/README.md) |
| 9 | REST API CRUD: SQLAlchemy, Alembic, Pydantic | [PDF](pert9/modul/modul-praktikum-flutter-pertemuan-9.pdf) | [praktikum9](pert9/praktikum9) | [Endpoint Laporan](pert9/tugas9) | [docs](pert9/docs-tugas/README.md) |
| 10 | Autentikasi JWT dan data per pengguna | [PDF](pert10/modul/modul-praktikum-flutter-pertemuan-10.pdf) | [praktikum10](pert10/praktikum10) | [Refresh Token](pert10/tugas10) | [docs](pert10/docs-tugas/README.md) |
| 11 | Integrasi Flutter dengan API (*repository pattern*) | [PDF](pert11/modul/modul-praktikum-flutter-pertemuan-11.pdf) | [praktikum11](pert11/praktikum11) | [Target di Server + Offline](pert11/tugas11) | [docs](pert11/docs-tugas/README.md) |
| 12 | Dashboard admin Laravel + Filament | [PDF](pert12/modul/modul-praktikum-flutter-pertemuan-12.pdf) | [praktikum12](pert12/praktikum12) | [Widget Dashboard](pert12/tugas12) | [docs](pert12/docs-tugas/README.md) |
| 13 | Upload foto bukti struk dan pytest | [PDF](pert13/modul/modul-praktikum-flutter-pertemuan-13.pdf) | [praktikum13](pert13/praktikum13) | [Laporan Bulanan + CSV](pert13/tugas13) | [docs](pert13/docs-tugas/README.md) |
| 14 | *Hardening*, deploy dengan Nginx, proyek akhir | [PDF](pert14/modul/modul-praktikum-flutter-pertemuan-14.pdf) | [praktikum14](pert14/praktikum14) | [Contoh: Pengumuman](pert14/tugas14) | [docs](pert14/docs-tugas/README.md) |

Pertemuan 8–14 mengembangkan TabungKu dari pertemuan 7 menjadi **TabungKu Cloud**: aplikasi Flutter, API FastAPI, dan dashboard Filament yang berbagi satu database MySQL. Snapshot disusun bertingkat (`praktikum8` → `tugas8` → `praktikum9` → … → `tugas14`), sehingga setiap folder dapat dijalankan sendiri dan mahasiswa yang tertinggal dapat melanjutkan dari snapshot sebelumnya.

## Struktur Repositori

```
pemrograman-mobile-2026/
├── modul-src/             # sumber modul (Markdown) + generator PDF
├── pert1/
│   ├── modul/             # modul praktikum (PDF)
│   ├── praktikum1/        # kode praktikum sesuai langkah modul + latihan mandiri
│   ├── tugas1/            # contoh penyelesaian tugas
│   └── docs-tugas/        # dokumentasi tugas + tangkapan layar
├── pert2/ … pert7/          # struktur sama dengan pert1
├── pert8/ … pert14/         # TabungKu Cloud
│   ├── modul/
│   ├── praktikumN/
│   │   ├── docker-compose.yml   # mysql, api, admin (mulai 12), adminer
│   │   ├── .env.example
│   │   ├── backend/             # FastAPI + Alembic (+ tests/ mulai 13)
│   │   ├── admin/               # Laravel + Filament (mulai 12)
│   │   ├── mobile/              # Flutter (lib/, test/, izin Android/iOS)
│   │   └── nginx/, scripts/, docker-compose.prod.yml   (pertemuan 14)
│   ├── tugasN/              # contoh penyelesaian tugas, struktur sama
│   └── docs-tugas/
└── .gitignore
```

## Menjalankan Proyek

Setiap folder `praktikumN` dan `tugasN` adalah proyek Flutter yang berdiri sendiri.

```bash
cd pert5/tugas5
flutter pub get
flutter run          # pilih emulator/perangkat
flutter test         # menjalankan pengujian
flutter analyze      # memeriksa kode
```

Catatan per pertemuan:

| Pertemuan | Paket | Catatan |
|---|---|---|
| 3 | `provider` | – |
| 4 | `http` | Butuh internet (API [JSONPlaceholder](https://jsonplaceholder.typicode.com)); izin INTERNET sudah ditambahkan |
| 5, 7 | `sqflite`, `path`, `shared_preferences` | `sqflite` tidak mendukung web; gunakan Android/iOS/macOS. Pengujian database memakai `sqflite_common_ffi` |
| 6 | `shared_preferences` | – |

### Pertemuan 8–14 (TabungKu Cloud)

```bash
cd pert12/tugas12                 # snapshot mana pun
cp .env.example .env
docker compose up -d --build      # MySQL, API :8000, admin :8080 (mulai 12), Adminer :8081
docker compose exec api python -m scripts.seed_demo   # data contoh (mulai 12)

cd mobile
flutter create . --platforms android,ios   # sekali: membuat folder platform yang tidak di-commit
flutter pub get
flutter run                        # emulator Android -> http://10.0.2.2:8000
flutter run --dart-define=API_URL=http://192.168.1.10:8000   # HP fisik
```

| Layanan | Alamat | Akun bawaan |
|---|---|---|
| API + Swagger | http://localhost:8000/docs | daftar dari aplikasi, atau akun `seed_demo` (password `rahasia123`) |
| Dashboard Filament | http://localhost:8080/admin | `admin@tabungku.test` / `admin12345` (dari `.env`) |
| Adminer | http://localhost:8081 | server `mysql`, user/password dari `.env` |

Semua snapshot memakai nama proyek Compose `tabungku`, sehingga volume database dipakai bersama dan migrasi Alembic berjalan bertingkat. Untuk kembali ke snapshot yang lebih lama, jalankan `docker compose down -v` (menghapus data). Pengujian: `docker compose exec api pytest` (mulai 13) dan `docker compose exec admin php artisan test` (mulai 12).

## Mengubah Modul

Modul PDF dibangun dari berkas Markdown di [`modul-src/`](modul-src). Untuk mengubah isi modul:

1. Edit `modul-src/modul-N.md`.
2. Bangun ulang PDF (butuh Python 3 dan `reportlab`):

   ```bash
   pip install reportlab
   python3 modul-src/build_modul.py      # semua modul
   python3 modul-src/build_modul.py 2 5  # modul tertentu saja
   ```

Hasilnya ditulis ke `pertN/modul/modul-praktikum-flutter-pertemuan-N.pdf`. Format sumber (judul, heading, tabel, blok kode, kotak *Checkpoint*) dijelaskan di bagian atas [`build_modul.py`](modul-src/build_modul.py). Generator memakai font Arial dan Courier New dari macOS; bila tidak tersedia, generator otomatis memakai Helvetica dan Courier.

## Status Verifikasi

**Pertemuan 8–14:**

- Ke-14 snapshot: `flutter analyze` tanpa masalah dan `flutter test` lulus (9 sampai 48 test); `ruff check` bersih; semua `docker-compose*.yml` valid.
- Setiap snapshot dijalankan dengan `docker compose up` dan diuji dengan `curl` atau Swagger. Migrasi Alembic 0001–0005 diuji naik dan turun.
- pytest (di container bersih): `praktikum13` 22, `tugas13` 25 (cakupan 96%), `praktikum14` 28, `tugas14` 30 test lulus. Feature test Filament: 4 sampai 9 test lulus per snapshot.
- APK debug `praktikum10` (secure storage) dan `praktikum13` (image_picker) berhasil di-build.
- `tugas14`: uji *end-to-end* di simulator iPhone terhadap Docker lulus; compose produksi diuji dengan daftar periksa keamanan modul 14 dan login Filament lewat Nginx memakai Chrome headless.
- Belum diuji di emulator Android maupun HP fisik (hanya simulator iOS). Uji koneksi HP fisik ke IP laptop perlu dicoba di jaringan kampus.

**Pertemuan 1–7:**

- Praktikum 1–7 dan tugas 1–6 lolos `flutter analyze` tanpa masalah.
- Semua test lulus: praktikum 1, 2, 3, dan 7 serta tugas 1–6. Praktikum 4–6 belum memiliki test.
- Proyek yang memakai plugin (praktikum 4–7, tugas 4–6) berhasil di-build menjadi APK debug.
- Aplikasi belum dijalankan manual di emulator/perangkat. Checkpoint interaktif pada modul, misalnya data tetap ada setelah restart, perlu dicoba langsung.
