import os

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from .config import settings
from .routers import auth, health, kategori, kegiatan, laporan

app = FastAPI(title="TabungKu API", version="0.5.0")

# Foto bukti dapat dibuka langsung: GET /uploads/<nama-berkas>.
# Nama berkas acak (UUID) sehingga tidak dapat ditebak.
os.makedirs(settings.upload_dir, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.upload_dir), name="uploads")

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(kategori.router)
app.include_router(kegiatan.router)
app.include_router(laporan.router)


@app.get("/", tags=["health"])
def beranda():
    return {"pesan": "Selamat datang di TabungKu API. Dokumentasi: /docs"}
