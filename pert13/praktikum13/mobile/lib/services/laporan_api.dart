import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'cache_client.dart';

/// Pembungkus endpoint /laporan milik backend FastAPI.
class LaporanApi {
  final http.Client _client;

  LaporanApi({http.Client? client})
    : _client = client ?? CacheClient(ApiClient());

  Future<dynamic> _get(String path, Map<String, String> query) async {
    final uri = Uri.parse('${apiUrl.value}$path')
        .replace(queryParameters: query);
    final res = await _client.get(uri).timeout(batasWaktu);
    if (res.statusCode != 200) throw ApiException.dariRespons(res);
    return jsonDecode(res.body);
  }

  Future<LaporanHarian> harian(String tanggal) async {
    final j = await _get('/laporan/harian', {'tanggal': tanggal});
    return LaporanHarian.fromJson(j as Map<String, dynamic>);
  }

  /// Ringkasan per hari dari [mulai] sampai [sampai], urut naik.
  Future<List<MapEntry<DateTime, Ringkasan>>> rentang(
    DateTime mulai,
    DateTime sampai,
  ) async {
    final j = await _get('/laporan/rentang', {
      'mulai': fmtTanggal(mulai),
      'sampai': fmtTanggal(sampai),
    });
    return [
      for (final e in j as List<dynamic>)
        MapEntry(
          DateTime.parse(e['tanggal'] as String),
          Ringkasan.fromJson(e as Map<String, dynamic>),
        ),
    ];
  }
}
