import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/health_service.dart';

/// Memeriksa apakah backend (docker compose) dapat dihubungi dari HP.
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
          final ok = snapshot.hasData;
          final s = snapshot.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Icon(
                ok ? Icons.cloud_done : Icons.cloud_off,
                size: 72,
                color: ok ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                ok ? 'Server terhubung' : 'Server tidak dapat dihubungi',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Alamat API'),
                subtitle: const Text(apiUrl),
              ),
              if (s != null) ...[
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Waktu server'),
                  subtitle: Text(s.waktuServer),
                ),
                ListTile(
                  leading: const Icon(Icons.speed),
                  title: const Text('Latensi'),
                  subtitle: Text('${s.latensi.inMilliseconds} ms'),
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('Galat'),
                  subtitle: Text('${snapshot.error}'),
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
