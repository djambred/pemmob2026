from fastapi import FastAPI

from .routers import health, kegiatan, laporan

app = FastAPI(title="TabungKu API", version="0.2.0")

app.include_router(health.router)
app.include_router(kegiatan.router)
app.include_router(laporan.router)


@app.get("/", tags=["health"])
def beranda():
    return {"pesan": "Selamat datang di TabungKu API. Dokumentasi: /docs"}
