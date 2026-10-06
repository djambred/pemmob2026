import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../utils/format.dart';

/// Satu baris kegiatan: centang selesai, judul, nominal, tombol hapus.
class KegiatanTile extends StatelessWidget {
  final Kegiatan kegiatan;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const KegiatanTile({
    super.key,
    required this.kegiatan,
    required this.onToggle,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final k = kegiatan;
    final masuk = k.tipe == Tipe.pemasukan;

    return ListTile(
      leading: Checkbox(value: k.selesai, onChanged: (_) => onToggle()),
      title: Text(
        k.judul,
        style: TextStyle(
          decoration: k.selesai ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: k.tipe == Tipe.pengeluaran ? Text(k.kategori) : null,
      onTap: onEdit,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (k.tipe != Tipe.tanpa)
            Text(
              '${masuk ? '+' : '-'}${rupiah(k.nominal)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: masuk ? Colors.green : Colors.red,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onHapus,
          ),
        ],
      ),
    );
  }
}
