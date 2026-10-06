import 'package:flutter/material.dart';

import '../data/wisata.dart';
import '../state/pengaturan.dart';
import 'beranda_page.dart';

class FavoritPage extends StatelessWidget {
  const FavoritPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favorit,
      builder: (context, isi, _) {
        final daftar = daftarWisata.where((w) => isi.contains(w.id)).toList();
        if (daftar.isEmpty) {
          return Center(
            child: Text(
              'Belum ada favorit.\nTekan ikon hati di tab Beranda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: daftar.length,
          itemBuilder: (context, i) =>
              WisataTile(wisata: daftar[i], asal: 'favorit'),
        );
      },
    );
  }
}
