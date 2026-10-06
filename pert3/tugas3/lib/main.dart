import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const daftarKategori = [
  'Makanan',
  'Minuman',
  'Kebersihan',
  'Alat Tulis',
  'Lainnya',
];

class Barang {
  final String nama;
  final int jumlah;
  final String kategori;
  bool dibeli;

  Barang(this.nama, this.jumlah, this.kategori, {this.dibeli = false});
}

class BelanjaModel extends ChangeNotifier {
  final List<Barang> _items = [];

  List<Barang> get items => List.unmodifiable(_items);
  int get jumlahBelumDibeli => _items.where((b) => !b.dibeli).length;

  void tambah(Barang barang) {
    _items.add(barang);
    notifyListeners();
  }

  void toggle(int index) {
    _items[index].dibeli = !_items[index].dibeli;
    notifyListeners();
  }

  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => BelanjaModel(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Belanja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const DaftarPage(),
    );
  }
}

class DaftarPage extends StatelessWidget {
  const DaftarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BelanjaModel>();

    return Scaffold(
      appBar: AppBar(title: Text('Belum dibeli: ${model.jumlahBelumDibeli}')),
      body: model.items.isEmpty
          ? const Center(child: Text('Daftar belanja masih kosong'))
          : ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, i) {
                final b = model.items[i];
                return ListTile(
                  leading: Checkbox(
                    value: b.dibeli,
                    onChanged: (_) => context.read<BelanjaModel>().toggle(i),
                  ),
                  title: Text(
                    b.nama,
                    style: TextStyle(
                      decoration: b.dibeli ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('${b.jumlah} buah • ${b.kategori}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Hapus',
                    onPressed: () => context.read<BelanjaModel>().hapus(i),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormTambahPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormTambahPage extends StatefulWidget {
  const FormTambahPage({super.key});

  @override
  State<FormTambahPage> createState() => _FormTambahPageState();
}

class _FormTambahPageState extends State<FormTambahPage> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _jumlah = TextEditingController();
  String? _kategori;

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BelanjaModel>().tambah(
      Barang(_nama.text.trim(), int.parse(_jumlah.text.trim()), _kategori!),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Barang ditambahkan')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama barang',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama barang wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Jumlah wajib diisi';
                final n = int.tryParse(v.trim());
                if (n == null) return 'Jumlah harus berupa angka';
                if (n <= 0) return 'Jumlah harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final k in daftarKategori)
                  DropdownMenuItem(value: k, child: Text(k)),
              ],
              onChanged: (v) => setState(() => _kategori = v),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
