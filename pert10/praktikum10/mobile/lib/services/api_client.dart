import 'package:http/http.dart' as http;

import '../state/sesi.dart';

/// http.Client yang otomatis menambahkan header
/// `Authorization: Bearer <token>` ke setiap request bila sudah login.
class ApiClient extends http.BaseClient {
  final http.Client _inner;

  ApiClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final token = accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
