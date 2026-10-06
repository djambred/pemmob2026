import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tabungku/config/api_config.dart';
import 'package:tabungku/services/api_exception.dart';
import 'package:tabungku/services/laporan_api.dart';

// Data sama dengan "Contoh Skenario Satu Hari" pada modul 7.
void main() {
  setUp(() => apiUrl.value = 'http://uji');

  test('harian membaca ringkasan dan per kategori', () async {
    final api = LaporanApi(
      client: MockClient((req) async {
        expect(
          req.url.toString(),
          'http://uji/laporan/harian?tanggal=2026-10-05',
        );
        return http.Response(
          jsonEncode({
            'tanggal': '2026-10-05',
            'jumlah_kegiatan': 4,
            'selesai': 2,
            'pemasukan': 50000,
            'pengeluaran': 25000,
            'tabungan': 25000,
            'per_kategori': [
              {'kategori': 'Makan', 'total': 15000},
              {'kategori': 'Transport', 'total': 10000},
            ],
          }),
          200,
        );
      }),
    );
    final l = await api.harian('2026-10-05');
    expect(l.ringkasan.jumlahKegiatan, 4);
    expect(l.ringkasan.selesai, 2);
    expect(l.ringkasan.tabungan, 25000);
    expect(l.perKategori, {'Makan': 15000, 'Transport': 10000});
  });

  test('rentang mengubah tanggal menjadi DateTime', () async {
    final api = LaporanApi(
      client: MockClient((req) async {
        expect(req.url.queryParameters, {
          'mulai': '2026-10-04',
          'sampai': '2026-10-05',
        });
        Map<String, Object> hari(String t, int masuk) => {
          'tanggal': t,
          'jumlah_kegiatan': masuk == 0 ? 0 : 1,
          'selesai': 0,
          'pemasukan': masuk,
          'pengeluaran': 0,
          'tabungan': masuk,
        };
        return http.Response(
          jsonEncode([hari('2026-10-04', 0), hari('2026-10-05', 50000)]),
          200,
        );
      }),
    );
    final r = await api.rentang(DateTime(2026, 10, 4), DateTime(2026, 10, 5));
    expect(r.length, 2);
    expect(r.last.key, DateTime(2026, 10, 5));
    expect(r.last.value.pemasukan, 50000);
  });

  test('rentang terlalu panjang ditolak server', () async {
    final api = LaporanApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'detail': 'Rentang maksimal 31 hari'}),
          400,
        ),
      ),
    );
    expect(
      () => api.rentang(DateTime(2026, 1, 1), DateTime(2026, 3, 1)),
      throwsA(isA<ApiException>().having((e) => e.kode, 'kode', 400)),
    );
  });
}
