import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pengguna.dart';
import '../state/sesi.dart';
import 'api_exception.dart';

/// Register, login, dan profil (/auth/*, /users/me).
class AuthApi {
  final http.Client _client;

  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${apiUrl.value}$path');

  Future<void> daftar(String nama, String email, String password) async {
    final res = await _client
        .post(
          _uri('/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nama': nama,
            'email': email,
            'password': password,
          }),
        )
        .timeout(batasWaktu);
    if (res.statusCode != 201) throw ApiException.dariRespons(res);
  }

  /// Login lalu ambil profil, kemudian simpan sesi.
  ///
  /// Endpoint login memakai form OAuth2 (bukan JSON). Mengirim `body`
  /// berupa `Map<String, String>` membuat paket http otomatis memakai
  /// `application/x-www-form-urlencoded`.
  Future<Pengguna> masuk(String email, String password) async {
    final res = await _client
        .post(
          _uri('/auth/login'),
          body: {'username': email, 'password': password},
        )
        .timeout(batasWaktu);
    if (res.statusCode != 200) throw ApiException.dariRespons(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final access = data['access_token'] as String;
    final refresh = data['refresh_token'] as String;

    final p = await profil(access);
    await simpanSesi(access, refresh, p);
    return p;
  }

  Future<Pengguna> profil(String token) async {
    final res = await _client
        .get(_uri('/users/me'), headers: {'Authorization': 'Bearer $token'})
        .timeout(batasWaktu);
    if (res.statusCode != 200) throw ApiException.dariRespons(res);
    return Pengguna.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
