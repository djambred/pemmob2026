import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/pengeluaran.dart';

class DbHelper {
  static const namaDb = 'pengeluaran.db';
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), namaDb);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pengeluaran('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'nama TEXT NOT NULL, '
          'jumlah INTEGER NOT NULL, '
          'kategori TEXT NOT NULL, '
          'tanggal TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  static Future<int> tambah(Pengeluaran x) async {
    final db = await database;
    return db.insert('pengeluaran', x.toMap());
  }

  /// [kategori] null berarti semua kategori.
  static Future<List<Pengeluaran>> semua({String? kategori}) async {
    final db = await database;
    final rows = await db.query(
      'pengeluaran',
      where: kategori == null ? null : 'kategori = ?',
      whereArgs: kategori == null ? null : [kategori],
      orderBy: 'tanggal DESC, id DESC',
    );
    return rows.map(Pengeluaran.fromMap).toList();
  }

  /// Total dihitung di database dengan SUM; COALESCE agar hasil 0 bila kosong.
  static Future<int> total({String? kategori}) async {
    final db = await database;
    final hasil = await db.rawQuery(
      'SELECT COALESCE(SUM(jumlah), 0) AS total FROM pengeluaran'
      '${kategori == null ? '' : ' WHERE kategori = ?'}',
      kategori == null ? [] : [kategori],
    );
    return hasil.first['total'] as int;
  }

  static Future<int> ubah(Pengeluaran x) async {
    final db = await database;
    return db.update(
      'pengeluaran',
      x.toMap(),
      where: 'id = ?',
      whereArgs: [x.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('pengeluaran', where: 'id = ?', whereArgs: [id]);
  }
}
