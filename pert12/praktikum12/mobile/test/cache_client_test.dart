import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tabungku/config/api_config.dart';
import 'package:tabungku/data/cache_store.dart';
import 'package:tabungku/models/pengguna.dart';
import 'package:tabungku/services/cache_client.dart';
import 'package:tabungku/services/token_storage.dart';
import 'package:tabungku/state/sesi.dart';

Pengguna _akun(int id) =>
    Pengguna(id: id, nama: 'U$id', email: 'u$id@x.id', targetHarian: 0);

void main() {
  var online = true;
  late MemoryCacheStore store;
  late CacheClient client;

  setUp(() async {
    apiUrl.value = 'http://uji';
    penyimpanToken = MemoryTokenStorage();
    store = MemoryCacheStore();
    cacheStore = store;
    online = true;
    statusOffline.value = null;
    await simpanSesi('a', 'r', _akun(1));
    client = CacheClient(
      MockClient((req) async {
        if (!online) throw http.ClientException('tidak ada jaringan');
        return http.Response(jsonEncode([req.url.path]), 200);
      }),
    );
  });

  test('online: respons GET disimpan ke cache', () async {
    final res = await client.get(Uri.parse('http://uji/kegiatan'));
    expect(res.body, '["/kegiatan"]');
    expect(store.data.keys, ['1|http://uji/kegiatan']);
    expect(statusOffline.value, isNull);
  });

  test('offline: memakai cache dan menandai statusOffline', () async {
    await client.get(Uri.parse('http://uji/kegiatan'));
    online = false;
    final res = await client.get(Uri.parse('http://uji/kegiatan'));
    expect(res.statusCode, 200);
    expect(jsonDecode(res.body), ['/kegiatan']);
    expect(statusOffline.value, isNotNull);

    online = true;
    await client.get(Uri.parse('http://uji/kegiatan'));
    expect(statusOffline.value, isNull);
  });

  test('offline tanpa cache: galat diteruskan', () async {
    online = false;
    expect(
      client.get(Uri.parse('http://uji/laporan/harian')),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('POST tidak di-cache', () async {
    await client.post(Uri.parse('http://uji/kegiatan'), body: '{}');
    expect(store.data, isEmpty);
  });

  test('cache akun lain tidak dipakai', () async {
    await client.get(Uri.parse('http://uji/kegiatan'));
    await simpanSesi('b', 'r', _akun(2));
    online = false;
    expect(
      client.get(Uri.parse('http://uji/kegiatan')),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('keluar dari akun menghapus cache', () async {
    await client.get(Uri.parse('http://uji/kegiatan'));
    await hapusSesi();
    expect(store.data, isEmpty);
  });
}
