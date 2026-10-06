% Modul Praktikum Flutter Fundamental
%% Pertemuan 6: Tema, Routing dan Navigasi, serta Animasi

| Durasi | Level | Prasyarat |
| 150 menit | Menengah | Pertemuan 1–5 (widget, state, form, async, penyimpanan lokal) |

## 1. Tujuan Pembelajaran

Setelah praktikum ini, mahasiswa mampu:
1. Membuat tema terang/gelap dan warna tema yang dapat diganti pengguna dengan `ThemeData` dan `ThemeMode`.
2. Memakai nilai tema (`Theme.of(context)`) alih-alih warna dan gaya yang ditulis manual.
3. Menerapkan *named routes*, mengirim argumen antar halaman, dan `onGenerateRoute`.
4. Membuat navigasi tab bawah dengan `NavigationBar` dan `IndexedStack`.
5. Membuat animasi implisit (`AnimatedContainer`, `AnimatedSwitcher`), transisi `Hero`, dan animasi eksplisit (`AnimationController`).

## 2. Alat dan Bahan
- Flutter SDK, editor, dan emulator/perangkat dari pertemuan sebelumnya
- Proyek baru: `flutter create praktikum_6` (tidak perlu paket tambahan)

## 3. Teori Singkat

**Tema.** `ThemeData` menyimpan seluruh gaya aplikasi (warna, tipografi, gaya komponen). Cukup menentukan satu *seed color*, Material 3 menghasilkan seluruh palet warnanya. `MaterialApp` menerima `theme` (terang), `darkTheme` (gelap), dan `themeMode` (sistem/terang/gelap). Widget membaca tema dengan `Theme.of(context)`, sehingga otomatis menyesuaikan saat tema berubah.

**Routing.** Selain `Navigator.push` langsung, halaman dapat diberi nama sehingga navigasi lebih rapi dan terpusat.

| Method | Fungsi |
| `pushNamed(ctx, '/detail',` `arguments: x)` | Membuka halaman bernama, membawa argumen |
| `pop(ctx)` | Menutup halaman saat ini |
| `pushReplacementNamed(...)` | Mengganti halaman saat ini (tidak bisa kembali), misalnya dari login ke beranda |
| `pushNamedAndRemoveUntil(...)` | Membuka halaman baru sambil menghapus riwayat sebelumnya |

> Untuk aplikasi besar dengan *deep link* dan web, biasanya dipakai paket `go_router`. Prinsip named routes di pertemuan ini menjadi dasarnya.

**Animasi.**

| Jenis | Widget/kelas | Kapan dipakai |
| Implisit | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher` | Cukup ubah nilai lewat `setState`; Flutter menganimasikan perubahannya |
| Transisi Hero | `Hero` | Elemen "terbang" mulus antar dua halaman (tag harus sama) |
| Eksplisit | `AnimationController` + `RotationTransition` dll. | Butuh kontrol penuh: ulang, berhenti, urutan, sinkronisasi |

## 4. Langkah Praktikum

### Bagian A: Tema Terang/Gelap dan Warna Tema

Ganti seluruh isi `lib/main.dart`. Dua `ValueNotifier` global menyimpan pilihan tema; `ListenableBuilder` membangun ulang `MaterialApp` saat salah satunya berubah.

```
import 'package:flutter/material.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Praktikum 6',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          home: Scaffold(
            appBar: AppBar(title: const Text('Tema')),
            body: const PengaturanTab(),
          ),
        );
      },
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Warna tema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () => seedColor.value = c,
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: seedColor.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
```

> **Checkpoint:** saklar mode gelap dan pilihan warna langsung mengubah tampilan AppBar dan seluruh aplikasi tanpa restart. Perhatikan: tidak ada warna yang ditulis manual pada widget; semuanya berasal dari tema.

### Bagian B: Named Routes, Argumen, dan Hero

Tambahkan model data dan halaman di bawah `PengaturanTab`:

```
class Item {
  final String nama;
  final IconData ikon;
  final Color warna;
  const Item(this.nama, this.ikon, this.warna);
}

const daftarItem = [
  Item('Flutter', Icons.flutter_dash, Colors.blue),
  Item('Musik', Icons.music_note, Colors.pink),
  Item('Kamera', Icons.camera_alt, Colors.orange),
  Item('Peta', Icons.map, Colors.green),
];

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: daftarItem.length,
      itemBuilder: (context, i) {
        final item = daftarItem[i];
        return ListTile(
          leading: Hero(
            tag: 'ikon-${item.nama}',
            child: CircleAvatar(
              backgroundColor: item.warna,
              child: Icon(item.ikon, color: Colors.white),
            ),
          ),
          title: Text(item.nama),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/detail', arguments: item);
          },
        );
      },
    );
  }
}

class DetailPage extends StatelessWidget {
  final Item item;
  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(item.nama)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'ikon-${item.nama}',
              child: CircleAvatar(
                radius: 64,
                backgroundColor: item.warna,
                child: Icon(item.ikon, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.nama, style: tema.textTheme.headlineMedium),
            Text('Detail untuk ${item.nama}', style: tema.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
```

Lalu pada `MyApp`, **ganti** baris `home:` (Scaffold Tema) dengan daftar rute berikut. Rute `'/'` didaftarkan di `routes`; rute yang membawa argumen ditangani `onGenerateRoute`:

```
initialRoute: '/',
routes: {
  '/': (_) => Scaffold(
        appBar: AppBar(title: const Text('Beranda')),
        body: const BerandaTab(),
      ),
},
onGenerateRoute: (settings) {
  if (settings.name == '/detail') {
    final item = settings.arguments as Item;
    return MaterialPageRoute(
      builder: (_) => DetailPage(item: item),
      settings: settings,
    );
  }
  return null;
},
```

> *Alternatif:* argumen juga dapat dibaca di halaman tujuan dengan `ModalRoute.of(context)!.settings.arguments`. Cara `onGenerateRoute` di atas lebih aman karena tipe datanya dicek di satu tempat.

> **Checkpoint:** mengetuk item membuka halaman detail; ikon **terbang** dan membesar dari daftar ke halaman detail (Hero), dan sebaliknya saat kembali. Bila memakai mode gelap, warna teks/AppBar ikut menyesuaikan. (Halaman Pengaturan sementara belum dapat diakses; ia akan kembali di Bagian D.)

### Bagian C: Animasi

Tambahkan halaman `AnimasiTab` yang berisi tiga demo: animasi implisit, `AnimatedSwitcher`, dan animasi eksplisit. Karena `AnimationController` membutuhkan `vsync`, state class memakai `SingleTickerProviderStateMixin`.

```
class AnimasiTab extends StatefulWidget {
  const AnimasiTab({super.key});

  @override
  State<AnimasiTab> createState() => _AnimasiTabState();
}

class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  bool _besar = false;
  int _hitung = 0;
  late final AnimationController _putar;

  @override
  void initState() {
    super.initState();
    _putar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _putar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('1. AnimatedContainer', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _besar ? 200 : 100,
            height: 100,
            decoration: BoxDecoration(
              color: _besar ? warna.primary : warna.tertiary,
              borderRadius: BorderRadius.circular(_besar ? 50 : 8),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _besar = !_besar),
          child: const Text('Ubah bentuk'),
        ),
        const Divider(),
        Text('2. AnimatedSwitcher', style: tema.textTheme.titleMedium),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) {
              return ScaleTransition(scale: anim, child: child);
            },
            child: Text(
              '$_hitung',
              key: ValueKey(_hitung),
              style: tema.textTheme.displayMedium,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _hitung++),
          child: const Text('Tambah'),
        ),
        const Divider(),
        Text('3. AnimationController', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: RotationTransition(
            turns: _putar,
            child: Icon(Icons.settings, size: 64, color: warna.primary),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_putar.isAnimating) {
              _putar.stop();
            } else {
              _putar.repeat();
            }
            setState(() {});
          },
          child: Text(_putar.isAnimating ? 'Berhenti' : 'Putar'),
        ),
      ],
    );
  }
}
```

> **Checkpoint:** (1) menekan *Ubah bentuk* mengubah lebar, warna, dan sudut dengan halus; (2) angka berganti dengan efek membesar; (3) ikon roda gigi berputar terus dan dapat dihentikan. Untuk mencobanya sebelum Bagian D, sementara ubah `body` rute `'/'` menjadi `const AnimasiTab()`. **Amati** mengapa `AnimatedSwitcher` membutuhkan `key` yang berbeda pada anaknya.

### Bagian D: Navigasi Tab Bawah (Menyatukan Semuanya)

Tambahkan `ShellPage`, yang menampung tiga tab. `IndexedStack` menjaga state setiap tab tetap hidup saat berpindah.

```
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [BerandaTab(), AnimasiTab(), PengaturanTab()];
  static const _judul = ['Beranda', 'Animasi', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.animation),
            label: 'Animasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
```

Terakhir, ubah rute `'/'` pada `MyApp` menjadi:

```
routes: {
  '/': (_) => const ShellPage(),
},
```

> **Checkpoint:** aplikasi memiliki tiga tab di bawah. Tab Beranda membuka halaman detail dengan Hero, tab Animasi menjalankan demo, dan tab Pengaturan mengganti tema seluruh aplikasi termasuk halaman detail.

## 5. Latihan Mandiri
1. Simpan mode gelap dan warna tema dengan `shared_preferences` (Pertemuan 5) dan muat saat aplikasi dimulai (`WidgetsFlutterBinding.ensureInitialized()` di `main()`). Petunjuk: simpan **indeks** warna pada `pilihanWarna` dengan `setInt`; jangan memakai `Color.value` karena sudah *deprecated* (penggantinya `toARGB32()`).
2. Tambahkan `Drawer` pada `ShellPage` berisi menu untuk berpindah tab.
3. Ganti transisi halaman detail dengan `PageRouteBuilder` yang memakai `FadeTransition` (di dalam `onGenerateRoute`). Petunjuk: `pageBuilder: (context, animation, secondaryAnimation) => DetailPage(item: item)` dan `transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child)`; jangan lupa meneruskan `settings`.
4. Tambahkan `onUnknownRoute` yang menampilkan halaman "404 - Halaman tidak ditemukan".
5. Tambahkan demo keempat di `AnimasiTab`: `AnimatedOpacity` yang memudarkan dan memunculkan sebuah kartu saat tombol ditekan.

## 6. Tugas

Buat aplikasi **Galeri/Katalog Interaktif** dengan tema bebas (misalnya profil diri, katalog produk, atau galeri tempat wisata) dengan ketentuan:
- Minimal 3 tab memakai `NavigationBar` (misalnya Beranda, Favorit/Katalog, Pengaturan).
- *Named routes* dengan argumen untuk halaman detail, dan halaman detail memakai `Hero`.
- Minimal dua jenis animasi: satu implisit dan satu eksplisit (`AnimationController`).
- Pengaturan tema terang/gelap dan minimal 3 pilihan warna, **tersimpan** setelah aplikasi ditutup.
- Warna dan gaya teks mengambil dari `Theme.of(context)` (hindari warna hard-coded pada teks dan latar).
- Kumpulkan: tangkapan layar (mode terang, mode gelap, halaman detail) dan berkas kode (atau tautan repositori). Aplikasi ini akan menjadi bahan awal untuk mini proyek di Pertemuan 7.

## 7. Rubrik Penilaian

| Komponen | Bobot |
| Bagian A–D berjalan (checkpoint) | 30% |
| Latihan mandiri | 20% |
| Tugas Galeri/Katalog (tab, routing, Hero, animasi, tema tersimpan) | 40% |
| Kerapian kode dan konsistensi memakai tema | 10% |

## 8. Pertanyaan Refleksi
1. Apa perbedaan animasi implisit dan eksplisit? Kapan memilih masing-masing?
2. Mengapa dua `Hero` harus memiliki `tag` yang sama, dan apa yang terjadi bila tag-nya kembali muncul dua kali di halaman yang sama?
3. Apa keuntungan memakai `Theme.of(context)` dibanding menulis warna langsung pada widget?
4. Apa perbedaan berpindah tab dengan `IndexedStack` dan membuka halaman dengan `Navigator`?
5. Mengapa `AnimationController` wajib di-`dispose`?

## 9. Troubleshooting Umum

| Masalah | Solusi |
| Could not find a generator for route | Nama rute salah ketik, atau belum ditangani di `routes` / `onGenerateRoute` |
| Hero tidak beranimasi | Pastikan `tag` sama di kedua halaman dan unik di halaman yang sama |
| Tema tidak berubah saat saklar digeser | Pastikan `MaterialApp` dibungkus `ListenableBuilder` dan nilai diubah lewat `themeMode.value` (bukan variabel biasa) |
| Sebagian warna tidak ikut mode gelap | Warna ditulis manual; ganti dengan `Theme.of(context).colorScheme` |
| AnimatedContainer tidak beranimasi | Nilai harus berubah di dalam `setState` dan kedua nilai harus bertipe sama (angka/warna) |
| AnimatedSwitcher tidak beranimasi | Anak harus punya `key` yang berbeda tiap perubahan (misalnya `ValueKey`) |
| Error: vsync / TickerProvider | Tambahkan `with SingleTickerProviderStateMixin` pada state class |

## 10. Referensi
- Tema aplikasi: docs.flutter.dev/cookbook/design/themes
- Navigasi dengan named routes: docs.flutter.dev/cookbook/navigation/named-routes
- Pengantar animasi: docs.flutter.dev/ui/animations
- Hero animations: docs.flutter.dev/ui/animations/hero-animations
