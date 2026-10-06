/// Alamat backend TabungKu.
///
/// Bawaan `10.0.2.2` adalah alamat khusus emulator Android untuk menuju
/// `localhost` milik laptop. Untuk HP fisik atau simulator iOS, ganti saat
/// menjalankan aplikasi, misalnya:
///   flutter run --dart-define=API_URL=http://192.168.1.10:8000
const apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

/// Batas waktu tunggu setiap permintaan ke server.
const batasWaktu = Duration(seconds: 10);
