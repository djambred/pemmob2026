import 'package:flutter/material.dart';

/// Tampilan galat dengan tombol coba lagi, dipakai di kedua halaman.
class GalatView extends StatelessWidget {
  final Object? error;
  final VoidCallback onCobaLagi;

  const GalatView({super.key, required this.error, required this.onCobaLagi});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text('Terjadi kesalahan:\n$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onCobaLagi,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class MemuatView extends StatelessWidget {
  const MemuatView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
