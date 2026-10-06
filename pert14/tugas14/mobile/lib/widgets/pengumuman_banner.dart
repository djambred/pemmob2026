import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pengumuman.dart';
import '../services/pengumuman_api.dart';

/// Kartu pengumuman dari admin di atas halaman Hari Ini.
/// Pengumuman yang ditutup pengguna diingat dengan shared_preferences.
class PengumumanBanner extends StatefulWidget {
  /// Dapat diganti di test agar tidak memanggil server.
  final Future<List<Pengumuman>> Function()? muat;

  const PengumumanBanner({super.key, this.muat});

  @override
  State<PengumumanBanner> createState() => _PengumumanBannerState();
}

class _PengumumanBannerState extends State<PengumumanBanner> {
  static const _kunci = 'pengumuman_ditutup';
  List<Pengumuman> _tampil = [];

  @override
  void initState() {
    super.initState();
    _ambil();
  }

  Future<void> _ambil() async {
    try {
      final semua = await (widget.muat ?? PengumumanApi().daftar)();
      final prefs = await SharedPreferences.getInstance();
      final ditutup = prefs.getStringList(_kunci) ?? [];
      if (!mounted) return;
      setState(() {
        _tampil = semua.where((p) => !ditutup.contains('${p.id}')).toList();
      });
    } catch (_) {
      // Pengumuman bukan fitur utama: bila gagal, cukup tidak ditampilkan.
    }
  }

  Future<void> _tutup(Pengumuman p) async {
    setState(() => _tampil.remove(p));
    final prefs = await SharedPreferences.getInstance();
    final ditutup = prefs.getStringList(_kunci) ?? [];
    await prefs.setStringList(_kunci, [...ditutup, '${p.id}']);
  }

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final p in _tampil)
          Card(
            color: skema.secondaryContainer,
            child: ListTile(
              leading: Icon(Icons.campaign, color: skema.onSecondaryContainer),
              title: Text(
                p.judul,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(p.isi),
              trailing: IconButton(
                tooltip: 'Tutup',
                icon: const Icon(Icons.close),
                onPressed: () => _tutup(p),
              ),
            ),
          ),
      ],
    );
  }
}
