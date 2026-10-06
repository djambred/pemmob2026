import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

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
  late String _kategori;

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
    _kategori = (k != null && kategoriPengeluaran.contains(k.kategori))
        ? k.kategori
        : kategoriPengeluaran.first;
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
    if (!_formKey.currentState!.validate()) return;

    final adaUang = _tipe != Tipe.tanpa;
    final k = Kegiatan(
      id: widget.kegiatan?.id,
      judul: _judul.text.trim(),
      tanggal: fmtTanggal(_tanggal),
      selesai: widget.kegiatan?.selesai ?? false,
      tipe: _tipe,
      nominal: adaUang ? int.parse(_nominal.text.trim()) : 0,
      kategori: _tipe == Tipe.pengeluaran ? _kategori : '-',
    );

    if (widget.kegiatan == null) {
      await DbHelper.tambah(k);
    } else {
      await DbHelper.ubah(k);
    }
    if (!mounted) return;
    Navigator.pop(context);
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
              Wrap(
                spacing: 8,
                children: [
                  for (final c in kategoriPengeluaran)
                    ChoiceChip(
                      label: Text(c),
                      selected: _kategori == c,
                      onSelected: (_) => setState(() => _kategori = c),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
