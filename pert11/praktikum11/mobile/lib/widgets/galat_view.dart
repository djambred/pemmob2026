import 'package:flutter/material.dart';

import '../services/api_exception.dart';

/// Tampilan galat dengan tombol "Coba lagi" (pola dari pertemuan 4).
class GalatView extends StatelessWidget {
  final Object galat;
  final VoidCallback onCobaLagi;

  const GalatView({super.key, required this.galat, required this.onCobaLagi});

  @override
  Widget build(BuildContext context) {
    final e = galat;
    final pesan = e is ApiException
        ? e.pesan
        : 'Tidak dapat terhubung ke server.\nPeriksa koneksi dan alamat API.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              e is ApiException ? Icons.error_outline : Icons.cloud_off,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCobaLagi,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan pesan galat singkat di SnackBar.
void tampilkanGalat(BuildContext context, Object e) {
  final pesan = e is ApiException
      ? e.pesan
      : 'Tidak dapat terhubung ke server. Coba lagi nanti.';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(pesan)));
}
