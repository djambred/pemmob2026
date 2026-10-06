/// Kategori pengeluaran (GET /kategori). Daftarnya dikelola admin di
/// dashboard Filament, bukan lagi ditulis tetap di kode aplikasi.
class Kategori {
  final int id;
  final String nama;

  const Kategori(this.id, this.nama);

  factory Kategori.fromJson(Map<String, dynamic> j) =>
      Kategori(j['id'] as int, j['nama'] as String);
}

/// Dipakai mode lokal (SQLite). Id sama dengan data awal migrasi 0003.
const kategoriBawaan = [
  Kategori(1, 'Makan'),
  Kategori(2, 'Transport'),
  Kategori(3, 'Belajar'),
  Kategori(4, 'Hiburan'),
  Kategori(5, 'Lainnya'),
];
