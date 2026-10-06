import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class Kontak {
  final String nama;
  final String telepon;
  final String email;
  const Kontak(this.nama, this.telepon, this.email);

  String get inisial => nama[0].toUpperCase();
}

const daftarKontak = [
  Kontak('Andi Pratama', '0812-1111-2222', 'andi@example.com'),
  Kontak('Budi Santoso', '0813-3333-4444', 'budi@example.com'),
  Kontak('Citra Lestari', '0814-5555-6666', 'citra@example.com'),
  Kontak('Dewi Anggraini', '0815-7777-8888', 'dewi@example.com'),
  Kontak('Eko Saputra', '0816-9999-0000', 'eko@example.com'),
  Kontak('Fitri Handayani', '0817-1212-3434', 'fitri@example.com'),
  Kontak('Gilang Ramadhan', '0818-5656-7878', 'gilang@example.com'),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const KontakPage(),
    );
  }
}

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kontak')),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];
          return ListTile(
            leading: CircleAvatar(child: Text(kontak.inisial)),
            title: Text(kontak.nama),
            subtitle: Text(kontak.telepon),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailKontakPage(kontak: kontak),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailKontakPage extends StatelessWidget {
  final Kontak kontak;
  const DetailKontakPage({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kontak.nama)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(kontak.inisial, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              kontak.nama,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Nama'),
            subtitle: Text(kontak.nama),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Telepon'),
            subtitle: Text(kontak.telepon),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(kontak.email),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
          ),
        ],
      ),
    );
  }
}
