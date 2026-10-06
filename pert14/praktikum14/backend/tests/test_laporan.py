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


def _catat(client, auth, tanggal, tipe, nominal, kategori_id=None):
    res = client.post(
        "/kegiatan",
        headers=auth,
        json={
            "judul": f"{tipe} {tanggal}",
            "tanggal": tanggal,
            "tipe": tipe,
            "nominal": nominal,
            "kategori_id": kategori_id,
        },
    )
    assert res.status_code == 201, res.text


def test_laporan_bulanan(client, auth):
    # Target bawaan Rp 20.000.
    _catat(client, auth, "2025-02-01", "pemasukan", 50000)  # tabungan 50.000 -> tercapai
    _catat(client, auth, "2025-02-02", "pemasukan", 30000)
    _catat(client, auth, "2025-02-02", "pengeluaran", 20000, 1)  # 10.000 -> belum
    _catat(client, auth, "2025-02-28", "pengeluaran", 5000, 2)
    _catat(client, auth, "2025-03-01", "pemasukan", 99999)  # bulan lain

    lap = client.get("/laporan/bulanan", headers=auth, params={"tahun": 2025, "bulan": 2}).json()
    assert lap["jumlah_hari"] == 28
    assert lap["jumlah_kegiatan"] == 4
    assert lap["pemasukan"] == 80000
    assert lap["pengeluaran"] == 25000
    assert lap["tabungan"] == 55000
    assert lap["hari_target_tercapai"] == 1
    assert lap["per_kategori"] == [
        {"kategori": "Makan", "total": 20000},
        {"kategori": "Transport", "total": 5000},
    ]

    salah = client.get("/laporan/bulanan", headers=auth, params={"tahun": 2025, "bulan": 13})
    assert salah.status_code == 422


def test_ekspor_csv(client, auth):
    _catat(client, auth, "2025-02-01", "pengeluaran", 15000, 1)
    _catat(client, auth, "2025-02-02", "pemasukan", 50000)
    res = client.get(
        "/laporan/ekspor.csv", headers=auth, params={"mulai": "2025-02-01", "sampai": "2025-02-28"}
    )
    assert res.status_code == 200
    assert res.headers["content-type"].startswith("text/csv")
    assert "tabungku_2025-02-01_2025-02-28.csv" in res.headers["content-disposition"]
    baris = res.text.strip().splitlines()
    assert baris[0] == "tanggal,judul,tipe,kategori,nominal,selesai"
    assert baris[1] == "2025-02-01,pengeluaran 2025-02-01,pengeluaran,Makan,15000,0"
    assert len(baris) == 3


def test_ekspor_rentang_salah(client, auth):
    res = client.get(
        "/laporan/ekspor.csv", headers=auth, params={"mulai": "2025-02-10", "sampai": "2025-02-01"}
    )
    assert res.status_code == 400
