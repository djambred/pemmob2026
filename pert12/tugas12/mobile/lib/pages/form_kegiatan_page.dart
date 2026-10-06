import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/kegiatan_repository.dart';
import '../models/kategori.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';
import '../widgets/galat_view.dart';

/// Form tambah/ubah kegiatan. Bila [kegiatan] null berarti tambah baru.
class FormKegiatanPage extends StatefulWidget {
  final Kegiatan? kegiatan;
  const FormKegiatanPage({super.key, this.kegiatan});

  @override
  State<FormKegiatanPage> createState() => _FormKegiatanPageState();
}

class _FormKegiatanPageState extends State<FormKegiatanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _nominal;
  late DateTime _tanggal;
  late Tipe _tipe;
  Kategori? _kategori;
  String? _galatKategori;
  late Future<List<Kategori>> _daftarKategori;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    final k = widget.kegiatan;
    _judul = TextEditingController(text: k?.judul ?? '');
    _nominal = TextEditingController(
      text: (k != null && k.nominal > 0) ? '${k.nominal}' : '',
    );
    _tanggal = k != null ? DateTime.parse(k.tanggal) : DateTime.now();
    _tipe = k?.tipe ?? Tipe.tanpa;
    if (k?.kategoriId != null) _kategori = Kategori(k!.kategoriId!, k.kategori);
    // Daftar kategori diambil dari server (dikelola admin di Filament).
    _daftarKategori = repo.daftarKategori();
  }

  void _muatKategori() {
    setState(() {
      _daftarKategori = repo.daftarKategori();
    });
  }

  @override
  void dispose() {
    _judul.dispose();
    _nominal.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (dipilih != null && mounted) {
      setState(() => _tanggal = dipilih);
    }
  }

  Future<void> _simpan() async {
    final formValid = _formKey.currentState!.validate();
    final kategoriKosong = _tipe == Tipe.pengeluaran && _kategori == null;
    setState(() {
      _galatKategori = kategoriKosong ? 'Pilih kategori pengeluaran' : null;
    });
    if (!formValid || kategoriKosong) return;

    final adaUang = _tipe != Tipe.tanpa;
    final k = Kegiatan(
      id: widget.kegiatan?.id,
      judul: _judul.text.trim(),
      tanggal: fmtTanggal(_tanggal),
      selesai: widget.kegiatan?.selesai ?? false,
      tipe: _tipe,
      nominal: adaUang ? int.parse(_nominal.text.trim()) : 0,
      kategoriId: _tipe == Tipe.pengeluaran ? _kategori!.id : null,
      kategori: _tipe == Tipe.pengeluaran ? _kategori!.nama : '-',
    );

    setState(() => _menyimpan = true);
    try {
      if (widget.kegiatan == null) {
        await repo.tambah(k);
      } else {
        await repo.ubah(k);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // Form tetap terbuka agar isian tidak hilang.
      if (mounted) tampilkanGalat(context, e);
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.kegiatan == null;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(baru ? 'Kegiatan Baru' : 'Ubah Kegiatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(
                labelText: 'Nama kegiatan',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama kegiatan wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            // Material sendiri agar bingkai ListTile ikut bergeser saat
            // pesan error validasi di atasnya muncul.
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: tema.colorScheme.outline),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_month),
                title: Text(tampilTanggal(_tanggal)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pilihTanggal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Apakah kegiatan ini melibatkan uang?',
              style: tema.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<Tipe>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: Tipe.tanpa, label: Text('Tidak')),
                ButtonSegment(value: Tipe.pemasukan, label: Text('Pemasukan')),
                ButtonSegment(
                  value: Tipe.pengeluaran,
                  label: Text('Pengeluaran'),
                ),
              ],
              selected: {_tipe},
              onSelectionChanged: (s) => setState(() => _tipe = s.first),
            ),
            if (_tipe != Tipe.tanpa) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _nominal,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) {
                    return 'Isi nominal berupa angka lebih dari 0';
                  }
                  return null;
                },
              ),
            ],
            if (_tipe == Tipe.pengeluaran) ...[
              const SizedBox(height: 16),
              Text('Kategori pengeluaran', style: tema.textTheme.titleSmall),
              const SizedBox(height: 8),
              FutureBuilder<List<Kategori>>(
                future: _daftarKategori,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return TextButton.icon(
                      onPressed: _muatKategori,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Gagal memuat kategori. Coba lagi'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }
                  final daftar = [...snapshot.data!];
                  // Kategori lama yang sudah dinonaktifkan admin tetap
                  // ditampilkan agar kegiatan lama dapat disimpan ulang.
                  final dipilih = _kategori;
                  if (dipilih != null &&
                      !daftar.any((c) => c.id == dipilih.id)) {
                    daftar.add(dipilih);
                  }
                  return Wrap(
                    spacing: 8,
                    children: [
                      for (final c in daftar)
                        ChoiceChip(
                          label: Text(c.nama),
                          selected: _kategori?.id == c.id,
                          onSelected: (_) => setState(() {
                            _kategori = c;
                            _galatKategori = null;
                          }),
                        ),
                    ],
                  );
                },
              ),
              if (_galatKategori != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    _galatKategori!,
                    style: TextStyle(
                      color: tema.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _menyimpan ? null : _simpan,
              child: _menyimpan
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
