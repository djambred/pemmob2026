"""Fixture pytest. Pengujian memakai SQLite di memori, bukan MySQL,
sehingga cepat dan tidak mengganggu data di docker compose."""

import os
import tempfile

# Harus di-set sebelum modul app diimpor (Settings dibaca saat impor).
os.environ["DATABASE_URL"] = "sqlite://"
os.environ["UPLOAD_DIR"] = tempfile.mkdtemp(prefix="tabungku-uji-")

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import create_engine  # noqa: E402
from sqlalchemy.orm import sessionmaker  # noqa: E402
from sqlalchemy.pool import StaticPool  # noqa: E402

from app.database import Base, get_db  # noqa: E402
from app.main import app  # noqa: E402
from app.models import Kategori  # noqa: E402

KATEGORI = ["Makan", "Transport", "Belajar", "Hiburan", "Lainnya"]


@pytest.fixture
def db_session():
    # StaticPool: semua koneksi memakai database memori yang sama.
    engine = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    Base.metadata.create_all(engine)
    Sesi = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)
    with Sesi() as db:
        db.add_all(Kategori(nama=n, urutan=i) for i, n in enumerate(KATEGORI, 1))
        db.commit()
    yield Sesi
    engine.dispose()


@pytest.fixture
def client(db_session):
    def get_db_uji():
        db = db_session()
        try:
            yield db
        finally:
            db.close()

    # Ganti dependency get_db dengan database uji.
    app.dependency_overrides[get_db] = get_db_uji
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


def daftar_dan_login(client: TestClient, email: str = "budi@contoh.id") -> dict:
    """Mendaftarkan akun lalu mengembalikan header Authorization."""
    client.post("/auth/register", json={"nama": "Budi", "email": email, "password": "rahasia123"})
    res = client.post("/auth/login", data={"username": email, "password": "rahasia123"})
    return {"Authorization": f"Bearer {res.json()['access_token']}"}


@pytest.fixture
def auth(client) -> dict:
    return daftar_dan_login(client)
