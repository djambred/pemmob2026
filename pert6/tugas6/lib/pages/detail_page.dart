import 'package:flutter/material.dart';

import '../data/wisata.dart';
import 'beranda_page.dart';

/// Argumen rute '/detail': data wisata dan tag Hero dari tab asal.
class DetailArgs {
  final Wisata wisata;
  final String heroTag;
  const DetailArgs(this.wisata, this.heroTag);
}

class DetailPage extends StatefulWidget {
  static const rute = '/detail';

  final Wisata wisata;
  final String heroTag;
  const DetailPage({super.key, required this.wisata, required this.heroTag});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

/// Animasi eksplisit: lingkaran di belakang ikon berdenyut terus-menerus.
class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _denyut;
  late final Animation<double> _skala;

  @override
  void initState() {
    super.initState();
    _denyut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _skala = Tween(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _denyut, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _denyut.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;
    final w = widget.wisata;

    return Scaffold(
      appBar: AppBar(
        title: Text(w.nama),
        actions: [TombolFavorit(id: w.id)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ScaleTransition(
              scale: _skala,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: warna.secondaryContainer,
                ),
                child: Hero(
                  tag: widget.heroTag,
                  child: CircleAvatar(
                    radius: 64,
                    backgroundColor: warna.primaryContainer,
                    foregroundColor: warna.onPrimaryContainer,
                    child: Icon(w.ikon, size: 64),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            w.nama,
            style: tema.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.place, size: 18, color: warna.primary),
              const SizedBox(width: 4),
              Text(w.lokasi, style: tema.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          Text(w.deskripsi, style: tema.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
