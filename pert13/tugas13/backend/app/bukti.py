"""Penyimpanan foto bukti struk di disk."""

import os
import uuid

from fastapi import HTTPException, UploadFile, status

from .config import settings

# Tanda tangan (magic bytes) di awal berkas. Content-Type dari klien
# bisa dipalsukan, jadi isi berkas juga diperiksa.
_FORMAT = {
    "image/jpeg": (b"\xff\xd8\xff", ".jpg"),
    "image/png": (b"\x89PNG\r\n\x1a\n", ".png"),
    "image/webp": (b"RIFF", ".webp"),
}


async def simpan_bukti(berkas: UploadFile) -> str:
    """Validasi lalu simpan berkas. Mengembalikan path relatif 'uploads/xxx.jpg'."""
    if berkas.content_type not in _FORMAT:
        raise HTTPException(
            status.HTTP_415_UNSUPPORTED_MEDIA_TYPE, "Format harus JPG, PNG, atau WEBP"
        )
    # Baca maksimal 1 byte melebihi batas untuk mengetahui berkas terlalu besar.
    isi = await berkas.read(settings.maks_ukuran_bukti + 1)
    if len(isi) > settings.maks_ukuran_bukti:
        raise HTTPException(status.HTTP_413_CONTENT_TOO_LARGE, "Ukuran foto maksimal 2 MB")

    tanda, ekstensi = _FORMAT[berkas.content_type]
    if not isi.startswith(tanda):
        raise HTTPException(
            status.HTTP_415_UNSUPPORTED_MEDIA_TYPE, "Isi berkas bukan gambar yang valid"
        )

    nama = uuid.uuid4().hex + ekstensi
    with open(os.path.join(settings.upload_dir, nama), "wb") as f:
        f.write(isi)
    return f"uploads/{nama}"


def hapus_bukti(path_relatif: str | None) -> None:
    if not path_relatif:
        return
    path = os.path.join(settings.upload_dir, os.path.basename(path_relatif))
    if os.path.exists(path):
        os.remove(path)
