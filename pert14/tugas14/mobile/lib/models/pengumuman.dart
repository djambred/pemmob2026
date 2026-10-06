/// Pengumuman dari admin (GET /pengumuman).
class Pengumuman {
  final int id;
  final String judul;
  final String isi;

  const Pengumuman({required this.id, required this.judul, required this.isi});

  factory Pengumuman.fromJson(Map<String, dynamic> j) => Pengumuman(
    id: j['id'] as int,
    judul: j['judul'] as String,
    isi: j['isi'] as String,
  );
}
