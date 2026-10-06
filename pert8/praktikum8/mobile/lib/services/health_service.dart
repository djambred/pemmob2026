import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class StatusServer {
  final String status;
  final String waktuServer;
  final Duration latensi;

  const StatusServer({
    required this.status,
    required this.waktuServer,
    required this.latensi,
  });
}

/// Memanggil GET /health dan mengukur lama responsnya.
Future<StatusServer> cekServer({http.Client? client}) async {
  final c = client ?? http.Client();
  final jam = Stopwatch()..start();
  try {
    final res = await c.get(Uri.parse('$apiUrl/health')).timeout(batasWaktu);
    jam.stop();
    if (res.statusCode != 200) {
      throw Exception('Server membalas kode ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return StatusServer(
      status: data['status'] as String,
      waktuServer: data['waktu_server'] as String,
      latensi: jam.elapsed,
    );
  } finally {
    if (client == null) c.close();
  }
}
