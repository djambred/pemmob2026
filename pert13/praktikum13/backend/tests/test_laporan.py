def test_skenario_satu_hari_modul_7(client, auth):
    """Contoh Skenario Satu Hari pada modul pertemuan 7."""
    data = [
        ("Kuliah pagi dan makan siang", "pengeluaran", 15000, 1, True),
        ("Pulang naik angkot", "pengeluaran", 10000, 2, True),
        ("Kerja freelance desain poster", "pemasukan", 50000, None, False),
        ("Belajar Flutter di perpustakaan", "tanpa", 0, None, False),
    ]
    for judul, tipe, nominal, kategori_id, selesai in data:
        res = client.post(
            "/kegiatan",
            headers=auth,
            json={
                "judul": judul,
                "tanggal": "2026-10-05",
                "tipe": tipe,
                "nominal": nominal,
                "kategori_id": kategori_id,
                "selesai": selesai,
            },
        )
        assert res.status_code == 201, res.text

    lap = client.get("/laporan/harian", headers=auth, params={"tanggal": "2026-10-05"}).json()
    assert lap["jumlah_kegiatan"] == 4
    assert lap["selesai"] == 2
    assert lap["pemasukan"] == 50000
    assert lap["pengeluaran"] == 25000
    assert lap["tabungan"] == 25000
    assert lap["per_kategori"] == [
        {"kategori": "Makan", "total": 15000},
        {"kategori": "Transport", "total": 10000},
    ]


def test_tanggal_kosong_bernilai_nol(client, auth):
    lap = client.get("/laporan/harian", headers=auth, params={"tanggal": "2000-01-01"}).json()
    assert lap["jumlah_kegiatan"] == 0
    assert lap["tabungan"] == 0
    assert lap["per_kategori"] == []


def test_rentang(client, auth):
    client.post(
        "/kegiatan",
        headers=auth,
        json={"judul": "Gaji", "tanggal": "2026-10-05", "tipe": "pemasukan", "nominal": 100},
    )
    res = client.get(
        "/laporan/rentang", headers=auth, params={"mulai": "2026-10-04", "sampai": "2026-10-06"}
    )
    assert [h["pemasukan"] for h in res.json()] == [0, 100, 0]

    terlalu_panjang = {"mulai": "2026-01-01", "sampai": "2026-03-01"}
    res = client.get("/laporan/rentang", headers=auth, params=terlalu_panjang)
    assert res.status_code == 400
