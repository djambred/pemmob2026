import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pengumuman.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'cache_client.dart';

class PengumumanApi {
  final http.Client _client;

  PengumumanApi({http.Client? client})
    : _client = client ?? CacheClient(ApiClient());

  Future<List<Pengumuman>> daftar() async {
    final res = await _client
        .get(Uri.parse('${apiUrl.value}/pengumuman'))
        .timeout(batasWaktu);
    if (res.statusCode != 200) throw ApiException.dariRespons(res);
    return [
      for (final e in jsonDecode(res.body) as List<dynamic>)
        Pengumuman.fromJson(e as Map<String, dynamic>),
    ];
  }
}
