import 'package:flutter/material.dart';

import '../services/api_exception.dart';
import '../services/auth_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _sembunyi = true;
  bool _memuat = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _memuat = true);
    try {
      // Bila berhasil, sesi tersimpan dan MyApp otomatis pindah ke ShellPage.
      await AuthApi().masuk(_email.text.trim(), _password.text);
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
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.savings,
                    size: 72,
                    color: tema.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TabungKu',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.headlineMedium,
                  ),
                  const Text(
                    'Masuk untuk menyinkronkan catatanmu',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Masukkan email yang valid'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _sembunyi,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _sembunyi ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _sembunyi = !_sembunyi),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Password wajib diisi'
                        : null,
                    onFieldSubmitted: (_) => _masuk(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _memuat ? null : _masuk,
                    child: _memuat
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Masuk'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/daftar'),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/status'),
                    icon: const Icon(Icons.dns_outlined, size: 18),
                    label: const Text('Status server'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
