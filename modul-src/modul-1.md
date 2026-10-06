% Modul Praktikum Flutter Fundamental
%% Pertemuan 1: Pengenalan Flutter, Instalasi, dan Aplikasi Pertama

| Durasi | Level | Bahasa |
| 100–150 menit | Pemula | Dart |

## 1. Tujuan Pembelajaran

Setelah praktikum ini, mahasiswa mampu:
1. Menjelaskan apa itu Flutter dan Dart serta perbedaannya dengan pengembangan native.
2. Memasang Flutter SDK, editor, dan emulator/perangkat fisik.
3. Membuat dan menjalankan proyek Flutter pertama.
4. Memahami struktur folder proyek dan konsep dasar *widget*.
5. Memodifikasi UI sederhana dan menggunakan *hot reload*.

## 2. Alat dan Bahan
- Laptop (RAM minimal 8 GB, ruang disk minimal 10 GB)
- Flutter SDK versi stabil terbaru
- Android Studio atau VS Code (dengan ekstensi Flutter & Dart)
- Emulator Android atau HP Android (mode developer + USB debugging aktif)
- Koneksi internet

## 3. Teori Singkat

**Flutter** adalah *UI toolkit* dari Google untuk membangun aplikasi mobile, web, dan desktop dari satu basis kode. **Dart** adalah bahasa pemrogramannya.

**Konsep utama:**
- **Widget**: semua elemen di Flutter (teks, tombol, layout, bahkan aplikasi itu sendiri) adalah widget.
- **StatelessWidget**: widget yang tampilannya tidak berubah.
- **StatefulWidget**: widget yang tampilannya bisa berubah lewat `setState()`.
- **Hot Reload**: perubahan kode langsung tampil tanpa restart aplikasi.

## 4. Langkah Praktikum

### Bagian A: Instalasi dan Verifikasi
1. Unduh Flutter SDK dari situs resmi (docs.flutter.dev), ekstrak, lalu tambahkan folder `flutter/bin` ke *PATH*.
2. Pasang Android Studio dan Android SDK, lalu buat satu emulator lewat *Device Manager*.
3. Pasang ekstensi **Flutter** dan **Dart** di editor.
4. Buka terminal dan jalankan perintah di bawah.
5. Perbaiki semua tanda silang yang muncul (misalnya lisensi Android).

```
flutter doctor

flutter doctor --android-licenses
```

> **Checkpoint:** `flutter doctor` menampilkan centang hijau untuk Flutter, Android toolchain, dan editor. Tunjukkan ke asisten/dosen.

### Bagian B: Membuat Proyek Pertama

```
flutter create praktikum_1
cd praktikum_1
flutter run
```

Pilih emulator/perangkat saat diminta. Tunggu hingga aplikasi *counter* bawaan tampil.

> **Checkpoint:** aplikasi counter berjalan dan tombol + menambah angka.

### Bagian C: Mengenal Struktur Proyek

| Folder/File | Fungsi |
| `lib/main.dart` | Titik masuk aplikasi (kode utama) |
| `pubspec.yaml` | Konfigurasi proyek, dependensi, aset |
| `android/`, `ios/` | Kode platform native |
| `test/` | Berkas pengujian |

### Bagian D: Aplikasi "Hello Flutter"

Hapus seluruh isi `lib/main.dart`, lalu ganti dengan:

```
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 1',
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello Flutter')),
        body: const Center(
          child: Text(
            'Halo, nama saya [NAMA]!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
```

**Yang dipelajari:** `MaterialApp` → `Scaffold` → `AppBar` + `Center` → `Text`. Ini adalah *widget tree*.

Ganti `[NAMA]` dengan nama Anda, simpan, dan amati *hot reload*.

### Bagian E: Widget Layout Dasar

Ganti `body` dengan `Column`:

```
body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.flutter_dash, size: 80, color: Colors.blue),
      SizedBox(height: 16),
      Text('Halo, nama saya [NAMA]!', style: TextStyle(fontSize: 24)),
      Text('NIM: [NIM]'),
    ],
  ),
),
```

> **Checkpoint:** tampilan menampilkan ikon, nama, dan NIM tersusun vertikal di tengah layar.

### Bagian F: Widget Interaktif (StatefulWidget)

Tambahkan class berikut di bawah `MyApp`, lalu ubah `home:` menjadi `const CounterPage()`:

```
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Saya')),
      body: Center(
        child: Text('$_count', style: const TextStyle(fontSize: 48)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

> **Checkpoint:** angka bertambah saat tombol ditekan.

## 5. Latihan Mandiri
1. Ubah warna `AppBar` dan warna teks sesuai selera (`backgroundColor`, `color`).
2. Tambahkan tombol kedua (`Icons.remove`) untuk mengurangi angka.
3. Tambahkan tombol *reset* yang mengembalikan angka ke 0.
4. Cegah angka menjadi negatif.

## 6. Tugas

Buat aplikasi **"Kartu Perkenalan"** satu halaman yang menampilkan: foto/ikon, nama, NIM, jurusan, dan hobi menggunakan `Column`, `Text`, `Icon`, dan `SizedBox`. Kumpulkan berupa tangkapan layar aplikasi berjalan dan tautan repositori (atau berkas `main.dart`).

## 7. Rubrik Penilaian

| Komponen | Bobot |
| Instalasi berhasil (flutter doctor) | 20% |
| Checkpoint Bagian B–F selesai | 40% |
| Latihan mandiri | 20% |
| Tugas Kartu Perkenalan | 20% |

## 8. Pertanyaan Refleksi
1. Apa perbedaan `StatelessWidget` dan `StatefulWidget`?
2. Mengapa perubahan variabel `_count` perlu dibungkus `setState()`?
3. Apa keuntungan *hot reload* dibanding *rebuild* penuh?

## 9. Troubleshooting Umum

| Masalah | Solusi |
| `flutter` tidak dikenali | Periksa *PATH*, buka ulang terminal |
| Lisensi Android belum diterima | `flutter doctor --android-licenses` |
| Emulator lambat | Aktifkan virtualisasi (VT-x/AMD-V) di BIOS |
| Perangkat tidak terdeteksi | Aktifkan USB debugging, cek dengan `flutter devices` |
| `flutter test` gagal setelah `main.dart` diganti | Berkas `test/widget_test.dart` bawaan menguji aplikasi counter awal. Sesuaikan isinya dengan aplikasi Anda atau hapus berkas tersebut |

## 10. Referensi
- Dokumentasi resmi Flutter: docs.flutter.dev
- Dart Language Tour: dart.dev/language
- Widget catalog: docs.flutter.dev/ui/widgets
