from datetime import date, timedelta

from app.models import Pengumuman


def test_hanya_pengumuman_yang_tayang(client, db_session, auth):
    kemarin = date.today() - timedelta(days=1)
    besok = date.today() + timedelta(days=1)
    with db_session() as db:
        db.add_all(
            [
                Pengumuman(judul="Tayang", isi="a"),
                Pengumuman(judul="Dalam rentang", isi="b", mulai=kemarin, sampai=besok),
                Pengumuman(judul="Nonaktif", isi="c", aktif=False),
                Pengumuman(judul="Terjadwal", isi="d", mulai=besok),
                Pengumuman(judul="Berakhir", isi="e", sampai=kemarin),
            ]
        )
        db.commit()

    judul = {p["judul"] for p in client.get("/pengumuman", headers=auth).json()}
    assert judul == {"Tayang", "Dalam rentang"}


def test_pengumuman_butuh_login(client):
    assert client.get("/pengumuman").status_code == 401
