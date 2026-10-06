import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db_helper.dart';
import '../main.dart';
import '../models/pengeluaran.dart';
import 'form_page.dart';

class DataDaftar {
  final List<Pengeluaran> items;
  final int total;
  const DataDaftar(this.items, this.total);
}

class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});

  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  String? _filter; // kategori filter terakhir, disimpan di shared_preferences
  late Future<DataDaftar> _future;

  @override
  void initState() {
    super.initState();
    _future = _ambil();
    _muatFilter();
  }

  Future<DataDaftar> _ambil() async {
    final items = await DbHelper.semua(kategori: _filter);
    final total = await DbHelper.total(kategori: _filter);
    return DataDaftar(items, total);
  }

  void _muat() {
    setState(() {
      _future = _ambil();
    });
  }

  Future<void> _muatFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final simpanan = prefs.getString('filterKategori');
    if (!mounted || simpanan == null) return;
    _filter = daftarKategori.contains(simpanan) ? simpanan : null;
    _muat();
  }

  Future<void> _ubahFilter(String? kategori) async {
    _filter = kategori;
    _muat();
    final prefs = await SharedPreferences.getInstance();
    if (kategori == null) {
      await prefs.remove('filterKategori');
    } else {
      await prefs.setString('filterKategori', kategori);
    }
  }

  Future<void> _buka([Pengeluaran? data]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPage(data: data)),
    );
    if (!mounted) return;
    _muat();
  }

  Future<void> _hapus(Pengeluaran x) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus pengeluaran ini?'),
        content: Text('${x.nama} (${rupiah(x.jumlah)})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ya != true) return;
    await DbHelper.hapus(x.id!);
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: modeGelap,
            builder: (context, gelap, _) => IconButton(
              tooltip: 'Mode gelap',
              icon: Icon(gelap ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => ubahModeGelap(!gelap),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _filter == null,
                  onSelected: (_) => _ubahFilter(null),
                ),
                for (final k in daftarKategori)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(k),
                      selected: _filter == k,
                      onSelected: (_) => _ubahFilter(k),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<DataDaftar>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Galat: ${snapshot.error}'));
                }
                final data = snapshot.data!;
                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: tema.colorScheme.primaryContainer,
                      child: ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: Text(
                          _filter == null
                              ? 'Total pengeluaran'
                              : 'Total $_filter',
                        ),
                        trailing: Text(
                          rupiah(data.total),
                          style: tema.textTheme.titleLarge,
                        ),
                      ),
                    ),
                    Expanded(
                      child: data.items.isEmpty
                          ? const Center(child: Text('Belum ada pengeluaran'))
                          : ListView.builder(
                              itemCount: data.items.length,
                              itemBuilder: (context, i) {
                                final x = data.items[i];
                                return ListTile(
                                  title: Text(x.nama),
                                  subtitle: Text(
                                    '${x.kategori} • ${x.tanggal}',
                                  ),
                                  leading: CircleAvatar(
                                    child: Text(x.kategori[0]),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(rupiah(x.jumlah)),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'Hapus',
                                        onPressed: () => _hapus(x),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _buka(x),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
