# Tugas Pertemuan 9 — Endpoint Laporan

API CRUD kegiatan (SQLAlchemy 2, Alembic, Pydantic) ditambah endpoint laporan harian dan rentang yang dihitung di SQL, serta pembungkusnya di Flutter.

- **Kode:** [`../tugas9/`](../tugas9/) — `backend/app/routers/laporan.py`, `mobile/lib/services/laporan_api.dart`
- **Modul:** [Pertemuan 9](../modul/modul-praktikum-flutter-pertemuan-9.pdf), bagian 6 (Tugas)

## Tangkapan Layar

Swagger UI (`/docs`). Gambar diambil dari API akhir pertemuan 14, sedangkan pada pertemuan 9 baru tersedia kelompok `health`, `kegiatan`, dan `laporan`.

<img src="img/01-swagger.png" width="640" alt="Swagger UI">

## Pemenuhan Ketentuan Tugas

| Ketentuan | Implementasi |
|---|---|
| `GET /laporan/harian` dihitung di SQL | Satu `SELECT ... COUNT, SUM(CASE WHEN ...), COALESCE ... GROUP BY tanggal` + query `GROUP BY kategori` |
| `GET /laporan/rentang` termasuk hari kosong | Satu query `GROUP BY tanggal`; tanggal tanpa data diisi 0 di Python |
| Rentang terbalik atau > 31 hari ditolak | 400 dengan pesan Bahasa Indonesia |
| Hasil sama dengan skenario modul 7 | Terverifikasi: 4 kegiatan, 2 selesai, masuk 50.000, keluar 25.000 (Makan 15.000, Transport 10.000), tabungan 25.000 |
| `Ringkasan.fromJson`, `LaporanHarian`, `LaporanApi` | `mobile/lib/models/kegiatan.dart`, `mobile/lib/services/laporan_api.dart` |
| Unit test | `mobile/test/laporan_api_test.dart` (harian, rentang, galat 400) |

## Cara Menjalankan

```bash
cd pert9/tugas9 && cp .env.example .env && docker compose up -d --build
# migrasi Alembic 0001 berjalan otomatis; buka http://localhost:8000/docs
docker compose exec api alembic current   # 0001 (head)
```

## Hasil Verifikasi

- Seluruh skenario uji bagian F modul dicoba dengan `curl` dan sesuai (201/422/204/404, header `X-Total-Count`).
- `alembic check`: tidak ada perbedaan model dan database.
- `flutter test`: 19 test lulus.
