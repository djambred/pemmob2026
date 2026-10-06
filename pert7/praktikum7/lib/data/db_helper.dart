import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/kegiatan.dart';

/// Naik setiap kali data berubah. Halaman yang menampilkan data
/// mendengarkan notifier ini lalu memuat ulang datanya.
final versiData = ValueNotifier<int>(0);

class DbHelper {
  static Database? _db;

  static Future<Database> get _database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'tabungku.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kegiatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            selesai INTEGER NOT NULL DEFAULT 0,
            tipe TEXT NOT NULL DEFAULT 'tanpa',
            nominal INTEGER NOT NULL DEFAULT 0,
            kategori TEXT NOT NULL DEFAULT '-'
          )
        ''');
      },
    );
    return _db!;
  }

  static void _berubah() => versiData.value++;

  static Future<int> tambah(Kegiatan k) async {
    final db = await _database;
    final id = await db.insert('kegiatan', k.toMap());
    _berubah();
    return id;
  }

  static Future<int> ubah(Kegiatan k) async {
    final db = await _database;
    final n = await db.update(
      'kegiatan',
      k.toMap(),
      where: 'id = ?',
      whereArgs: [k.id],
    );
    _berubah();
    return n;
  }

  static Future<int> hapus(int id) async {
    final db = await _database;
    final n = await db.delete('kegiatan', where: 'id = ?', whereArgs: [id]);
    _berubah();
    return n;
  }

  /// Semua kegiatan pada satu tanggal (yang belum selesai di atas).
  static Future<List<Kegiatan>> pada(String tanggal) async {
    final db = await _database;
    final rows = await db.query(
      'kegiatan',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'selesai ASC, id DESC',
    );
    return rows.map(Kegiatan.fromMap).toList();
  }

  /// Laporan harian: jumlah kegiatan, pemasukan, pengeluaran.
  static Future<Ringkasan> ringkasan(String tanggal) async {
    final db = await _database;
    final hasil = await db.rawQuery('''
      SELECT COUNT(*) AS jumlah,
             COALESCE(SUM(selesai), 0) AS selesai,
             COALESCE(SUM(CASE WHEN tipe = 'pemasukan'
                               THEN nominal END), 0) AS masuk,
             COALESCE(SUM(CASE WHEN tipe = 'pengeluaran'
                               THEN nominal END), 0) AS keluar
      FROM kegiatan
      WHERE tanggal = ?
    ''', [tanggal]);
    final baris = hasil.first;
    return Ringkasan(
      jumlahKegiatan: baris['jumlah'] as int,
      selesai: baris['selesai'] as int,
      pemasukan: baris['masuk'] as int,
      pengeluaran: baris['keluar'] as int,
    );
  }

  /// Total pengeluaran per kategori pada satu tanggal.
  static Future<Map<String, int>> pengeluaranPerKategori(
    String tanggal,
  ) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT kategori, SUM(nominal) AS total
      FROM kegiatan
      WHERE tanggal = ? AND tipe = 'pengeluaran'
      GROUP BY kategori
      ORDER BY total DESC
    ''', [tanggal]);
    return {
      for (final r in rows) r['kategori'] as String: r['total'] as int,
    };
  }
}
