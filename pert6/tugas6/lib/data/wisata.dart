import 'package:flutter/material.dart';

class Wisata {
  final String id;
  final String nama;
  final String lokasi;
  final IconData ikon;
  final String deskripsi;

  const Wisata({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.ikon,
    required this.deskripsi,
  });
}

const daftarWisata = [
  Wisata(
    id: 'borobudur',
    nama: 'Candi Borobudur',
    lokasi: 'Magelang, Jawa Tengah',
    ikon: Icons.account_balance,
    deskripsi:
        'Candi Buddha terbesar di dunia yang dibangun pada abad ke-9, '
        'dengan ratusan relief dan stupa.',
  ),
  Wisata(
    id: 'bromo',
    nama: 'Gunung Bromo',
    lokasi: 'Probolinggo, Jawa Timur',
    ikon: Icons.landscape,
    deskripsi:
        'Gunung api aktif dengan lautan pasir dan pemandangan matahari '
        'terbit yang terkenal.',
  ),
  Wisata(
    id: 'rajaampat',
    nama: 'Raja Ampat',
    lokasi: 'Papua Barat Daya',
    ikon: Icons.scuba_diving,
    deskripsi:
        'Kepulauan dengan keanekaragaman hayati laut yang sangat tinggi, '
        'surga para penyelam.',
  ),
  Wisata(
    id: 'toba',
    nama: 'Danau Toba',
    lokasi: 'Sumatra Utara',
    ikon: Icons.water,
    deskripsi:
        'Danau vulkanik terbesar di Asia Tenggara dengan Pulau Samosir '
        'di tengahnya.',
  ),
  Wisata(
    id: 'komodo',
    nama: 'Taman Nasional Komodo',
    lokasi: 'Nusa Tenggara Timur',
    ikon: Icons.pets,
    deskripsi: 'Habitat asli komodo, kadal terbesar di dunia.',
  ),
  Wisata(
    id: 'kotatua',
    nama: 'Kota Tua Jakarta',
    lokasi: 'DKI Jakarta',
    ikon: Icons.museum,
    deskripsi:
        'Kawasan bersejarah dengan bangunan peninggalan kolonial dan '
        'beberapa museum.',
  ),
];

Wisata? cariWisata(String id) {
  for (final w in daftarWisata) {
    if (w.id == id) return w;
  }
  return null;
}
