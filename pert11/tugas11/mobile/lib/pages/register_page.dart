import 'package:flutter/material.dart';

import '../services/api_exception.dart';
import '../services/auth_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _ulangi = TextEditingController();
  bool _memuat = false;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _password.dispose();
    _ulangi.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _memuat = true);
    final api = AuthApi();
    try {
      await api.daftar(_nama.text.trim(), _email.text.trim(), _password.text);
      // Langsung login agar pengguna tidak perlu mengetik ulang.
      await api.masuk(_email.text.trim(), _password.text);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      _pesan(e.pesan);
    } catch (e) {
      _pesan('Tidak dapat terhubung ke server. Periksa alamat API.');
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Masukkan email yang valid'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'Minimal 8 karakter',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.length < 8)
                  ? 'Password minimal 8 karakter'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ulangi,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Ulangi password',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v != _password.text ? 'Password tidak sama' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _memuat ? null : _daftar,
              child: _memuat
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
