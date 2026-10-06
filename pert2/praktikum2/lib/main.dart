import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Model data (Bagian B + Latihan 2: properti deskripsi)
class Makanan {
  final String nama;
  final int harga;
  final String deskripsi;
  const Makanan(this.nama, this.harga, this.deskripsi);
}

// Latihan 1: 3 menu tambahan
const daftarMenu = [
  Makanan(
    'Nasi Goreng',
    15000,
    'Nasi goreng dengan telur, ayam suwir, dan kerupuk.',
  ),
  Makanan('Mie Ayam', 12000, 'Mie kenyal dengan topping ayam kecap dan sawi.'),
  Makanan('Es Teh', 4000, 'Teh manis dingin yang menyegarkan.'),
  Makanan(
    'Ayam Bakar',
    20000,
    'Ayam bakar bumbu kecap disajikan dengan sambal.',
  ),
  Makanan('Sate Ayam', 18000, 'Sepuluh tusuk sate ayam dengan bumbu kacang.'),
  Makanan('Bakso', 14000, 'Bakso sapi dengan kuah kaldu gurih.'),
  Makanan('Jus Alpukat', 10000, 'Jus alpukat segar dengan susu cokelat.'),
];

// Latihan 4: format ribuan buatan sendiri (15000 -> 15.000)
String formatRibuan(int angka) {
  final teks = angka.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < teks.length; i++) {
    if (i > 0 && (teks.length - i) % 3 == 0) buffer.write('.');
    buffer.write(teks[i]);
  }
  return buffer.toString();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const MenuPage(),
    );
  }
}

// Bagian A: Layout Kartu Profil
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                child: Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Jefry',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Kode Dosen: 8126'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bagian B: ListView.builder
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];
          // Latihan 3: Container berwarna dengan sudut membulat menggantikan Card
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            // Material transparan agar efek sentuh ListTile tetap terlihat di atas
            // warna Container (tanpa ini Flutter memunculkan assertion di mode debug)
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(item.nama),
                subtitle: Text('Rp ${formatRibuan(item.harga)}'),
                trailing: const Icon(Icons.chevron_right),
                // Bagian C: navigasi ke halaman detail
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(makanan: item),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Bagian C: halaman detail menerima data lewat constructor
class DetailPage extends StatelessWidget {
  final Makanan makanan;
  const DetailPage({super.key, required this.makanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(makanan.nama)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 80),
              const SizedBox(height: 16),
              Text(makanan.nama, style: const TextStyle(fontSize: 24)),
              Text('Rp ${formatRibuan(makanan.harga)}'),
              const SizedBox(height: 8),
              Text(makanan.deskripsi, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
