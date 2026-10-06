import os

from app.config import settings

JPG = b"\xff\xd8\xff\xe0" + b"0" * 100
PNG = b"\x89PNG\r\n\x1a\n" + b"0" * 100


def _kegiatan(client, auth, tipe="pengeluaran"):
    data = {"judul": "Beli buku", "tanggal": "2026-10-06", "tipe": tipe}
    if tipe != "tanpa":
        data.update(nominal=50000, kategori_id=3 if tipe == "pengeluaran" else None)
    return client.post("/kegiatan", headers=auth, json=data).json()


def _unggah(client, auth, kid, isi=JPG, jenis="image/jpeg"):
    return client.post(
        f"/kegiatan/{kid}/bukti", headers=auth, files={"berkas": ("struk.jpg", isi, jenis)}
    )


def test_unggah_lalu_unduh(client, auth):
    k = _kegiatan(client, auth)
    res = _unggah(client, auth, k["id"])
    assert res.status_code == 200
    bukti = res.json()["bukti"]
    assert bukti.startswith("uploads/") and bukti.endswith(".jpg")

    unduh = client.get(f"/{bukti}")
    assert unduh.status_code == 200
    assert unduh.content == JPG


def test_ganti_bukti_menghapus_berkas_lama(client, auth):
    k = _kegiatan(client, auth)
    lama = _unggah(client, auth, k["id"]).json()["bukti"]
    baru = _unggah(client, auth, k["id"], PNG, "image/png").json()["bukti"]
    assert baru.endswith(".png")
    assert not os.path.exists(os.path.join(settings.upload_dir, os.path.basename(lama)))


def test_format_dan_ukuran_divalidasi(client, auth):
    k = _kegiatan(client, auth)
    assert _unggah(client, auth, k["id"], b"%PDF", "application/pdf").status_code == 415
    # Content-Type mengaku JPG padahal isinya bukan gambar.
    assert _unggah(client, auth, k["id"], b"bukan gambar", "image/jpeg").status_code == 415
    besar = b"\xff\xd8\xff" + b"0" * settings.maks_ukuran_bukti
    assert _unggah(client, auth, k["id"], besar).status_code == 413


def test_bukti_tidak_untuk_kegiatan_tanpa_uang(client, auth):
    k = _kegiatan(client, auth, tipe="tanpa")
    assert _unggah(client, auth, k["id"]).status_code == 400


def test_hapus_bukti_dan_kegiatan(client, auth):
    k = _kegiatan(client, auth)
    bukti = _unggah(client, auth, k["id"]).json()["bukti"]
    res = client.delete(f"/kegiatan/{k['id']}/bukti", headers=auth)
    assert res.json()["bukti"] is None
    assert client.get(f"/{bukti}").status_code == 404

    bukti = _unggah(client, auth, k["id"]).json()["bukti"]
    client.delete(f"/kegiatan/{k['id']}", headers=auth)
    assert client.get(f"/{bukti}").status_code == 404
