import 'package:flutter/material.dart';

import '../data/kegiatan_repository.dart';
import '../models/kegiatan.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';
import '../widgets/galat_view.dart';
import '../widgets/ringkasan_card.dart';

class DataLaporan {
  final Ringkasan hari;
  final Map<String, int> perKategori;
  final List<MapEntry<DateTime, Ringkasan>> tujuhHari;
  final LaporanBulanan bulanan;
  const DataLaporan(this.hari, this.perKategori, this.tujuhHari, this.bulanan);
}

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime _tanggal = DateTime.now();
  late Future<DataLaporan> _future;

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

  Future<DataLaporan> _ambil() async {
    final basis = _tanggal;
    final awal = DateTime(basis.year, basis.month, basis.day - 6);
    // Laporan harian dan 7 hari terakhir diambil bersamaan.
    final hasil = await Future.wait([
      repo.laporanHarian(fmtTanggal(basis)),
      repo.rentang(awal, basis),
      repo.laporanBulanan(basis.year, basis.month),
    ]);
    final harian = hasil[0] as LaporanHarian;
    final rentang = hasil[1] as List<MapEntry<DateTime, Ringkasan>>;
    // Terbaru di atas, sama seperti pertemuan 7.
    return DataLaporan(
      harian.ringkasan,
      harian.perKategori,
      rentang.reversed.toList(),
      hasil[2] as LaporanBulanan,
    );
  }

  void _ganti(DateTime baru) {
    setState(() {
      _tanggal = baru;
      _future = _ambil();
    });
  }

  void _muat() => _ganti(_tanggal);

  void _geser(int hari) {
    _ganti(DateTime(_tanggal.year, _tanggal.month, _tanggal.day + hari));
  }

  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (dipilih != null && mounted) _ganti(dipilih);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return FutureBuilder<DataLaporan>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return GalatView(galat: snapshot.error!, onCobaLagi: _muat);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final d = snapshot.data!;
        final total7 = d.tujuhHari.fold<int>(0, (s, e) => s + e.value.tabungan);

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _geser(-1),
                ),
                TextButton.icon(
                  onPressed: _pilihTanggal,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(tampilTanggal(_tanggal)),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _geser(1),
                ),
              ],
            ),
            ValueListenableBuilder<int>(
              valueListenable: targetHarian,
              builder: (context, target, _) {
                return RingkasanCard(
                  judul: 'Ringkasan harian',
                  ringkasan: d.hari,
                  target: target,
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Pengeluaran per kategori', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (d.perKategori.isEmpty)
              const Text('Tidak ada pengeluaran pada tanggal ini.')
            else
              for (final e in d.perKategori.entries)
                _BarisKategori(
                  nama: e.key,
                  total: e.value,
                  semua: d.hari.pengeluaran,
                ),
            const SizedBox(height: 16),
            Text('7 hari terakhir', style: tema.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Total tabungan 7 hari: ${rupiah(total7)}',
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: total7 >= 0 ? Colors.green : Colors.red,
              ),
            ),
            for (final e in d.tujuhHari)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(tampilTanggal(e.key)),
                subtitle: Text(
                  '${e.value.jumlahKegiatan} kegiatan | '
                  'masuk ${rupiah(e.value.pemasukan)} | '
                  'keluar ${rupiah(e.value.pengeluaran)}',
                ),
                trailing: Text(
                  rupiah(e.value.tabungan),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: e.value.tabungan >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _KartuBulanan(b: d.bulanan),
          ],
        );
      },
    );
  }
}

class _BarisKategori extends StatelessWidget {
  final String nama;
  final int total;
  final int semua;

  const _BarisKategori({
    required this.nama,
    required this.total,
    required this.semua,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(nama), Text(rupiah(total))],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: semua == 0 ? 0.0 : total / semua,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}

/// Ringkasan satu bulan (GET /laporan/bulanan).
class _KartuBulanan extends StatelessWidget {
  final LaporanBulanan b;

  const _KartuBulanan({required this.b});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final r = b.ringkasan;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bulan ${namaBulan(b.bulan)} ${b.tahun}',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _Baris('Kegiatan', '${r.jumlahKegiatan}'),
            _Baris('Pemasukan', rupiah(r.pemasukan), Colors.green),
            _Baris('Pengeluaran', rupiah(r.pengeluaran), Colors.red),
            _Baris(
              'Tabungan',
              rupiah(r.tabungan),
              r.tabungan >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(),
            Text(
              'Target harian tercapai ${b.hariTargetTercapai} '
              'dari ${b.jumlahHari} hari',
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: b.hariTargetTercapai / b.jumlahHari,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _Baris extends StatelessWidget {
  final String label;
  final String nilai;
  final Color? warna;

  const _Baris(this.label, this.nilai, [this.warna]);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            nilai,
            style: TextStyle(fontWeight: FontWeight.bold, color: warna),
          ),
        ],
      ),
    );
  }
}
