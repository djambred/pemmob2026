import 'package:flutter/foundation.dart';

/// Alamat bawaan backend TabungKu.
///
/// `10.0.2.2` adalah alamat khusus emulator Android untuk menuju
/// `localhost` milik laptop. Nilai ini bisa diganti saat menjalankan:
///   flutter run --dart-define=API_URL=http://192.168.1.10:8000
const apiUrlBawaan = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

/// Alamat yang sedang dipakai. Dapat diubah dari halaman Pengaturan dan
/// disimpan dengan shared_preferences (lihat state/pengaturan.dart).
final apiUrl = ValueNotifier<String>(apiUrlBawaan);

/// Batas waktu tunggu setiap permintaan ke server.
const batasWaktu = Duration(seconds: 10);

/// Sumber data kegiatan: 'api' (bawaan) atau 'lokal' (SQLite seperti
/// pertemuan 7). Contoh: flutter run --dart-define=MODE_DATA=lokal
const modeData = String.fromEnvironment('MODE_DATA', defaultValue: 'api');
