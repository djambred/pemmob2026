/// Data akun yang sedang login (hasil GET /users/me).
class Pengguna {
  final int id;
  final String nama;
  final String email;
  final int targetHarian;

  const Pengguna({
    required this.id,
    required this.nama,
    required this.email,
    required this.targetHarian,
  });

  factory Pengguna.fromJson(Map<String, dynamic> j) => Pengguna(
    id: j['id'] as int,
    nama: j['nama'] as String,
    email: j['email'] as String,
    targetHarian: j['target_harian'] as int,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'nama': nama,
    'email': email,
    'target_harian': targetHarian,
  };
}
