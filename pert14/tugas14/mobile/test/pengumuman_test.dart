import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tabungku/models/pengumuman.dart';
import 'package:tabungku/widgets/pengumuman_banner.dart';

const _data = [
  Pengumuman(id: 1, judul: 'Server maintenance', isi: 'Sabtu pukul 22.00'),
  Pengumuman(id: 2, judul: 'Fitur baru', isi: 'Foto struk kini didukung'),
];

Widget _app() => MaterialApp(
  home: Scaffold(body: PengumumanBanner(muat: () async => _data)),
);

void main() {
  testWidgets('menampilkan pengumuman dan mengingat yang ditutup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Server maintenance'), findsOneWidget);
    expect(find.text('Fitur baru'), findsOneWidget);

    await tester.tap(find.byTooltip('Tutup').first);
    await tester.pumpAndSettle();
    expect(find.text('Server maintenance'), findsNothing);

    // Dibuka ulang: yang sudah ditutup tidak muncul lagi.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Server maintenance'), findsNothing);
    expect(find.text('Fitur baru'), findsOneWidget);
  });

  testWidgets('galat server tidak merusak halaman', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PengumumanBanner(muat: () async => throw Exception('mati')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNothing);
  });
}
