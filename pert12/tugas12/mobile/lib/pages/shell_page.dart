import 'package:flutter/material.dart';

import '../services/cache_client.dart';

import 'beranda_page.dart';
import 'laporan_page.dart';
import 'pengaturan_page.dart';

/// Kerangka utama: tiga tab dengan NavigationBar.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [BerandaPage(), LaporanPage(), PengaturanPage()];
  static const _judul = ['Hari Ini', 'Laporan', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: Column(
        children: [
          // Banner muncul bila data berasal dari cache (offline).
          ValueListenableBuilder<DateTime?>(
            valueListenable: statusOffline,
            builder: (context, waktu, _) {
              if (waktu == null) return const SizedBox.shrink();
              final jam =
                  '${waktu.hour.toString().padLeft(2, '0')}:'
                  '${waktu.minute.toString().padLeft(2, '0')}';
              return Material(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.cloud_off),
                  title: const Text('Offline: menampilkan data tersimpan'),
                  subtitle: Text('Terakhir diperbarui pukul $jam'),
                ),
              );
            },
          ),
          Expanded(
            child: IndexedStack(index: _index, children: _halaman),
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/form'),
              icon: const Icon(Icons.add),
              label: const Text('Kegiatan'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hari Ini',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
