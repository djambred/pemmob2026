import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tabungku/config/api_config.dart';
import 'package:tabungku/models/pengguna.dart';
import 'package:tabungku/services/api_client.dart';
import 'package:tabungku/services/token_storage.dart';
import 'package:tabungku/state/sesi.dart';

const _budi = Pengguna(
  id: 1,
  nama: 'Budi',
  email: 'budi@contoh.id',
  targetHarian: 20000,
);

http.Response _token(String access, String refresh) => http.Response(
  jsonEncode({'access_token': access, 'refresh_token': refresh}),
  200,
);

void main() {
  setUp(() async {
    apiUrl.value = 'http://uji';
    penyimpanToken = MemoryTokenStorage();
    await simpanSesi('lama', 'ref-lama', _budi);
  });

  test('401 -> refresh -> request diulang dengan token baru', () async {
    final log = <String>[];
    final client = ApiClient(
      MockClient((req) async {
        log.add(
          '${req.method} ${req.url.path} ${req.headers['Authorization']}',
        );
        if (req.url.path == '/auth/refresh') {
          expect(jsonDecode(req.body), {'refresh_token': 'ref-lama'});
          return _token('baru', 'ref-baru');
        }
        return req.headers['Authorization'] == 'Bearer baru'
            ? http.Response('[]', 200)
            : http.Response('{"detail":"kedaluwarsa"}', 401);
      }),
    );

    final res = await client.post(
      Uri.parse('http://uji/kegiatan'),
      body: '{"judul":"x"}',
    );
    expect(res.statusCode, 200);
    expect(log, [
      'POST /kegiatan Bearer lama',
      'POST /auth/refresh null',
      'POST /kegiatan Bearer baru',
    ]);
    expect(accessToken, 'baru');
    expect(refreshToken, 'ref-baru');
    expect(pengguna.value, isNotNull);
  });

  test('refresh ditolak -> sesi dihapus (auto-logout)', () async {
    final client = ApiClient(
      MockClient((req) async => http.Response('{"detail":"x"}', 401)),
    );
    final res = await client.get(Uri.parse('http://uji/kegiatan'));
    expect(res.statusCode, 401);
    expect(pengguna.value, isNull);
    expect(accessToken, isNull);
  });

  test('server mati saat refresh -> sesi dipertahankan', () async {
    final client = ApiClient(
      MockClient((req) async {
        if (req.url.path == '/auth/refresh') {
          throw http.ClientException('tidak ada jaringan');
        }
        return http.Response('{"detail":"x"}', 401);
      }),
    );
    await client.get(Uri.parse('http://uji/kegiatan'));
    expect(pengguna.value, isNotNull);
  });

  test('beberapa 401 bersamaan hanya memicu satu refresh', () async {
    var jumlahRefresh = 0;
    final client = ApiClient(
      MockClient((req) async {
        if (req.url.path == '/auth/refresh') {
          jumlahRefresh++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return _token('baru', 'ref-baru');
        }
        return req.headers['Authorization'] == 'Bearer baru'
            ? http.Response('{}', 200)
            : http.Response('{}', 401);
      }),
    );
    final hasil = await Future.wait([
      client.get(Uri.parse('http://uji/laporan/harian')),
      client.get(Uri.parse('http://uji/laporan/rentang')),
      client.get(Uri.parse('http://uji/kegiatan')),
    ]);
    expect(hasil.map((r) => r.statusCode), [200, 200, 200]);
    expect(jumlahRefresh, 1);
  });

  test('401 dari /auth/login tidak memicu refresh', () async {
    var dipanggil = 0;
    final client = ApiClient(
      MockClient((req) async {
        dipanggil++;
        return http.Response('{}', 401);
      }),
    );
    await client.post(Uri.parse('http://uji/auth/login'));
    expect(dipanggil, 1);
    expect(pengguna.value, isNotNull);
  });
}
