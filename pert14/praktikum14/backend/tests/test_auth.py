from .conftest import daftar_dan_login


def test_register_dan_profil(client, auth):
    res = client.get("/users/me", headers=auth)
    assert res.status_code == 200
    assert res.json()["email"] == "budi@contoh.id"
    assert res.json()["target_harian"] == 20000
    assert "password_hash" not in res.json()


def test_email_ganda_ditolak(client, auth):
    res = client.post(
        "/auth/register",
        json={"nama": "Lain", "email": "BUDI@contoh.id", "password": "rahasia123"},
    )
    assert res.status_code == 409


def test_password_pendek_ditolak(client):
    res = client.post(
        "/auth/register", json={"nama": "A", "email": "a@contoh.id", "password": "123"}
    )
    assert res.status_code == 422


def test_login_salah(client, auth):
    res = client.post("/auth/login", data={"username": "budi@contoh.id", "password": "salah"})
    assert res.status_code == 401


def test_tanpa_token_ditolak(client):
    assert client.get("/kegiatan").status_code == 401
    assert client.get("/kegiatan", headers={"Authorization": "Bearer palsu"}).status_code == 401


def test_refresh_token(client):
    client.post(
        "/auth/register", json={"nama": "B", "email": "b@contoh.id", "password": "rahasia123"}
    )
    token = client.post(
        "/auth/login", data={"username": "b@contoh.id", "password": "rahasia123"}
    ).json()
    # Refresh token tidak boleh dipakai sebagai access token.
    res = client.get("/users/me", headers={"Authorization": f"Bearer {token['refresh_token']}"})
    assert res.status_code == 401

    baru = client.post("/auth/refresh", json={"refresh_token": token["refresh_token"]})
    assert baru.status_code == 200
    res = client.get(
        "/users/me", headers={"Authorization": f"Bearer {baru.json()['access_token']}"}
    )
    assert res.status_code == 200


def test_akun_nonaktif(client, db_session, auth):
    from app.models import User

    with db_session() as db:
        db.query(User).update({"aktif": False})
        db.commit()
    assert client.get("/users/me", headers=auth).status_code == 403
    res = client.post("/auth/login", data={"username": "budi@contoh.id", "password": "rahasia123"})
    assert res.status_code == 403


def test_ubah_target(client, auth):
    res = client.patch("/users/me", headers=auth, json={"target_harian": 25000})
    assert res.json()["target_harian"] == 25000
    assert client.patch("/users/me", headers=auth, json={"target_harian": -1}).status_code == 422


def test_daftar_dan_login_helper_mengembalikan_header(client):
    assert daftar_dan_login(client, "c@contoh.id")["Authorization"].startswith("Bearer ")
