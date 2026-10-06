import 'package:flutter/material.dart';

import 'models/kegiatan.dart';
import 'models/pengguna.dart';
import 'pages/form_kegiatan_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/shell_page.dart';
import 'pages/status_server_page.dart';
import 'state/pengaturan.dart';
import 'state/sesi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatPengaturan();
  await muatSesi();
  runApp(const MyApp());
}

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'TabungKu',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {
            // Halaman awal bergantung pada sesi: belum login -> LoginPage.
            '/': (_) => ValueListenableBuilder<Pengguna?>(
              valueListenable: pengguna,
              builder: (context, p, _) =>
                  p == null ? const LoginPage() : const ShellPage(),
            ),
            '/daftar': (_) => const RegisterPage(),
            '/status': (_) => const StatusServerPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/form') {
              final kegiatan = settings.arguments as Kegiatan?;
              return MaterialPageRoute(
                builder: (_) => FormKegiatanPage(kegiatan: kegiatan),
                settings: settings,
              );
            }
            return null;
          },
        );
      },
    );
  }
}
