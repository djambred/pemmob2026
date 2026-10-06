import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/komentar.dart';
import '../models/post.dart';

/// Kode pengambil data, terpisah dari UI.
class ApiService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  /// [client] dapat diganti (misalnya MockClient) saat pengujian.
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<dynamic>> _getList(String path) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl$path'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data (kode ${response.statusCode})');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<List<Post>> ambilPosts() async {
    final data = await _getList('/posts');
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Komentar>> ambilKomentar(int postId) async {
    final data = await _getList('/posts/$postId/comments');
    return data
        .map((e) => Komentar.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
