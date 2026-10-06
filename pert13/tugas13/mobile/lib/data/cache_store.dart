import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class IsiCache {
  final String isi;
  final DateTime waktu;
  const IsiCache(this.isi, this.waktu);
}

/// Penyimpanan salinan terakhir respons GET dari server.
abstract class CacheStore {
  Future<void> simpan(String kunci, String isi);
  Future<IsiCache?> baca(String kunci);
  Future<void> hapusSemua();
}

/// Cache di SQLite (berkas terpisah dari database mode lokal).
class SqliteCacheStore implements CacheStore {
  Database? _db;

  Future<Database> get _database async {
    return _db ??= await openDatabase(
      p.join(await getDatabasesPath(), 'tabungku_cache.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE cache(
          kunci TEXT PRIMARY KEY,
          isi TEXT NOT NULL,
          waktu TEXT NOT NULL
        )
      '''),
    );
  }

  @override
  Future<void> simpan(String kunci, String isi) async {
    final db = await _database;
    await db.insert('cache', {
      'kunci': kunci,
      'isi': isi,
      'waktu': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<IsiCache?> baca(String kunci) async {
    final db = await _database;
    final rows = await db.query(
      'cache',
      where: 'kunci = ?',
      whereArgs: [kunci],
    );
    if (rows.isEmpty) return null;
    return IsiCache(
      rows.first['isi'] as String,
      DateTime.parse(rows.first['waktu'] as String),
    );
  }

  @override
  Future<void> hapusSemua() async {
    final db = await _database;
    await db.delete('cache');
  }
}

class MemoryCacheStore implements CacheStore {
  final data = <String, IsiCache>{};

  @override
  Future<void> simpan(String kunci, String isi) async =>
      data[kunci] = IsiCache(isi, DateTime.now());

  @override
  Future<IsiCache?> baca(String kunci) async => data[kunci];

  @override
  Future<void> hapusSemua() async => data.clear();
}

/// Dapat diganti di test: `cacheStore = MemoryCacheStore();`
CacheStore cacheStore = SqliteCacheStore();
