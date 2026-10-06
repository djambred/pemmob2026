import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tabungku/config/api_config.dart';
import 'package:tabungku/models/kegiatan.dart';
import 'package:tabungku/services/api_exception.dart';
import 'package:tabungku/services/kegiatan_api.dart';

Map<String, dynamic> _json({int id = 1, bool selesai = false}) => {
  'id': id,
  'judul': 'Makan siang',
  'tanggal': '2026-10-06',
  'selesai': selesai,
  'tipe': 'pengeluaran',
  'nominal': 15000,
  'kategori_id': 1,
  'kategori': 'Makan',
  'created_at': '2026-10-06T08:00:00',
  'updated_at': '2026-10-06T08:00:00',
};

void main() {
  setUp(() => apiUrl.value = 'http://uji');

  test('fromJson dan toJson', () {
    final k = Kegiatan.fromJson(_json());
    expect(k.id, 1);
    expect(k.tipe, Tipe.pengeluaran);
    expect(k.toJson()['selesai'], isFalse);
    expect(k.kategoriId, 1);
    expect(k.toJson().containsKey('id'), isFalse);
    expect(k.toJson()['kategori_id'], 1);
    expect(k.toJson().containsKey('kategori'), isFalse);
  });

  test('daftar mengirim filter tanggal', () async {
    final api = KegiatanApi(
      client: MockClient((req) async {
        expect(req.method, 'GET');
        expect(req.url.toString(), 'http://uji/kegiatan?tanggal=2026-10-06');
        return http.Response(jsonEncode([_json(), _json(id: 2)]), 200);
      }),
    );
    final hasil = await api.daftar(tanggal: '2026-10-06');
    expect(hasil.map((k) => k.id), [1, 2]);
  });

  test('tambah mengirim JSON dan membaca respons 201', () async {
    final api = KegiatanApi(
      client: MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.headers['Content-Type'], startsWith('application/json'));
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['nominal'], 15000);
        return http.Response(jsonEncode(_json(id: 7)), 201);
      }),
    );
    final k = await api.tambah(Kegiatan.fromJson(_json()));
    expect(k.id, 7);
  });

  test('setSelesai memakai PATCH', () async {
    final api = KegiatanApi(
      client: MockClient((req) async {
        expect(req.method, 'PATCH');
        expect(req.url.path, '/kegiatan/3');
        expect(jsonDecode(req.body), {'selesai': true});
        return http.Response(jsonEncode(_json(id: 3, selesai: true)), 200);
      }),
    );
    expect((await api.setSelesai(3, true)).selesai, isTrue);
  });

  test('pesan validasi 422 dibaca dari detail', () async {
    final api = KegiatanApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'detail': [
              {
                'loc': ['body'],
                'msg': 'Value error, nominal wajib lebih dari 0',
              },
            ],
          }),
          422,
        ),
      ),
    );
    expect(
      () => api.tambah(Kegiatan.fromJson(_json())),
      throwsA(
        isA<ApiException>()
            .having((e) => e.kode, 'kode', 422)
            .having((e) => e.pesan, 'pesan', 'nominal wajib lebih dari 0'),
      ),
    );
  });

  test('404 menghasilkan pesan dari server', () async {
    final api = KegiatanApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'detail': 'Kegiatan tidak ditemukan'}),
          404,
        ),
      ),
    );
    expect(
      () => api.hapus(99),
      throwsA(isA<ApiException>().having((e) => e.kode, 'kode', 404)),
    );
  });
}
