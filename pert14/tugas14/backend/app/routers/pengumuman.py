from datetime import date

from fastapi import APIRouter
from sqlalchemy import or_, select

from ..deps import DbSession, UserAktif
from ..models import Pengumuman
from ..schemas import PengumumanOut

router = APIRouter(prefix="/pengumuman", tags=["pengumuman"])


@router.get("", response_model=list[PengumumanOut])
def pengumuman_tayang(db: DbSession, _: UserAktif):
    """Pengumuman aktif yang sedang dalam rentang tayang (maksimal 5, terbaru dulu)."""
    hari_ini = date.today()
    stmt = (
        select(Pengumuman)
        .where(
            Pengumuman.aktif.is_(True),
            or_(Pengumuman.mulai.is_(None), Pengumuman.mulai <= hari_ini),
            or_(Pengumuman.sampai.is_(None), Pengumuman.sampai >= hari_ini),
        )
        .order_by(Pengumuman.created_at.desc(), Pengumuman.id.desc())
        .limit(5)
    )
    return db.scalars(stmt).all()
