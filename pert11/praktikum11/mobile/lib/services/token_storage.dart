import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tempat menyimpan token. Dibuat abstrak agar test dapat memakai
/// [MemoryTokenStorage] tanpa plugin native.
abstract class TokenStorage {
  Future<String?> baca(String kunci);
  Future<void> tulis(String kunci, String nilai);
  Future<void> hapusSemua();
}

/// Disimpan terenkripsi: Keystore (Android) dan Keychain (iOS).
/// Jangan simpan token di shared_preferences karena berupa teks biasa.
class SecureTokenStorage implements TokenStorage {
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> baca(String kunci) => _storage.read(key: kunci);

  @override
  Future<void> tulis(String kunci, String nilai) =>
      _storage.write(key: kunci, value: nilai);

  @override
  Future<void> hapusSemua() => _storage.deleteAll();
}

class MemoryTokenStorage implements TokenStorage {
  final data = <String, String>{};

  @override
  Future<String?> baca(String kunci) async => data[kunci];

  @override
  Future<void> tulis(String kunci, String nilai) async => data[kunci] = nilai;

  @override
  Future<void> hapusSemua() async => data.clear();
}
