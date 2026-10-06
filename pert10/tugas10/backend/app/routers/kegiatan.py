from datetime import date

from fastapi import APIRouter, HTTPException, Query, Response, status
from fastapi.exceptions import RequestValidationError
from pydantic import ValidationError
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from ..deps import DbSession, UserAktif
from ..models import Kegiatan, Tipe, User
from ..schemas import KegiatanInput, KegiatanOut, KegiatanPatch

router = APIRouter(prefix="/kegiatan", tags=["kegiatan"])


def _ambil_atau_404(db: Session, kegiatan_id: int, user: User) -> Kegiatan:
    """Kegiatan milik user lain dianggap tidak ada (404, bukan 403),
    agar orang lain tidak bisa menebak id mana yang ada."""
    k = db.get(Kegiatan, kegiatan_id)
    if k is None or k.user_id != user.id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Kegiatan tidak ditemukan")
    return k


@router.get("", response_model=list[KegiatanOut])
def daftar_kegiatan(
    response: Response,
    db: DbSession,
    user: UserAktif,
    tanggal: date | None = None,
    tipe: Tipe | None = None,
    q: str | None = Query(None, description="Cari di judul"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
):
    """Daftar kegiatan dengan filter dan pagination.

    Jumlah total data (sebelum limit/offset) dikirim di header X-Total-Count.
    """
    stmt = select(Kegiatan).where(Kegiatan.user_id == user.id)
    if tanggal:
        stmt = stmt.where(Kegiatan.tanggal == tanggal)
    if tipe:
        stmt = stmt.where(Kegiatan.tipe == tipe)
    if q:
        stmt = stmt.where(Kegiatan.judul.contains(q))

    total = db.scalar(select(func.count()).select_from(stmt.subquery()))
    response.headers["X-Total-Count"] = str(total)

    stmt = stmt.order_by(Kegiatan.selesai, Kegiatan.id.desc()).limit(limit).offset(offset)
    return db.scalars(stmt).all()


@router.get("/{kegiatan_id}", response_model=KegiatanOut)
def detail_kegiatan(kegiatan_id: int, db: DbSession, user: UserAktif):
    return _ambil_atau_404(db, kegiatan_id, user)


@router.post("", response_model=KegiatanOut, status_code=status.HTTP_201_CREATED)
def tambah_kegiatan(data: KegiatanInput, db: DbSession, user: UserAktif):
    k = Kegiatan(**data.model_dump(), user_id=user.id)
    db.add(k)
    db.commit()
    db.refresh(k)
    return k


@router.put("/{kegiatan_id}", response_model=KegiatanOut)
def ganti_kegiatan(kegiatan_id: int, data: KegiatanInput, db: DbSession, user: UserAktif):
    k = _ambil_atau_404(db, kegiatan_id, user)
    for kolom, nilai in data.model_dump().items():
        setattr(k, kolom, nilai)
    db.commit()
    db.refresh(k)
    return k


@router.patch("/{kegiatan_id}", response_model=KegiatanOut)
def ubah_sebagian(kegiatan_id: int, data: KegiatanPatch, db: DbSession, user: UserAktif):
    """Contoh: {"selesai": true} untuk mencentang kegiatan."""
    k = _ambil_atau_404(db, kegiatan_id, user)
    gabungan = KegiatanOut.model_validate(k).model_dump()
    gabungan.update(data.model_dump(exclude_unset=True))
    try:
        # Validasi ulang agar aturan bisnis tetap berlaku setelah digabung.
        valid = KegiatanInput.model_validate(gabungan)
    except ValidationError as e:
        # Dibalas 422 dengan format yang sama seperti validasi bawaan FastAPI.
        raise RequestValidationError(e.errors(include_url=False, include_context=False)) from e
    for kolom, nilai in valid.model_dump().items():
        setattr(k, kolom, nilai)
    db.commit()
    db.refresh(k)
    return k


@router.delete("/{kegiatan_id}", status_code=status.HTTP_204_NO_CONTENT)
def hapus_kegiatan(kegiatan_id: int, db: DbSession, user: UserAktif):
    db.delete(_ambil_atau_404(db, kegiatan_id, user))
    db.commit()
