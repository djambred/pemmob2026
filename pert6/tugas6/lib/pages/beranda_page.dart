import 'package:flutter/material.dart';

import '../data/wisata.dart';
import '../state/pengaturan.dart';
import 'detail_page.dart';

/// Kartu wisata yang dipakai di tab Beranda dan Favorit.
class WisataTile extends StatelessWidget {
  final Wisata wisata;

  /// Nama tab asal. Beranda dan Favorit hidup bersamaan di IndexedStack,
  /// jadi tag Hero harus berbeda per tab agar tidak bentrok.
  final String asal;

  const WisataTile({super.key, required this.wisata, required this.asal});

  String get heroTag => '$asal-${wisata.id}';

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Hero(
          tag: heroTag,
          child: CircleAvatar(
            backgroundColor: warna.primaryContainer,
            foregroundColor: warna.onPrimaryContainer,
            child: Icon(wisata.ikon),
          ),
        ),
        title: Text(wisata.nama),
        subtitle: Text(wisata.lokasi),
        trailing: TombolFavorit(id: wisata.id),
        onTap: () => Navigator.pushNamed(
          context,
          DetailPage.rute,
          arguments: DetailArgs(wisata, heroTag),
        ),
      ),
    );
  }
}

/// Animasi implisit: ikon membesar sejenak dan berganti saat ditekan.
class TombolFavorit extends StatelessWidget {
  final String id;
  const TombolFavorit({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favorit,
      builder: (context, isi, _) {
        final aktif = isi.contains(id);
        return IconButton(
          tooltip: aktif ? 'Hapus dari favorit' : 'Tambah ke favorit',
          onPressed: () => toggleFavorit(id),
          icon: AnimatedScale(
            scale: aktif ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                aktif ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(aktif),
                color: aktif ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: daftarWisata.length,
      itemBuilder: (context, i) =>
          WisataTile(wisata: daftarWisata[i], asal: 'beranda'),
    );
  }
}
