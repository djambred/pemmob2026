import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tabungku/config/api_config.dart';
import 'package:tabungku/services/health_service.dart';

// MockClient menggantikan server sungguhan sehingga test tidak butuh Docker.
void main() {
  setUp(() => apiUrl.value = 'http://server-uji:8000');

  test('API dan database sehat', () async {
    final client = MockClient((req) async {
      expect(req.url.toString(), 'http://server-uji:8000/health');
      return http.Response(
        jsonEncode({
          'status': 'ok',
          'waktu_server': '2026-10-06T08:00:00',
          'database': 'ok',
          'mysql_version': '8.4.6',
        }),
        200,
      );
    });
    final s = await cekServer(client: client);
    expect(s.apiOk, isTrue);
    expect(s.databaseOk, isTrue);
    expect(s.versiMysql, '8.4.6');
  });

  test('503 berarti API hidup tetapi database mati', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'status': 'error',
          'waktu_server': '2026-10-06T08:00:00',
          'database': 'error',
          'detail': "Can't connect to MySQL server",
        }),
        503,
      ),
    );
    final s = await cekServer(client: client);
    expect(s.apiOk, isTrue);
    expect(s.databaseOk, isFalse);
    expect(s.detail, contains('MySQL'));
  });

  test('kode lain dianggap galat', () async {
    final client = MockClient((_) async => http.Response('rusak', 500));
    expect(cekServer(client: client), throwsException);
  });
}
