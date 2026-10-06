import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/daftar_page.dart';

/// Pengaturan mode gelap; disimpan dengan shared_preferences.
final modeGelap = ValueNotifier<bool>(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  modeGelap.value = prefs.getBool('gelap') ?? false;
  runApp(const MyApp());
}

Future<void> ubahModeGelap(bool nilai) async {
  modeGelap.value = nilai;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('gelap', nilai);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modeGelap,
      builder: (context, gelap, _) {
        return MaterialApp(
          title: 'Pencatat Pengeluaran',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.orange,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: gelap ? ThemeMode.dark : ThemeMode.light,
          home: const DaftarPage(),
        );
      },
    );
  }
}
