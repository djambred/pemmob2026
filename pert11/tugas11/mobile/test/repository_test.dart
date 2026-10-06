import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tabungku/config/api_config.dart';
import 'package:tabungku/data/kegiatan_repository.dart';
import 'package:tabungku/models/kegiatan.dart';
import 'package:tabungku/pages/beranda_page.dart';
import 'package:tabungku/services/kegiatan_api.dart';
import 'package:tabungku/services/laporan_api.dart';
import 'package:tabungku/widgets/kegiatan_tile.dart';

/// Repository palsu: UI dapat diuji tanpa server maupun SQLite.
class FakeRepository implements KegiatanRepository {
  List<Kegiatan> daftar = [];
  Object? galat;
  int jumlahPanggil = 0;

  @override
  Future<List<Kegiatan>> pada(String tanggal) async {
    jumlahPanggil++;
    if (galat != null) throw galat!;
    return daftar;
  }

  @override
  Future<Ringkasan> ringkasan(String tanggal) async {
    if (galat != null) throw galat!;
    return Ringkasan(
      jumlahKegiatan: daftar.length,
      selesai: daftar.where((k) => k.selesai).length,
      pemasukan: 0,
      pengeluaran: daftar.fold(0, (s, k) => s + k.nominal),
    );
  }

  @override
  Future<LaporanHarian> laporanHarian(String tanggal) async =>
      LaporanHarian(await ringkasan(tanggal), const {});

  @override
  Future<List<MapEntry<DateTime, Ringkasan>>> rentang(
    DateTime mulai,
    DateTime sampai,
  ) async => [];

  @override
  Future<void> tambah(Kegiatan k) async => versiData.value++;

  @override
  Future<void> ubah(Kegiatan k) async => versiData.value++;

  @override
  Future<void> setSelesai(Kegiatan k, bool selesai) async => versiData.value++;

  @override
  Future<void> hapus(int id) async => versiData.value++;
}

Widget _app() => const MaterialApp(home: Scaffold(body: BerandaPage()));

void main() {
  group('BerandaPage dengan FakeRepository', () {
    late FakeRepository fake;

    setUp(() {
      fake = FakeRepository();
      repo = fake;
    });

    testWidgets('menampilkan daftar kegiatan dari repository', (tester) async {
      fake.daftar = [
        const Kegiatan(
          id: 1,
          judul: 'Makan siang',
          tanggal: '2026-10-06',
          tipe: Tipe.pengeluaran,
          nominal: 15000,
          kategori: 'Makan',
        ),
      ];
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.text('Makan siang'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(KegiatanTile),
          matching: find.text('-Rp 15.000'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('galat -> tombol Coba lagi -> data tampil', (tester) async {
      fake.galat = Exception('server mati');
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.text('Coba lagi'), findsOneWidget);

      fake.galat = null;
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Belum ada kegiatan'), findsOneWidget);
    });

    testWidgets('perubahan data memuat ulang halaman', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      final awal = fake.jumlahPanggil;
      await repo.hapus(1);
      await tester.pumpAndSettle();
      expect(fake.jumlahPanggil, awal + 1);
    });
  });

  test('ApiKegiatanRepository menaikkan versiData setelah tambah', () async {
    apiUrl.value = 'http://uji';
    final client = MockClient(
      (req) async => http.Response(
        jsonEncode({
          'id': 5,
          'judul': 'Gaji',
          'tanggal': '2026-10-06',
          'selesai': false,
          'tipe': 'pemasukan',
          'nominal': 100000,
          'kategori': '-',
        }),
        201,
      ),
    );
    final r = ApiKegiatanRepository(
      kegiatan: KegiatanApi(client: client),
      laporan: LaporanApi(client: client),
    );
    final awal = versiData.value;
    await r.tambah(
      const Kegiatan(
        judul: 'Gaji',
        tanggal: '2026-10-06',
        tipe: Tipe.pemasukan,
        nominal: 100000,
      ),
    );
    expect(versiData.value, awal + 1);
  });
}
