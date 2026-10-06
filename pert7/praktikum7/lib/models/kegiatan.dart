enum Tipe { tanpa, pemasukan, pengeluaran }

const kategoriPengeluaran = [
  'Makan',
  'Transport',
  'Belajar',
  'Hiburan',
  'Lainnya',
];

class Kegiatan {
  final int? id;
  final String judul;
  final String tanggal; // format yyyy-MM-dd
  final bool selesai;
  final Tipe tipe;
  final int nominal;
  final String kategori;

  const Kegiatan({
    this.id,
    required this.judul,
    required this.tanggal,
    this.selesai = false,
    this.tipe = Tipe.tanpa,
    this.nominal = 0,
    this.kategori = '-',
  });

  Kegiatan salin({bool? selesai}) {
    return Kegiatan(
      id: id,
      judul: judul,
      tanggal: tanggal,
      selesai: selesai ?? this.selesai,
      tipe: tipe,
      nominal: nominal,
      kategori: kategori,
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
        kategori: m['kategori'] as String,
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
}
