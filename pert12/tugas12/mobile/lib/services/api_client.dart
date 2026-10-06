import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../state/sesi.dart';

/// http.Client yang:
/// 1. menambahkan header `Authorization: Bearer <token>`;
/// 2. bila server membalas 401 (access token kedaluwarsa), meminta token
///    baru ke /auth/refresh lalu mengulang request sekali;
/// 3. bila refresh juga ditolak, menghapus sesi sehingga aplikasi kembali
///    ke halaman login (auto-logout).
class ApiClient extends http.BaseClient {
  final http.Client _inner;

  ApiClient([http.Client? inner]) : _inner = inner ?? http.Client();

  /// Dipakai bersama agar beberapa request yang gagal bersamaan
  /// (misalnya di halaman Laporan) hanya memicu satu kali refresh.
  static Future<bool?>? _sedangRefresh;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Body request hanya bisa dikirim sekali, jadi disalin lebih dulu
    // agar dapat dikirim ulang setelah token diperbarui.
    final salinan = request is http.Request ? _salin(request) : null;

    final res = await _inner.send(_pasangToken(request));
    if (res.statusCode != 401 ||
        refreshToken == null ||
        request.url.path.startsWith('/auth/')) {
      return res;
    }

    final berhasil = await (_sedangRefresh ??= _refresh().whenComplete(
      () => _sedangRefresh = null,
    ));
    if (berhasil == true && salinan != null) {
      return _inner.send(_pasangToken(salinan));
    }
    if (berhasil == false) await hapusSesi();
    return res;
  }

  http.BaseRequest _pasangToken(http.BaseRequest r) {
    final token = accessToken;
    if (token != null) r.headers['Authorization'] = 'Bearer $token';
    return r;
  }

  http.Request _salin(http.Request r) => http.Request(r.method, r.url)
    ..headers.addAll(r.headers)
    ..bodyBytes = r.bodyBytes
    ..followRedirects = r.followRedirects
    ..persistentConnection = r.persistentConnection;

  /// true = token baru tersimpan, false = refresh ditolak (harus login
  /// ulang), null = server tidak dapat dihubungi (sesi dipertahankan).
  Future<bool?> _refresh() async {
    try {
      final res = await _inner
          .post(
            Uri.parse('${apiUrl.value}/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(batasWaktu);
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await simpanToken(
        data['access_token'] as String,
        data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      return null;
    }
  }

  @override
  void close() => _inner.close();
}
