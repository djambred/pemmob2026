import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/kegiatan.dart';
import 'api_exception.dart';

/// Pembungkus endpoint /kegiatan milik backend FastAPI.
class KegiatanApi {
  final http.Client _client;

  KegiatanApi({http.Client? client}) : _client = client ?? http.Client();

  static const _json = {'Content-Type': 'application/json'};

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${apiUrl.value}$path').replace(queryParameters: query);

  /// Lempar [ApiException] bila kode status di luar 2xx.
  http.Response _cek(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException.dariRespons(res);
    }
    return res;
  }

  Future<List<Kegiatan>> daftar({String? tanggal}) async {
    final res = _cek(
      await _client
          .get(_uri('/kegiatan', {'tanggal': ?tanggal}))
          .timeout(batasWaktu),
    );
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => Kegiatan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Kegiatan> tambah(Kegiatan k) async {
    final res = _cek(
      await _client
          .post(_uri('/kegiatan'), headers: _json, body: jsonEncode(k.toJson()))
          .timeout(batasWaktu),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Kegiatan> ubah(Kegiatan k) async {
    final res = _cek(
      await _client
          .put(
            _uri('/kegiatan/${k.id}'),
            headers: _json,
            body: jsonEncode(k.toJson()),
          )
          .timeout(batasWaktu),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Hanya mengubah status selesai (PATCH).
  Future<Kegiatan> setSelesai(int id, bool selesai) async {
    final res = _cek(
      await _client
          .patch(
            _uri('/kegiatan/$id'),
            headers: _json,
            body: jsonEncode({'selesai': selesai}),
          )
          .timeout(batasWaktu),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> hapus(int id) async {
    _cek(await _client.delete(_uri('/kegiatan/$id')).timeout(batasWaktu));
  }
}
