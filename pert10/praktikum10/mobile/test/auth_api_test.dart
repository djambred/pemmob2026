import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tabungku/config/api_config.dart';
import 'package:tabungku/services/api_client.dart';
import 'package:tabungku/services/api_exception.dart';
import 'package:tabungku/services/auth_api.dart';
import 'package:tabungku/services/token_storage.dart';
import 'package:tabungku/state/sesi.dart';

const _profil = {
  'id': 1,
  'nama': 'Budi',
  'email': 'budi@contoh.id',
  'target_harian': 20000,
};

void main() {
  late MemoryTokenStorage storage;

  setUp(() async {
    apiUrl.value = 'http://uji';
    storage = MemoryTokenStorage();
    penyimpanToken = storage;
    await hapusSesi();
  });

  test('masuk mengirim form, mengambil profil, dan menyimpan sesi', () async {
    final api = AuthApi(
      client: MockClient((req) async {
        if (req.url.path == '/auth/login') {
          expect(
            req.headers['Content-Type'],
            startsWith('application/x-www-form-urlencoded'),
          );
          expect(req.bodyFields, {
            'username': 'budi@contoh.id',
            'password': 'rahasia123',
          });
          return http.Response(
            jsonEncode({'access_token': 'tok-1', 'token_type': 'bearer'}),
            200,
          );
        }
        expect(req.url.path, '/users/me');
        expect(req.headers['Authorization'], 'Bearer tok-1');
        return http.Response(jsonEncode(_profil), 200);
      }),
    );

    final p = await api.masuk('budi@contoh.id', 'rahasia123');
    expect(p.nama, 'Budi');
    expect(pengguna.value?.email, 'budi@contoh.id');
    expect(accessToken, 'tok-1');
    expect(storage.data['access_token'], 'tok-1');
  });

  test('login salah: pesan dari server, sesi tetap kosong', () async {
    final api = AuthApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'detail': 'Email atau password salah'}),
          401,
        ),
      ),
    );
    expect(
      () => api.masuk('budi@contoh.id', 'salah'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.pesan,
          'pesan',
          'Email atau password salah',
        ),
      ),
    );
    expect(pengguna.value, isNull);
  });

  test('sesi dipulihkan dari storage saat aplikasi dibuka lagi', () async {
    storage.data['access_token'] = 'tok-lama';
    storage.data['pengguna'] = jsonEncode(_profil);
    await muatSesi();
    expect(accessToken, 'tok-lama');
    expect(pengguna.value?.nama, 'Budi');
  });

  test('ApiClient menambahkan header Authorization', () async {
    accessToken = 'tok-2';
    final client = ApiClient(
      MockClient((req) async {
        expect(req.headers['Authorization'], 'Bearer tok-2');
        return http.Response('[]', 200);
      }),
    );
    await client.get(Uri.parse('http://uji/kegiatan'));
  });

  test('hapusSesi mengosongkan token dan pengguna', () async {
    storage.data['access_token'] = 'tok';
    await hapusSesi();
    expect(storage.data, isEmpty);
    expect(pengguna.value, isNull);
    expect(accessToken, isNull);
  });
}
