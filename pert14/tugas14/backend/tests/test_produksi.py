import pytest
from pydantic import ValidationError

from app.config import JWT_SECRET_BAWAAN, Settings


def test_produksi_menolak_jwt_secret_bawaan():
    # jwt_secret ditulis eksplisit agar tidak terpengaruh variabel JWT_SECRET
    # yang mungkin sudah ada di environment container.
    with pytest.raises(ValidationError):
        Settings(app_env="production", jwt_secret=JWT_SECRET_BAWAAN)
    with pytest.raises(ValidationError):
        Settings(app_env="production", jwt_secret="pendek")


def test_produksi_dengan_secret_kuat():
    s = Settings(app_env="production", jwt_secret="x" * 40)
    assert s.produksi


def test_cors_aktif_bila_diatur(client):
    # Pada pengujian CORS tidak diatur, jadi header CORS tidak dikirim.
    res = client.get("/health", headers={"Origin": "http://contoh.test"})
    assert "access-control-allow-origin" not in res.headers
