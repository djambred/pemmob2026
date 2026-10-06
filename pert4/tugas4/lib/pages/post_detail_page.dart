import 'package:flutter/material.dart';

import '../models/komentar.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/status_widgets.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final ApiService api;

  const PostDetailPage({super.key, required this.post, required this.api});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // Future kedua: komentar diambil dari endpoint terpisah.
  late Future<List<Komentar>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.ambilKomentar(widget.post.id);
  }

  void _muatUlang() {
    setState(() {
      _future = widget.api.ambilKomentar(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Postingan #${widget.post.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.post.title, style: tema.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(widget.post.body, style: tema.textTheme.bodyLarge),
          const Divider(height: 32),
          Text('Komentar', style: tema.textTheme.titleMedium),
          FutureBuilder<List<Komentar>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MemuatView();
              }
              if (snapshot.hasError) {
                return GalatView(error: snapshot.error, onCobaLagi: _muatUlang);
              }
              final komentar = snapshot.data!;
              if (komentar.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada komentar'),
                );
              }
              return Column(
                children: [
                  for (final k in komentar)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.comment_outlined),
                      title: Text(k.name),
                      subtitle: Text('${k.email}\n${k.body}'),
                      isThreeLine: true,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
