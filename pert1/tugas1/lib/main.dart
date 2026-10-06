import 'package:flutter/material.dart';

// Data kartu perkenalan. Ganti nilainya sesuai data Anda.
const nama = 'Jefry';
const nim = '8126';
const jurusan = 'Teknik Informatika';
const hobi = 'Membaca, bersepeda, dan ngoding';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kartu Perkenalan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const KartuPerkenalanPage(),
    );
  }
}

class KartuPerkenalanPage extends StatelessWidget {
  const KartuPerkenalanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Perkenalan'),
        backgroundColor: warna.primary,
        foregroundColor: warna.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Foto/ikon
              CircleAvatar(
                radius: 56,
                backgroundColor: warna.primaryContainer,
                child: Icon(Icons.person, size: 64, color: warna.primary),
              ),
              const SizedBox(height: 16),
              Text(
                nama,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: warna.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text('NIM: $nim', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              const BarisInfo(
                ikon: Icons.school,
                label: 'Jurusan',
                isi: jurusan,
              ),
              const SizedBox(height: 12),
              const BarisInfo(ikon: Icons.favorite, label: 'Hobi', isi: hobi),
            ],
          ),
        ),
      ),
    );
  }
}

class BarisInfo extends StatelessWidget {
  final IconData ikon;
  final String label;
  final String isi;

  const BarisInfo({
    super.key,
    required this.ikon,
    required this.label,
    required this.isi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(ikon, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(isi, textAlign: TextAlign.center),
      ],
    );
  }
}
