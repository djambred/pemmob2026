import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tabungku/services/health_service.dart';

// MockClient menggantikan server sungguhan sehingga test tidak butuh Docker.
void main() {
  test('cekServer membaca status dan waktu server', () async {
    final client = MockClient((req) async {
      expect(req.url.path, '/health');
      return http.Response(
        jsonEncode({'status': 'ok', 'waktu_server': '2026-10-06T08:00:00'}),
        200,
      );
    });
    final s = await cekServer(client: client);
    expect(s.status, 'ok');
    expect(s.waktuServer, '2026-10-06T08:00:00');
  });

  test('cekServer melempar galat bila kode bukan 200', () async {
    final client = MockClient((_) async => http.Response('rusak', 500));
    expect(cekServer(client: client), throwsException);
  });
}
