import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Menyimpan tangkapan layar dari integration test ke folder screenshots/.
Future<void> main() => integrationDriver(
  onScreenshot: (nama, bytes, [args]) async {
    final berkas = File('screenshots/$nama.png');
    await berkas.create(recursive: true);
    await berkas.writeAsBytes(bytes);
    return true;
  },
);
