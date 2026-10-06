import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pengaturan dan favorit global; disimpan dengan shared_preferences.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.teal);
final favorit = ValueNotifier<Set<String>>({});

const pilihanWarna = [
  Colors.teal,
  Colors.indigo,
  Colors.deepOrange,
  Colors.pink,
];

Future<void> muatPengaturan() async {
  final prefs = await SharedPreferences.getInstance();
  themeMode.value = (prefs.getBool('gelap') ?? false)
      ? ThemeMode.dark
      : ThemeMode.light;
  final indeks = (prefs.getInt('warna') ?? 0).clamp(0, pilihanWarna.length - 1);
  seedColor.value = pilihanWarna[indeks];
  favorit.value = (prefs.getStringList('favorit') ?? []).toSet();
}

Future<void> simpanGelap(bool nilai) async {
  themeMode.value = nilai ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('gelap', nilai);
}

Future<void> simpanWarna(int indeks) async {
  seedColor.value = pilihanWarna[indeks];
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('warna', indeks);
}

Future<void> toggleFavorit(String id) async {
  final baru = {...favorit.value};
  if (!baru.remove(id)) baru.add(id);
  favorit.value = baru;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('favorit', baru.toList());
}
