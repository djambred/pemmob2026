import '../config/api_config.dart';
import 'kategori.dart';

enum Tipe { tanpa, pemasukan, pengeluaran }

class Kegiatan {
  final int? id;
  final String judul;
  final String tanggal; // format yyyy-MM-dd
  final bool selesai;
  final Tipe tipe;
  final int nominal;
  final int? kategoriId;

  /// Nama kategori untuk ditampilkan ('-' bila bukan pengeluaran).
  final String kategori;

  /// Path foto bukti di server, misalnya 'uploads/3f2a.jpg' (null = tidak ada).
  final String? bukti;

  const Kegiatan({
    this.id,
    required this.judul,
    required this.tanggal,
    this.selesai = false,
    this.tipe = Tipe.tanpa,
    this.nominal = 0,
    this.kategoriId,
    this.kategori = '-',
    this.bukti,
  });

  /// URL lengkap foto bukti. Disusun di klien karena alamat API dapat
  /// berbeda (emulator 10.0.2.2, HP fisik memakai IP laptop).
  String? get buktiUrl => bukti == null ? null : '${apiUrl.value}/$bukti';

  Kegiatan salin({int? id, bool? selesai}) {
    return Kegiatan(
      id: id ?? this.id,
      judul: judul,
      tanggal: tanggal,
      selesai: selesai ?? this.selesai,
      tipe: tipe,
      nominal: nominal,
      kategoriId: kategoriId,
      kategori: kategori,
      bukti: bukti,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'judul': judul,
    'tanggal': tanggal,
    'selesai': selesai ? 1 : 0,
    'tipe': tipe.name,
    'nominal': nominal,
    'kategori': kategori,
  };

  factory Kegiatan.fromMap(Map<String, Object?> m) => Kegiatan(
    id: m['id'] as int,
    judul: m['judul'] as String,
    tanggal: m['tanggal'] as String,
    selesai: (m['selesai'] as int) == 1,
    tipe: Tipe.values.byName(m['tipe'] as String),
    nominal: m['nominal'] as int,
    kategoriId: _idDariNama(m['kategori'] as String),
    kategori: m['kategori'] as String,
  );

  /// SQLite (mode lokal) menyimpan nama kategori; id dicari dari daftar bawaan.
  static int? _idDariNama(String nama) {
    for (final k in kategoriBawaan) {
      if (k.nama == nama) return k.id;
    }
    return null;
  }

  /// JSON untuk dikirim ke API. Berbeda dengan [toMap]: `selesai` berupa
  /// boolean dan `id` tidak dikirim (id ada di URL).
  Map<String, Object?> toJson() => {
    'judul': judul,
    'tanggal': tanggal,
    'selesai': selesai,
    'tipe': tipe.name,
    'nominal': nominal,
    'kategori_id': kategoriId,
  };

  factory Kegiatan.fromJson(Map<String, dynamic> j) => Kegiatan(
    id: j['id'] as int,
    judul: j['judul'] as String,
    tanggal: j['tanggal'] as String,
    selesai: j['selesai'] as bool,
    tipe: Tipe.values.byName(j['tipe'] as String),
    nominal: j['nominal'] as int,
    kategoriId: j['kategori_id'] as int?,
    kategori: j['kategori'] as String,
    bukti: j['bukti'] as String?,
  );
}

/// Ringkasan keuangan dan kegiatan untuk satu hari.
class Ringkasan {
  final int jumlahKegiatan;
  final int selesai;
  final int pemasukan;
  final int pengeluaran;

  const Ringkasan({
    required this.jumlahKegiatan,
    required this.selesai,
    required this.pemasukan,
    required this.pengeluaran,
  });

  int get tabungan => pemasukan - pengeluaran;

  factory Ringkasan.fromJson(Map<String, dynamic> j) => Ringkasan(
    jumlahKegiatan: j['jumlah_kegiatan'] as int,
    selesai: j['selesai'] as int,
    pemasukan: j['pemasukan'] as int,
    pengeluaran: j['pengeluaran'] as int,
  );
}

/// Hasil GET /laporan/harian.
class LaporanHarian {
  final Ringkasan ringkasan;
  final Map<String, int> perKategori;

  const LaporanHarian(this.ringkasan, this.perKategori);

  factory LaporanHarian.fromJson(Map<String, dynamic> j) =>
      LaporanHarian(Ringkasan.fromJson(j), {
        for (final e in j['per_kategori'] as List<dynamic>)
          e['kategori'] as String: e['total'] as int,
      });
}
