import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/kegiatan.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'cache_client.dart';

/// Pembungkus endpoint /kegiatan milik backend FastAPI.
class KegiatanApi {
  final http.Client _client;

  KegiatanApi({http.Client? client})
    : _client = client ?? CacheClient(ApiClient());

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

  /// Unggah foto bukti (multipart/form-data, field `berkas`).
  Future<Kegiatan> unggahBukti(int id, List<int> isi, String namaBerkas) async {
    final req = http.MultipartRequest('POST', _uri('/kegiatan/$id/bukti'))
      ..files.add(
        http.MultipartFile.fromBytes(
          'berkas',
          isi,
          filename: namaBerkas,
          contentType: MediaType.parse(jenisGambar(namaBerkas)),
        ),
      );
    // Unggah butuh waktu lebih lama daripada request biasa.
    final res = _cek(
      await http.Response.fromStream(
        await _client.send(req).timeout(const Duration(seconds: 60)),
      ),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Kegiatan> hapusBukti(int id) async {
    final res = _cek(
      await _client.delete(_uri('/kegiatan/$id/bukti')).timeout(batasWaktu),
    );
    return Kegiatan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

/// Content-Type dari ekstensi berkas (server hanya menerima tiga jenis ini).
String jenisGambar(String namaBerkas) {
  final n = namaBerkas.toLowerCase();
  if (n.endsWith('.png')) return 'image/png';
  if (n.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
