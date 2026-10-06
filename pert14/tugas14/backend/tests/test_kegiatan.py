from .conftest import daftar_dan_login

MAKAN = {
    "judul": "Makan siang",
    "tanggal": "2026-10-06",
    "tipe": "pengeluaran",
    "nominal": 15000,
    "kategori_id": 1,
}


def test_crud_kegiatan(client, auth):
    res = client.post("/kegiatan", headers=auth, json=MAKAN)
    assert res.status_code == 201
    k = res.json()
    assert k["kategori"] == "Makan"

    res = client.patch(f"/kegiatan/{k['id']}", headers=auth, json={"selesai": True})
    assert res.json()["selesai"] is True

    res = client.put(f"/kegiatan/{k['id']}", headers=auth, json={**MAKAN, "nominal": 20000})
    assert res.json()["nominal"] == 20000

    res = client.get("/kegiatan", headers=auth, params={"tanggal": "2026-10-06"})
    assert res.headers["X-Total-Count"] == "1"

    assert client.delete(f"/kegiatan/{k['id']}", headers=auth).status_code == 204
    assert client.get(f"/kegiatan/{k['id']}", headers=auth).status_code == 404


def test_aturan_bisnis(client, auth):
    def kirim(**ubah):
        return client.post("/kegiatan", headers=auth, json={**MAKAN, **ubah})

    assert kirim(judul="   ").status_code == 422
    assert kirim(nominal=0).status_code == 422
    assert kirim(kategori_id=None).status_code == 422
    assert kirim(kategori_id=99).status_code == 422

    # Tanpa uang: nominal dan kategori diabaikan.
    res = kirim(tipe="tanpa", nominal=5000)
    assert res.json()["nominal"] == 0
    assert res.json()["kategori_id"] is None

    # Pemasukan tidak punya kategori.
    res = kirim(tipe="pemasukan", nominal=50000)
    assert res.json()["kategori"] == "-"


def test_patch_tetap_divalidasi(client, auth):
    k = client.post("/kegiatan", headers=auth, json=MAKAN).json()
    res = client.patch(f"/kegiatan/{k['id']}", headers=auth, json={"nominal": 0})
    assert res.status_code == 422


def test_data_antar_pengguna_terpisah(client, auth):
    k = client.post("/kegiatan", headers=auth, json=MAKAN).json()
    ani = daftar_dan_login(client, "ani@contoh.id")

    assert client.get("/kegiatan", headers=ani).json() == []
    assert client.get(f"/kegiatan/{k['id']}", headers=ani).status_code == 404
    assert client.delete(f"/kegiatan/{k['id']}", headers=ani).status_code == 404
    assert client.get(f"/kegiatan/{k['id']}", headers=auth).status_code == 200


def test_kategori_nonaktif(client, db_session, auth):
    from app.models import Kategori

    k = client.post("/kegiatan", headers=auth, json=MAKAN).json()
    with db_session() as db:
        db.get(Kategori, 1).aktif = False
        db.commit()

    nama = [c["nama"] for c in client.get("/kategori", headers=auth).json()]
    assert "Makan" not in nama
    # Kegiatan baru tidak boleh memakai kategori nonaktif ...
    assert client.post("/kegiatan", headers=auth, json=MAKAN).status_code == 422
    # ... tetapi kegiatan lama yang sudah memakainya tetap boleh diubah.
    res = client.put(f"/kegiatan/{k['id']}", headers=auth, json={**MAKAN, "judul": "Makan malam"})
    assert res.status_code == 200
