# pemrograman-mobile-2026

Materi praktikum mata kuliah **Pemrograman Mobile** dengan Flutter: modul praktikum, kode praktikum, contoh penyelesaian tugas, dan dokumentasinya.

Diuji dengan **Flutter 3.47.5** (channel stable).

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
| 8–14 | Belum tersedia | – | kerangka proyek | kerangka proyek | – |

Folder praktikum dan tugas pertemuan 8–14 masih berisi proyek bawaan `flutter create`.

## Struktur Repositori

```
pemrograman-mobile-2026/
├── modul-src/             # sumber modul (Markdown) + generator PDF
├── pert1/
│   ├── modul/             # modul praktikum (PDF)
│   ├── praktikum1/        # kode praktikum sesuai langkah modul + latihan mandiri
│   ├── tugas1/            # contoh penyelesaian tugas
│   └── docs-tugas/        # dokumentasi tugas + tangkapan layar
├── pert2/ … pert14/
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

- Praktikum 1–7 dan tugas 1–6 lolos `flutter analyze` tanpa masalah.
- Semua test lulus: praktikum 1, 2, 3, dan 7 serta tugas 1–6. Praktikum 4–6 belum memiliki test.
- Proyek yang memakai plugin (praktikum 4–7, tugas 4–6) berhasil di-build menjadi APK debug.
- Aplikasi belum dijalankan manual di emulator/perangkat. Checkpoint interaktif pada modul, misalnya data tetap ada setelah restart, perlu dicoba langsung.
