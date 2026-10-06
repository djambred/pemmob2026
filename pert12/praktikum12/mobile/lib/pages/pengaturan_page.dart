import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../state/pengaturan.dart';
import '../state/sesi.dart';
import '../utils/format.dart';
import '../widgets/galat_view.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        themeMode,
        seedColor,
        targetHarian,
        apiUrl,
        pengguna,
      ]),
      builder: (context, _) {
        final akun = pengguna.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (akun != null)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(akun.nama.characters.first.toUpperCase()),
                  ),
                  title: Text(akun.nama),
                  subtitle: Text(akun.email),
                  trailing: TextButton.icon(
                    onPressed: () => _keluar(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('Target tabungan harian', style: tema.textTheme.titleMedium),
            Text(
              'Tersimpan di akun, sama di semua perangkat',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              rupiah(targetHarian.value),
              style: tema.textTheme.headlineSmall,
            ),
            Slider(
              value: targetHarian.value.toDouble(),
              min: 0,
              max: 100000,
              divisions: 20,
              label: rupiah(targetHarian.value),
              onChanged: (v) => targetHarian.value = v.round(),
              onChangeEnd: (v) async {
                try {
                  await simpanTarget(v.round());
                } catch (e) {
                  if (context.mounted) tampilkanGalat(context, e);
                }
              },
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: simpanGelap,
            ),
            const SizedBox(height: 8),
            Text('Warna tema', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (var i = 0; i < pilihanWarna.length; i++)
                  GestureDetector(
                    onTap: () => simpanWarna(i),
                    child: CircleAvatar(
                      backgroundColor: pilihanWarna[i],
                      child: seedColor.value == pilihanWarna[i]
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link),
              title: const Text('Alamat API'),
              subtitle: Text(apiUrl.value),
              trailing: const Icon(Icons.edit),
              onTap: () => _ubahApiUrl(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dns_outlined),
              title: const Text('Status server'),
              subtitle: const Text('Periksa koneksi ke backend TabungKu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/status'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _keluar(BuildContext context) async {
  final ya = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Keluar dari akun?'),
      content: const Text('Kamu perlu login lagi untuk melihat data.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Keluar'),
        ),
      ],
    ),
  );
  if (ya == true) await hapusSesi();
}

Future<void> _ubahApiUrl(BuildContext context) async {
  final baru = await showDialog<String>(
    context: context,
    builder: (_) => const _DialogApiUrl(),
  );
  if (baru != null) await simpanApiUrl(baru);
}

/// Dialog dengan controller sendiri agar controller di-dispose
/// setelah animasi penutupan dialog selesai.
class _DialogApiUrl extends StatefulWidget {
  const _DialogApiUrl();

  @override
  State<_DialogApiUrl> createState() => _DialogApiUrlState();
}

class _DialogApiUrlState extends State<_DialogApiUrl> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController(text: apiUrl.value);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alamat API'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'http://192.168.1.10:8000',
            helperText: 'Emulator Android: http://10.0.2.2:8000',
          ),
          validator: (v) {
            final uri = Uri.tryParse((v ?? '').trim());
            if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
              return 'Format: http://alamat:port';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, apiUrlBawaan),
          child: const Text('Bawaan'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _ctrl.text);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
