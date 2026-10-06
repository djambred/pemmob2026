import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:tabungku/data/db_helper.dart';
import 'package:tabungku/models/kegiatan.dart';

// Menguji logika database TabungKu dengan skenario uji pada modul Pertemuan 7.
void main() {
  const hariIni = '2026-10-06';
  const kemarin = '2026-10-05';

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.deleteDatabase(
      p.join(await getDatabasesPath(), 'tabungku.db'),
    );
  });

  test('Skenario 1-3: tidak, pemasukan, pengeluaran', () async {
    await DbHelper.tambah(const Kegiatan(judul: 'Belajar', tanggal: hariIni));
    var r = await DbHelper.ringkasan(hariIni);
    expect(r.jumlahKegiatan, 1);
    expect(r.pemasukan, 0);
    expect(r.pengeluaran, 0);

    await DbHelper.tambah(
      const Kegiatan(
        judul: 'Freelance',
        tanggal: hariIni,
        tipe: Tipe.pemasukan,
        nominal: 50000,
      ),
    );
    r = await DbHelper.ringkasan(hariIni);
    expect(r.pemasukan, 50000);
    expect(r.tabungan, 50000);

    await DbHelper.tambah(
      const Kegiatan(
        judul: 'Makan siang',
        tanggal: hariIni,
        tipe: Tipe.pengeluaran,
        nominal: 15000,
        kategori: 'Makan',
      ),
    );
    r = await DbHelper.ringkasan(hariIni);
    expect(r.pengeluaran, 15000);
    expect(r.tabungan, 35000);
    expect(await DbHelper.pengeluaranPerKategori(hariIni), {'Makan': 15000});
  });

  test('Skenario 5: centang selesai', () async {
    final daftar = await DbHelper.pada(hariIni);
    await DbHelper.ubah(daftar[0].salin(selesai: true));
    await DbHelper.ubah(daftar[1].salin(selesai: true));
    final r = await DbHelper.ringkasan(hariIni);
    expect(r.selesai, 2);
    expect(r.jumlahKegiatan, 3);
  });

  test('Skenario 6: ubah nominal', () async {
    final makan = (await DbHelper.pada(hariIni))
        .firstWhere((k) => k.judul == 'Makan siang');
    await DbHelper.ubah(
      Kegiatan(
        id: makan.id,
        judul: makan.judul,
        tanggal: makan.tanggal,
        selesai: makan.selesai,
        tipe: makan.tipe,
        nominal: 20000,
        kategori: makan.kategori,
      ),
    );
    expect((await DbHelper.ringkasan(hariIni)).pengeluaran, 20000);
  });

  test('Skenario 7: hapus', () async {
    final belajar = (await DbHelper.pada(hariIni))
        .firstWhere((k) => k.judul == 'Belajar');
    await DbHelper.hapus(belajar.id!);
    expect((await DbHelper.ringkasan(hariIni)).jumlahKegiatan, 2);
  });

  test('Skenario 8: tanggal kemarin terpisah', () async {
    await DbHelper.tambah(
      const Kegiatan(
        judul: 'Angkot',
        tanggal: kemarin,
        tipe: Tipe.pengeluaran,
        nominal: 10000,
        kategori: 'Transport',
      ),
    );
    expect(
      (await DbHelper.pada(hariIni)).any((k) => k.judul == 'Angkot'),
      isFalse,
    );
    final r = await DbHelper.ringkasan(kemarin);
    expect(r.jumlahKegiatan, 1);
    expect(r.pengeluaran, 10000);
  });

  test('Skenario 10: tabungan negatif', () async {
    final r = await DbHelper.ringkasan(kemarin);
    expect(r.tabungan, lessThan(0));
  });

  test('Tanggal kosong menghasilkan 0, bukan null (COALESCE)', () async {
    final r = await DbHelper.ringkasan('2000-01-01');
    expect(r.jumlahKegiatan, 0);
    expect(r.pemasukan, 0);
    expect(r.tabungan, 0);
  });
}
