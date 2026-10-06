import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/cache_store.dart';
import '../models/pengguna.dart';
import '../services/token_storage.dart';

/// Pengguna yang sedang login; null berarti belum login.
/// MyApp mendengarkan notifier ini untuk memilih halaman Login atau Shell.
final pengguna = ValueNotifier<Pengguna?>(null);

/// Token di memori agar tidak membaca storage di setiap request.
String? accessToken;
String? refreshToken;

/// Dapat diganti di test: `penyimpanToken = MemoryTokenStorage();`
TokenStorage penyimpanToken = SecureTokenStorage();

const _kunciAccess = 'access_token';
const _kunciRefresh = 'refresh_token';
const _kunciPengguna = 'pengguna';

/// Dipanggil sekali di main(): memulihkan sesi dari login sebelumnya.
Future<void> muatSesi() async {
  accessToken = await penyimpanToken.baca(_kunciAccess);
  refreshToken = await penyimpanToken.baca(_kunciRefresh);
  final profil = await penyimpanToken.baca(_kunciPengguna);
  if (accessToken != null && profil != null) {
    pengguna.value = Pengguna.fromJson(
      jsonDecode(profil) as Map<String, dynamic>,
    );
  }
}

/// Menyimpan pasangan token baru (setelah login atau refresh).
Future<void> simpanToken(String access, String refresh) async {
  accessToken = access;
  refreshToken = refresh;
  await penyimpanToken.tulis(_kunciAccess, access);
  await penyimpanToken.tulis(_kunciRefresh, refresh);
}

Future<void> simpanSesi(String access, String refresh, Pengguna p) async {
  await simpanToken(access, refresh);
  await penyimpanToken.tulis(_kunciPengguna, jsonEncode(p.toJson()));
  pengguna.value = p;
}

/// Memperbarui profil tersimpan (misalnya setelah target diubah).
Future<void> simpanPengguna(Pengguna p) async {
  await penyimpanToken.tulis(_kunciPengguna, jsonEncode(p.toJson()));
  pengguna.value = p;
}

Future<void> hapusSesi() async {
  accessToken = null;
  refreshToken = null;
  await penyimpanToken.hapusSemua();
  // Data akun tidak boleh tertinggal di HP setelah keluar.
  await cacheStore.hapusSemua();
  pengguna.value = null;
}
