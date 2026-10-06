from datetime import date, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import case, func, select
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Kegiatan, Tipe
from ..schemas import LaporanHarian, RingkasanHari, TotalKategori

router = APIRouter(prefix="/laporan", tags=["laporan"])

MAKS_HARI = 31


def _ringkasan_per_tanggal(db: Session, mulai: date, sampai: date) -> list[RingkasanHari]:
    """Satu query GROUP BY tanggal, lalu tanggal tanpa kegiatan diisi 0."""

    def jumlah_jika(kondisi, nilai):
        return func.coalesce(func.sum(case((kondisi, nilai), else_=0)), 0)

    stmt = (
        select(
            Kegiatan.tanggal,
            func.count().label("jumlah"),
            jumlah_jika(Kegiatan.selesai.is_(True), 1).label("selesai"),
            jumlah_jika(Kegiatan.tipe == Tipe.pemasukan, Kegiatan.nominal).label("masuk"),
            jumlah_jika(Kegiatan.tipe == Tipe.pengeluaran, Kegiatan.nominal).label("keluar"),
        )
        .where(Kegiatan.tanggal.between(mulai, sampai))
        .group_by(Kegiatan.tanggal)
    )
    per_tanggal = {baris.tanggal: baris for baris in db.execute(stmt)}

    hasil = []
    hari = mulai
    while hari <= sampai:
        b = per_tanggal.get(hari)
        masuk = int(b.masuk) if b else 0
        keluar = int(b.keluar) if b else 0
        hasil.append(
            RingkasanHari(
                tanggal=hari,
                jumlah_kegiatan=b.jumlah if b else 0,
                selesai=int(b.selesai) if b else 0,
                pemasukan=masuk,
                pengeluaran=keluar,
                tabungan=masuk - keluar,
            )
        )
        hari += timedelta(days=1)
    return hasil


@router.get("/harian", response_model=LaporanHarian)
def laporan_harian(tanggal: date, db: Session = Depends(get_db)):
    """Ringkasan satu hari + total pengeluaran per kategori."""
    ringkasan = _ringkasan_per_tanggal(db, tanggal, tanggal)[0]

    stmt = (
        select(Kegiatan.kategori, func.sum(Kegiatan.nominal).label("total"))
        .where(Kegiatan.tanggal == tanggal, Kegiatan.tipe == Tipe.pengeluaran)
        .group_by(Kegiatan.kategori)
        .order_by(func.sum(Kegiatan.nominal).desc())
    )
    per_kategori = [
        TotalKategori(kategori=b.kategori, total=int(b.total)) for b in db.execute(stmt)
    ]
    return LaporanHarian(**ringkasan.model_dump(), per_kategori=per_kategori)


@router.get("/rentang", response_model=list[RingkasanHari])
def laporan_rentang(mulai: date, sampai: date, db: Session = Depends(get_db)):
    """Ringkasan setiap hari dari `mulai` sampai `sampai` (maksimal 31 hari)."""
    if sampai < mulai:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "Tanggal sampai harus setelah tanggal mulai"
        )
    if (sampai - mulai).days + 1 > MAKS_HARI:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Rentang maksimal {MAKS_HARI} hari")
    return _ringkasan_per_tanggal(db, mulai, sampai)
