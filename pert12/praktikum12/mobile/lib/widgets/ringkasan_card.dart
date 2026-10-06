import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../utils/format.dart';

/// Kartu ringkasan: jumlah kegiatan, pemasukan, pengeluaran, tabungan,
/// dan (opsional) kemajuan menuju target tabungan.
class RingkasanCard extends StatelessWidget {
  final String judul;
  final Ringkasan ringkasan;
  final int? target;

  const RingkasanCard({
    super.key,
    required this.judul,
    required this.ringkasan,
    this.target,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final r = ringkasan;
    final t = target;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(judul, style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(
                  ikon: Icons.checklist,
                  label: 'Kegiatan',
                  nilai: '${r.selesai}/${r.jumlahKegiatan}',
                ),
                _Stat(
                  ikon: Icons.arrow_downward,
                  label: 'Pemasukan',
                  nilai: rupiah(r.pemasukan),
                  warna: Colors.green,
                ),
                _Stat(
                  ikon: Icons.arrow_upward,
                  label: 'Pengeluaran',
                  nilai: rupiah(r.pengeluaran),
                  warna: Colors.red,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tabungan'),
                Text(
                  rupiah(r.tabungan),
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: r.tabungan >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (t != null && t > 0) ...[
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: (r.tabungan / t).clamp(0.0, 1.0).toDouble(),
                ),
                duration: const Duration(milliseconds: 600),
                builder: (context, nilai, _) {
                  return LinearProgressIndicator(
                    value: nilai,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(_pesan(r.tabungan, t), style: tema.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

String _pesan(int tabungan, int target) {
  if (tabungan >= target) {
    return 'Target ${rupiah(target)} tercapai! '
        'Pertahankan kebiasaan menabungmu.';
  }
  if (tabungan < 0) {
    return 'Pengeluaran melebihi pemasukan. '
        'Coba tunda pengeluaran yang belum perlu.';
  }
  return 'Target ${rupiah(target)}: masih kurang '
      '${rupiah(target - tabungan)}.';
}

class _Stat extends StatelessWidget {
  final IconData ikon;
  final String label;
  final String nilai;
  final Color? warna;

  const _Stat({
    required this.ikon,
    required this.label,
    required this.nilai,
    this.warna,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(ikon, color: warna),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              nilai,
              style: tema.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: warna,
              ),
            ),
          ),
          Text(label, style: tema.textTheme.bodySmall),
        ],
      ),
    );
  }
}
