import 'package:flutter/material.dart';

import '../data/kegiatan_repository.dart';
import '../models/kegiatan.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';
import '../widgets/galat_view.dart';
import '../widgets/kegiatan_tile.dart';
import '../widgets/pengumuman_banner.dart';
import '../widgets/ringkasan_card.dart';

class DataHari {
  final List<Kegiatan> daftar;
  final Ringkasan ringkasan;
  const DataHari(this.daftar, this.ringkasan);
}

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late Future<DataHari> _future;

  @override
  void initState() {
    super.initState();
    _future = _ambil();
    versiData.addListener(_muat);
  }

  @override
  void dispose() {
    versiData.removeListener(_muat);
    super.dispose();
  }

  Future<DataHari> _ambil() async {
    final tanggal = fmtTanggal(DateTime.now());
    // Dua request dikirim bersamaan, bukan berurutan.
    final hasil = await Future.wait([
      repo.pada(tanggal),
      repo.ringkasan(tanggal),
    ]);
    return DataHari(hasil[0] as List<Kegiatan>, hasil[1] as Ringkasan);
  }

  void _muat() {
    setState(() {
      _future = _ambil();
    });
  }

  /// Untuk RefreshIndicator: indikator berputar sampai data baru tiba.
  Future<void> _tarikSegarkan() async {
    _muat();
    try {
      await _future;
    } catch (_) {
      // Galat sudah ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _jalankan(Future<void> Function() aksi) async {
    try {
      await aksi();
    } catch (e) {
      if (mounted) tampilkanGalat(context, e);
    }
  }

  Future<void> _hapus(Kegiatan k) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus kegiatan?'),
        content: Text('"${k.judul}" akan dihapus.'),
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
    if (ya == true) await _jalankan(() => repo.hapus(k.id!));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataHari>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return GalatView(galat: snapshot.error!, onCobaLagi: _muat);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _tarikSegarkan,
          child: ListView(
            // Agar tetap bisa ditarik walau isinya sedikit.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            children: [
              const PengumumanBanner(),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  tampilTanggal(DateTime.now()),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: targetHarian,
                builder: (context, target, _) {
                  return RingkasanCard(
                    judul: 'Ringkasan hari ini',
                    ringkasan: data.ringkasan,
                    target: target,
                  );
                },
              ),
              const SizedBox(height: 8),
              if (data.daftar.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Belum ada kegiatan hari ini.\nTekan tombol Kegiatan untuk menambah.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                for (final k in data.daftar)
                  KegiatanTile(
                    kegiatan: k,
                    onToggle: () =>
                        _jalankan(() => repo.setSelesai(k, !k.selesai)),
                    onEdit: () {
                      Navigator.pushNamed(context, '/form', arguments: k);
                    },
                    onHapus: () => _hapus(k),
                  ),
            ],
          ),
        );
      },
    );
  }
}
