import 'dart:convert';

import 'package:http/http.dart' as http;

/// Galat dari API dalam bentuk yang siap ditampilkan ke pengguna.
class ApiException implements Exception {
  final int? kode;
  final String pesan;

  const ApiException(this.pesan, {this.kode});

  /// Membaca field `detail` dari respons FastAPI:
  /// - HTTPException  -> {"detail": "Kegiatan tidak ditemukan"}
  /// - validasi (422) -> {"detail": [{"loc": [...], "msg": "..."}]}
  factory ApiException.dariRespons(http.Response res) {
    String pesan = 'Server membalas kode ${res.statusCode}';
    try {
      final detail = (jsonDecode(res.body) as Map<String, dynamic>)['detail'];
      if (detail is String) {
        pesan = detail;
      } else if (detail is List) {
        pesan = detail
            .map((e) => (e['msg'] as String).replaceFirst('Value error, ', ''))
            .join('\n');
      }
    } catch (_) {
      // Badan respons bukan JSON (misalnya halaman galat 502 dari proxy).
    }
    return ApiException(pesan, kode: res.statusCode);
  }

  @override
  String toString() => pesan;
}
