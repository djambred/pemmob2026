import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/pengguna.dart';
import '../services/token_storage.dart';

/// Pengguna yang sedang login; null berarti belum login.
/// MyApp mendengarkan notifier ini untuk memilih halaman Login atau Shell.
final pengguna = ValueNotifier<Pengguna?>(null);

/// Access token di memori agar tidak membaca storage di setiap request.
String? accessToken;

/// Dapat diganti di test: `penyimpanToken = MemoryTokenStorage();`
TokenStorage penyimpanToken = SecureTokenStorage();

const _kunciToken = 'access_token';
const _kunciPengguna = 'pengguna';

/// Dipanggil sekali di main(): memulihkan sesi dari login sebelumnya.
Future<void> muatSesi() async {
  accessToken = await penyimpanToken.baca(_kunciToken);
  final profil = await penyimpanToken.baca(_kunciPengguna);
  if (accessToken != null && profil != null) {
    pengguna.value = Pengguna.fromJson(
      jsonDecode(profil) as Map<String, dynamic>,
    );
  }
}

Future<void> simpanSesi(String token, Pengguna p) async {
  accessToken = token;
  await penyimpanToken.tulis(_kunciToken, token);
  await penyimpanToken.tulis(_kunciPengguna, jsonEncode(p.toJson()));
  pengguna.value = p;
}

Future<void> hapusSesi() async {
  accessToken = null;
  await penyimpanToken.hapusSemua();
  pengguna.value = null;
}
