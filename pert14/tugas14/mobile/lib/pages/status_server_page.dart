import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/health_service.dart';

/// Memeriksa apakah backend (docker compose) dan database dapat dihubungi.
class StatusServerPage extends StatefulWidget {
  const StatusServerPage({super.key});

  @override
  State<StatusServerPage> createState() => _StatusServerPageState();
}

class _StatusServerPageState extends State<StatusServerPage> {
  late Future<StatusServer> _future;

  @override
  void initState() {
    super.initState();
    _future = cekServer();
  }

  void _ulangi() {
    setState(() {
      _future = cekServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Server')),
      body: FutureBuilder<StatusServer>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = snapshot.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BarisStatus(
                label: 'API (FastAPI)',
                ok: s?.apiOk ?? false,
                keterangan: s != null
                    ? 'Latensi ${s.latensi.inMilliseconds} ms'
                    : '${snapshot.error}',
              ),
              _BarisStatus(
                label: 'Database (MySQL)',
                ok: s?.databaseOk ?? false,
                keterangan: s == null
                    ? 'Tidak diketahui karena API tidak terhubung'
                    : s.databaseOk
                    ? 'MySQL ${s.versiMysql}'
                    : s.detail ?? 'Database tidak dapat dihubungi',
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Alamat API'),
                subtitle: Text(apiUrl.value),
              ),
              if (s != null)
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Waktu server'),
                  subtitle: Text(s.waktuServer),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _ulangi,
                icon: const Icon(Icons.refresh),
                label: const Text('Periksa lagi'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BarisStatus extends StatelessWidget {
  final String label;
  final bool ok;
  final String keterangan;

  const _BarisStatus({
    required this.label,
    required this.ok,
    required this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          ok ? Icons.check_circle : Icons.cancel,
          color: ok ? Colors.green : Colors.red,
          size: 32,
        ),
        title: Text(label),
        subtitle: Text(keterangan),
      ),
    );
  }
}
