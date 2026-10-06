import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .config import settings
from .routers import auth, health, kategori, kegiatan, laporan, pengumuman

# Di produksi, dokumentasi interaktif (/docs) dimatikan.
app = FastAPI(
    title="TabungKu API",
    version="1.0.0",
    docs_url=None if settings.produksi else "/docs",
    redoc_url=None,
    openapi_url=None if settings.produksi else "/openapi.json",
)

if settings.cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[o.strip() for o in settings.cors_origins.split(",")],
        allow_methods=["*"],
        allow_headers=["Authorization", "Content-Type"],
    )

# Foto bukti dapat dibuka langsung: GET /uploads/<nama-berkas>.
# Nama berkas acak (UUID) sehingga tidak dapat ditebak.
os.makedirs(settings.upload_dir, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.upload_dir), name="uploads")

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(kategori.router)
app.include_router(kegiatan.router)
app.include_router(laporan.router)
app.include_router(pengumuman.router)


@app.get("/", tags=["health"])
def beranda():
    return {"pesan": "Selamat datang di TabungKu API"}
