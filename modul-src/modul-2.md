% Modul Praktikum Flutter Fundamental
%% Pertemuan 2: Layout, ListView, dan Navigasi Antar Halaman

| Durasi | Level | Prasyarat |
| 100–150 menit | Pemula | Menyelesaikan Pertemuan 1 (instalasi, widget dasar, StatefulWidget) |

## 1. Tujuan Pembelajaran

Setelah praktikum ini, mahasiswa mampu:
1. Menyusun layout dengan `Container`, `Padding`, `Row`, `Column`, dan `Expanded`.
2. Menampilkan daftar data dengan `ListView.builder`, `Card`, dan `ListTile`.
3. Memodelkan data sederhana dengan class Dart.
4. Berpindah halaman dan mengirim data memakai `Navigator.push` dan `Navigator.pop`.

## 2. Alat dan Bahan
- Flutter SDK, editor (VS Code/Android Studio), dan emulator/perangkat dari Pertemuan 1
- Proyek baru: `flutter create praktikum_2`

## 3. Teori Singkat

| Widget | Fungsi |
| Container | Kotak serbaguna: ukuran, warna, border, radius, padding, margin |
| Padding | Memberi jarak di sekeliling widget anak |
| Row / Column | Menyusun anak secara horizontal / vertikal |
| Expanded | Membuat anak mengisi sisa ruang pada Row/Column |
| ListView.builder | Daftar yang di-render sesuai kebutuhan (efisien untuk data banyak) |
| Card + ListTile | Kartu berisi baris standar: ikon, judul, subjudul, ikon akhir |
| Navigator | Mengelola tumpukan (stack) halaman: push menambah, pop menutup |

**Sumbu layout:** pada `Row`, *main axis* adalah horizontal dan *cross axis* vertikal. Pada `Column` sebaliknya. Properti `mainAxisAlignment` dan `crossAxisAlignment` mengatur perataan pada masing-masing sumbu.

## 4. Langkah Praktikum

### Bagian A: Layout Kartu Profil

Ganti seluruh isi `lib/main.dart` dengan kode berikut, lalu ganti `[NAMA]` dan `[NIM]`.

```
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                child: Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('[NAMA]',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('[NIM]'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> **Checkpoint:** kartu profil tampil dengan avatar di kiri dan teks di kanan. Coba hapus `Expanded` dan panjangkan nama untuk melihat perbedaannya.

### Bagian B: Model Data dan ListView

Buat proyek/halaman baru untuk aplikasi **Daftar Menu**. Pertama, tentukan model data dan daftar isinya di `main.dart` (di bawah `import`):

```
class Makanan {
  final String nama;
  final int harga;
  const Makanan(this.nama, this.harga);
}

const daftarMenu = [
  Makanan('Nasi Goreng', 15000),
  Makanan('Mie Ayam', 12000),
  Makanan('Es Teh', 4000),
  Makanan('Ayam Bakar', 20000),
];
```

Lalu tampilkan dengan `ListView.builder`, `Card`, dan `ListTile`:

```
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(item.nama),
              subtitle: Text('Rp ${item.harga}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
```

Ubah `home:` pada `MyApp` menjadi `const MenuPage()`.

> **Checkpoint:** empat menu tampil sebagai kartu yang dapat di-scroll.

### Bagian C: Navigasi ke Halaman Detail

Tambahkan properti `onTap` pada `ListTile` (setelah `trailing`):

```
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => DetailPage(makanan: item)),
  );
},
```

Lalu buat halaman detail yang menerima data lewat constructor:

```
class DetailPage extends StatelessWidget {
  final Makanan makanan;
  const DetailPage({super.key, required this.makanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(makanan.nama)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 80),
            const SizedBox(height: 16),
            Text(makanan.nama, style: const TextStyle(fontSize: 24)),
            Text('Rp ${makanan.harga}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
```

> **Checkpoint:** mengetuk sebuah menu membuka halaman detail dengan data yang sesuai, dan tombol Kembali (atau tombol back) menutupnya.

## 5. Latihan Mandiri
1. Tambahkan 3 menu baru ke `daftarMenu` dan pastikan daftar tetap dapat di-scroll.
2. Tambahkan properti `deskripsi` pada class `Makanan` dan tampilkan di `DetailPage`.
3. Ganti `Card` dengan `Container` yang memiliki warna latar dan sudut membulat.
4. Tampilkan harga dengan format ribuan (misalnya 15.000) menggunakan fungsi buatan sendiri.

> **Catatan Latihan 3:** `ListTile` menggambar efek sentuh pada `Material` terdekat. Bila `ListTile` diletakkan langsung di dalam `Container` berwarna, Flutter (versi 3.x terbaru) memunculkan pesan *"ListTile background color or ink splashes may be invisible"* di mode debug dan efek sentuhnya tertutup warna. Bungkus `ListTile` dengan `Material(type: MaterialType.transparency, child: ListTile(...))`.

## 6. Tugas

Buat aplikasi **Daftar Kontak** dengan ketentuan:
- Minimal 6 kontak (nama, nomor telepon, email) yang disimpan dalam list berisi objek class.
- Halaman utama menampilkan daftar kontak dengan `ListView.builder` dan `ListTile` (avatar berisi huruf pertama nama).
- Mengetuk kontak membuka halaman detail yang menampilkan seluruh data kontak dan tombol kembali.
- Kumpulkan: tangkapan layar kedua halaman dan berkas `main.dart` (atau tautan repositori).

## 7. Rubrik Penilaian

| Komponen | Bobot |
| Bagian A–C berjalan (checkpoint) | 40% |
| Latihan mandiri | 20% |
| Tugas Daftar Kontak (fungsi dan kelengkapan) | 30% |
| Kerapian kode dan penamaan | 10% |

## 8. Pertanyaan Refleksi
1. Apa perbedaan `ListView` biasa dengan `ListView.builder`?
2. Mengapa `Row` yang berisi teks panjang dapat menyebabkan *overflow*, dan bagaimana `Expanded` membantu?
3. Bagaimana data dikirim dari halaman daftar ke halaman detail pada praktikum ini?

## 9. Troubleshooting Umum

| Masalah | Solusi |
| Garis kuning-hitam (overflow) di layar | Bungkus widget dengan `Expanded` atau `SingleChildScrollView` |
| Error: ListView tanpa tinggi dalam Column | Bungkus `ListView` dengan `Expanded` |
| Navigator error: context tidak memiliki Navigator | Pastikan halaman berada di bawah `MaterialApp` |
| Perubahan tidak muncul | Gunakan hot restart (Shift+R di terminal) bila mengubah `main()` atau data `const` |

## 10. Referensi
- Layout di Flutter: docs.flutter.dev/ui/layout
- Membuat daftar: docs.flutter.dev/cookbook/lists
- Navigasi: docs.flutter.dev/cookbook/navigation
