import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../services/auth_api.dart';
import 'sesi.dart';

/// Pengaturan global sederhana. Nilainya disimpan dengan
/// shared_preferences agar tetap ada setelah aplikasi ditutup.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.teal);
final targetHarian = ValueNotifier<int>(20000);

const pilihanWarna = [
  Colors.teal,
  Colors.indigo,
  Colors.deepOrange,
  Colors.pink,
];

Future<void> muatPengaturan() async {
  final prefs = await SharedPreferences.getInstance();
  final gelap = prefs.getBool('gelap') ?? false;
  final warna = (prefs.getInt('warna') ?? 0)
      .clamp(0, pilihanWarna.length - 1)
      .toInt();

  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  seedColor.value = pilihanWarna[warna];
  targetHarian.value = prefs.getInt('target') ?? 20000;
  apiUrl.value = prefs.getString('api_url') ?? apiUrlBawaan;
}

Future<void> simpanGelap(bool nilai) async {
  themeMode.value = nilai ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('gelap', nilai);
}

Future<void> simpanWarna(int index) async {
  seedColor.value = pilihanWarna[index];
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('warna', index);
}

/// Sejak tugas 11 target milik akun dan disimpan di server, sehingga sama
/// di semua HP. Bila gagal, nilai dikembalikan dan galat diteruskan.
Future<void> simpanTarget(int nilai) async {
  targetHarian.value = nilai;
  final akun = pengguna.value;
  if (akun == null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('target', nilai);
    return;
  }
  try {
    await AuthApi().ubahTarget(nilai);
  } catch (_) {
    targetHarian.value = akun.targetHarian;
    rethrow;
  }
}

/// Dipanggil di main(): target mengikuti akun yang sedang login.
void ikutiTargetAkun() {
  void sinkron() {
    final p = pengguna.value;
    if (p != null) targetHarian.value = p.targetHarian;
  }

  sinkron();
  pengguna.addListener(sinkron);
}

/// Menyimpan alamat API. Garis miring di akhir dibuang agar
/// '$url/health' tidak menjadi '//health'.
Future<void> simpanApiUrl(String nilai) async {
  final bersih = nilai.trim().replaceAll(RegExp(r'/+$'), '');
  apiUrl.value = bersih;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('api_url', bersih);
}
