import 'package:flutter/material.dart';

import 'pages/post_list_page.dart';
import 'services/api_service.dart';

void main() => runApp(MyApp(api: ApiService()));

class MyApp extends StatelessWidget {
  final ApiService api;
  const MyApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Postingan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: PostListPage(api: api),
    );
  }
}
