import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Foto yang baru dipilih dan belum diunggah.
class FotoBaru {
  final Uint8List isi;
  final String nama;
  const FotoBaru(this.isi, this.nama);
}

/// Bagian form untuk memilih, melihat, dan menghapus foto bukti struk.
///
/// Prioritas tampilan: [baru] (dipilih dari HP) lalu [urlLama] (sudah ada
/// di server). Bila keduanya null, hanya tombol pilih foto yang tampil.
class BuktiStruk extends StatelessWidget {
  final FotoBaru? baru;
  final String? urlLama;
  final ValueChanged<FotoBaru> onPilih;
  final VoidCallback onHapus;

  const BuktiStruk({
    super.key,
    required this.baru,
    required this.urlLama,
    required this.onPilih,
    required this.onHapus,
  });

  Future<void> _ambil(BuildContext context, ImageSource sumber) async {
    try {
      // Diperkecil di HP agar unggahan cepat dan di bawah batas 2 MB server.
      final f = await ImagePicker().pickImage(
        source: sumber,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (f == null) return; // pengguna membatalkan
      onPilih(FotoBaru(await f.readAsBytes(), f.name));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka kamera/galeri')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget? gambar = baru != null
        ? Image.memory(baru!.isi, fit: BoxFit.cover)
        : urlLama != null
        ? Image.network(
            urlLama!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progres) => progres == null
                ? child
                : const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stack) =>
                const Center(child: Icon(Icons.broken_image, size: 48)),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (gambar != null) ...[
          GestureDetector(
            onTap: () => _lihatPenuh(context, gambar),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(height: 180, child: gambar),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _ambil(context, ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Kamera'),
            ),
            OutlinedButton.icon(
              onPressed: () => _ambil(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galeri'),
            ),
            if (gambar != null)
              TextButton.icon(
                onPressed: onHapus,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus foto'),
              ),
          ],
        ),
      ],
    );
  }

  void _lihatPenuh(BuildContext context, Widget gambar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Bukti struk'),
          ),
          // InteractiveViewer: foto dapat dicubit untuk diperbesar.
          body: InteractiveViewer(child: Center(child: gambar)),
        ),
      ),
    );
  }
}
