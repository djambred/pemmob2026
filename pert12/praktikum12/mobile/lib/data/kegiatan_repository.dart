import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/kategori.dart';
import '../models/kegiatan.dart';
import '../services/kategori_api.dart';
import '../services/kegiatan_api.dart';
import '../services/laporan_api.dart';
import '../utils/format.dart';
import 'db_helper.dart';

/// Naik setiap kali data berubah. Halaman yang menampilkan data
/// mendengarkan notifier ini lalu memuat ulang datanya.
final versiData = ValueNotifier<int>(0);

/// Kontrak sumber data kegiatan. Halaman hanya mengenal kelas abstrak ini,
/// sehingga sumber data (SQLite atau API) dapat ditukar tanpa mengubah UI.
abstract class KegiatanRepository {
  Future<List<Kategori>> daftarKategori();
  Future<List<Kegiatan>> pada(String tanggal);
  Future<Ringkasan> ringkasan(String tanggal);
  Future<LaporanHarian> laporanHarian(String tanggal);
  Future<List<MapEntry<DateTime, Ringkasan>>> rentang(
    DateTime mulai,
    DateTime sampai,
  );

  Future<void> tambah(Kegiatan k);
  Future<void> ubah(Kegiatan k);
  Future<void> setSelesai(Kegiatan k, bool selesai);
  Future<void> hapus(int id);
}

/// Repository yang sedang dipakai aplikasi. Test dapat menggantinya
/// dengan repository palsu.
KegiatanRepository repo = modeData == 'lokal'
    ? SqliteKegiatanRepository()
    : ApiKegiatanRepository();

/// Data di server (FastAPI), milik pengguna yang sedang login.
class ApiKegiatanRepository implements KegiatanRepository {
  final KegiatanApi _kegiatan;
  final LaporanApi _laporan;
  final KategoriApi _kategori;

  ApiKegiatanRepository({
    KegiatanApi? kegiatan,
    LaporanApi? laporan,
    KategoriApi? kategori,
  }) : _kegiatan = kegiatan ?? KegiatanApi(),
       _laporan = laporan ?? LaporanApi(),
       _kategori = kategori ?? KategoriApi();

  @override
  Future<List<Kategori>> daftarKategori() => _kategori.daftar();

  @override
  Future<List<Kegiatan>> pada(String tanggal) =>
      _kegiatan.daftar(tanggal: tanggal);

  @override
  Future<Ringkasan> ringkasan(String tanggal) async =>
      (await _laporan.harian(tanggal)).ringkasan;

  @override
  Future<LaporanHarian> laporanHarian(String tanggal) =>
      _laporan.harian(tanggal);

  /// Satu request untuk seluruh rentang, bukan satu request per hari.
  @override
  Future<List<MapEntry<DateTime, Ringkasan>>> rentang(
    DateTime mulai,
    DateTime sampai,
  ) => _laporan.rentang(mulai, sampai);

  @override
  Future<void> tambah(Kegiatan k) async {
    await _kegiatan.tambah(k);
    versiData.value++;
  }

  @override
  Future<void> ubah(Kegiatan k) async {
    await _kegiatan.ubah(k);
    versiData.value++;
  }

  @override
  Future<void> setSelesai(Kegiatan k, bool selesai) async {
    await _kegiatan.setSelesai(k.id!, selesai);
    versiData.value++;
  }

  @override
  Future<void> hapus(int id) async {
    await _kegiatan.hapus(id);
    versiData.value++;
  }
}

/// Data di HP (SQLite) seperti pertemuan 7.
class SqliteKegiatanRepository implements KegiatanRepository {
  @override
  Future<List<Kategori>> daftarKategori() async => kategoriBawaan;

  @override
  Future<List<Kegiatan>> pada(String tanggal) => DbHelper.pada(tanggal);

  @override
  Future<Ringkasan> ringkasan(String tanggal) => DbHelper.ringkasan(tanggal);

  @override
  Future<LaporanHarian> laporanHarian(String tanggal) async => LaporanHarian(
    await DbHelper.ringkasan(tanggal),
    await DbHelper.pengeluaranPerKategori(tanggal),
  );

  @override
  Future<List<MapEntry<DateTime, Ringkasan>>> rentang(
    DateTime mulai,
    DateTime sampai,
  ) async {
    final hasil = <MapEntry<DateTime, Ringkasan>>[];
    for (
      var d = mulai;
      !d.isAfter(sampai);
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      hasil.add(MapEntry(d, await DbHelper.ringkasan(fmtTanggal(d))));
    }
    return hasil;
  }

  @override
  Future<void> tambah(Kegiatan k) async {
    await DbHelper.tambah(k);
    versiData.value++;
  }

  @override
  Future<void> ubah(Kegiatan k) async {
    await DbHelper.ubah(k);
    versiData.value++;
  }

  @override
  Future<void> setSelesai(Kegiatan k, bool selesai) =>
      ubah(k.salin(selesai: selesai));

  @override
  Future<void> hapus(int id) async {
    await DbHelper.hapus(id);
    versiData.value++;
  }
}
