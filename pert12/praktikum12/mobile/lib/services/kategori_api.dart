import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/kategori.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'cache_client.dart';

/// GET /kategori: daftar kategori aktif yang dikelola admin.
class KategoriApi {
  final http.Client _client;

  KategoriApi({http.Client? client})
    : _client = client ?? CacheClient(ApiClient());

  Future<List<Kategori>> daftar() async {
    final res = await _client
        .get(Uri.parse('${apiUrl.value}/kategori'))
        .timeout(batasWaktu);
    if (res.statusCode != 200) throw ApiException.dariRespons(res);
    return [
      for (final e in jsonDecode(res.body) as List<dynamic>)
        Kategori.fromJson(e as Map<String, dynamic>),
    ];
  }
}
