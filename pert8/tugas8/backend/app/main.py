from datetime import datetime

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from .database import engine

app = FastAPI(title="TabungKu API", version="0.1.0")


@app.get("/")
def beranda():
    return {"pesan": "Selamat datang di TabungKu API. Dokumentasi: /docs"}


@app.get("/health")
def health():
    """Status API sekaligus koneksi database.

    Bila database tidak dapat dihubungi, kode 503 (Service Unavailable)
    dikirim agar klien dan healthcheck tahu layanan belum siap.
    """
    waktu = datetime.now().isoformat(timespec="seconds")
    try:
        with engine.connect() as conn:
            versi = conn.execute(text("SELECT VERSION()")).scalar_one()
    except SQLAlchemyError as e:
        return JSONResponse(
            status_code=503,
            content={
                "status": "error",
                "waktu_server": waktu,
                "database": "error",
                "detail": str(e.__cause__ or e).splitlines()[0],
            },
        )
    return {
        "status": "ok",
        "waktu_server": waktu,
        "database": "ok",
        "mysql_version": versi,
    }
