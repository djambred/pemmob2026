class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  /// Potongan isi untuk ditampilkan di daftar.
  String get potongan {
    final satuBaris = body.replaceAll('\n', ' ');
    return satuBaris.length <= 80
        ? satuBaris
        : '${satuBaris.substring(0, 80)}...';
  }
}
