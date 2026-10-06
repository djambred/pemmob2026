import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class StatusServer {
  final bool apiOk;
  final bool databaseOk;
  final String waktuServer;
  final String? versiMysql;
  final String? detail;
  final Duration latensi;

  const StatusServer({
    required this.apiOk,
    required this.databaseOk,
    required this.waktuServer,
    required this.latensi,
    this.versiMysql,
    this.detail,
  });
}

/// Memanggil GET /health dan mengukur lama responsnya.
///
/// Kode 503 tetap dibaca karena artinya API hidup tetapi database bermasalah.
Future<StatusServer> cekServer({http.Client? client}) async {
  final c = client ?? http.Client();
  final jam = Stopwatch()..start();
  try {
    final res = await c
        .get(Uri.parse('${apiUrl.value}/health'))
        .timeout(batasWaktu);
    jam.stop();
    if (res.statusCode != 200 && res.statusCode != 503) {
      throw Exception('Server membalas kode ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return StatusServer(
      apiOk: true,
      databaseOk: data['database'] == 'ok',
      waktuServer: data['waktu_server'] as String,
      versiMysql: data['mysql_version'] as String?,
      detail: data['detail'] as String?,
      latensi: jam.elapsed,
    );
  } finally {
    if (client == null) c.close();
  }
}
