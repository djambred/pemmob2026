from fastapi import APIRouter
from sqlalchemy import select

from ..deps import DbSession, UserAktif
from ..models import Kategori
from ..schemas import KategoriOut

router = APIRouter(prefix="/kategori", tags=["kategori"])


@router.get("", response_model=list[KategoriOut])
def daftar_kategori(db: DbSession, _: UserAktif):
    """Kategori pengeluaran yang aktif, urut sesuai pengaturan admin."""
    stmt = select(Kategori).where(Kategori.aktif.is_(True)).order_by(Kategori.urutan, Kategori.nama)
    return db.scalars(stmt).all()
