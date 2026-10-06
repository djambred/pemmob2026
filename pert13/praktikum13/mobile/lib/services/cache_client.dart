import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/cache_store.dart';
import '../state/sesi.dart';

/// null = data terbaru dari server; berisi waktu = sedang menampilkan
/// data tersimpan (offline) yang diambil pada waktu tersebut.
final statusOffline = ValueNotifier<DateTime?>(null);

/// Lapisan cache untuk request GET (strategi *network first*):
/// - online: respons 200 disimpan ke cache lalu diteruskan;
/// - jaringan gagal: kembalikan salinan terakhir dari cache bila ada.
/// Request selain GET (tambah/ubah/hapus) tidak di-cache dan akan gagal
/// saat offline.
class CacheClient extends http.BaseClient {
  final http.Client _inner;

  CacheClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method != 'GET') return _inner.send(request);

    // Kunci memuat id pengguna agar cache dua akun di satu HP tidak tertukar.
    final kunci = '${pengguna.value?.id}|${request.url}';
    try {
      final res = await _inner.send(request).timeout(batasWaktu);
      if (res.statusCode != 200) return res;
      final body = await res.stream.toBytes();
      await cacheStore.simpan(kunci, utf8.decode(body));
      statusOffline.value = null;
      return http.StreamedResponse(
        Stream.value(body),
        200,
        headers: res.headers,
        request: request,
      );
    } on Exception {
      // SocketException, ClientException, TimeoutException, ...
      final c = await cacheStore.baca(kunci);
      if (c == null) rethrow;
      statusOffline.value = c.waktu;
      return http.StreamedResponse(
        Stream.value(utf8.encode(c.isi)),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
        request: request,
      );
    }
  }

  @override
  void close() => _inner.close();
}
