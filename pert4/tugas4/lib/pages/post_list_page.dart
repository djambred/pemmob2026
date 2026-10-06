import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/status_widgets.dart';
import 'post_detail_page.dart';

class PostListPage extends StatefulWidget {
  final ApiService api;
  const PostListPage({super.key, required this.api});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.ambilPosts();
  }

  void _muatUlang() {
    setState(() {
      _future = widget.api.ambilPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MemuatView();
          }
          if (snapshot.hasError) {
            return GalatView(error: snapshot.error, onCobaLagi: _muatUlang);
          }
          final posts = snapshot.data!;
          if (posts.isEmpty) {
            return const Center(child: Text('Tidak ada postingan'));
          }
          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final post = posts[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${post.id}')),
                title: Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(post.potongan, maxLines: 2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PostDetailPage(post: post, api: widget.api),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
