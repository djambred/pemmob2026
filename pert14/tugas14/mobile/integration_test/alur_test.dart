// Uji END-TO-END: aplikasi sungguhan + backend docker compose sungguhan.
//
// Prasyarat:
//   docker compose up -d
//   docker compose exec api python -m scripts.seed_demo
// Jalankan (simulator iOS memakai localhost laptop):
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/alur_test.dart \
//     --dart-define=API_URL=http://localhost:8000
// Emulator Android: --dart-define=API_URL=http://10.0.2.2:8000

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tabungku/main.dart' as app;
import 'package:tabungku/pages/form_kegiatan_page.dart';
import 'package:tabungku/state/sesi.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> tunggu(WidgetTester tester, Finder f) async {
    for (var i = 0; i < 100 && f.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(f, findsWidgets);
  }

  Future<void> tungguHilang(WidgetTester tester, Finder f) async {
    for (var i = 0; i < 100 && f.evaluate().isNotEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(f, findsNothing);
  }

  Future<void> foto(WidgetTester tester, String nama) async {
    await tester.pumpAndSettle();
    await binding.takeScreenshot(nama);
  }

  testWidgets('login, catat pengeluaran, lihat laporan', (tester) async {
    await app.main();
    await tester.pumpAndSettle();
    // Mulai dari keadaan belum login.
    if (pengguna.value != null) {
      await hapusSesi();
      await tester.pumpAndSettle();
    }

    await tunggu(tester, find.text('Masuk'));
    await tester.enterText(find.byType(TextFormField).at(0), 'ani@contoh.id');
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');
    await foto(tester, '01-login');
    await tester.tap(find.text('Masuk'));

    await tunggu(tester, find.text('Ringkasan hari ini'));
    // Banner pengumuman dibuat admin (tugas 14) dan dimuat terpisah.
    await tunggu(tester, find.text('Selamat datang di TabungKu Cloud'));
    await foto(tester, '02-hari-ini');

    // Tambah pengeluaran berkategori (kategori dari server).
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Beli buku Flutter',
    );
    await tester.tap(find.text('Pengeluaran'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '45000');
    await tunggu(tester, find.widgetWithText(ChoiceChip, 'Belajar'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Belajar'));
    FocusManager.instance.primaryFocus?.unfocus();
    await foto(tester, '03-form');
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));

    // Form tertutup setelah server menyimpan, lalu kegiatan muncul di daftar.
    await tungguHilang(tester, find.byType(FormKegiatanPage));
    await tunggu(tester, find.text('Beli buku Flutter'));

    await tester.tap(find.text('Laporan'));
    await tunggu(tester, find.text('Pengeluaran per kategori'));
    await foto(tester, '04-laporan');
    await tester.scrollUntilVisible(
      find.textContaining('Target harian tercapai'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await foto(tester, '05-laporan-bulanan');

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();
    expect(find.text('ani@contoh.id'), findsOneWidget);
    await foto(tester, '06-pengaturan');

    await tester.tap(find.text('Status server'));
    await tunggu(tester, find.text('Database (MySQL)'));
    await foto(tester, '07-status-server');
  });
}
