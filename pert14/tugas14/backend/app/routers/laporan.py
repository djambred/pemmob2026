import calendar
import csv
import io
from datetime import date, timedelta

from fastapi import APIRouter, HTTPException, Query, status
from fastapi.responses import StreamingResponse
from sqlalchemy import case, func, select
from sqlalchemy.orm import Session

from ..deps import DbSession, UserAktif
from ..models import Kategori, Kegiatan, Tipe, User
from ..schemas import LaporanBulanan, LaporanHarian, RingkasanHari, TotalKategori

router = APIRouter(prefix="/laporan", tags=["laporan"])

MAKS_HARI = 31


def _ringkasan_per_tanggal(
    db: Session, user: User, mulai: date, sampai: date
) -> list[RingkasanHari]:
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
        .where(Kegiatan.user_id == user.id, Kegiatan.tanggal.between(mulai, sampai))
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


def _per_kategori(db: Session, user: User, mulai: date, sampai: date) -> list[TotalKategori]:
    total = func.sum(Kegiatan.nominal)
    stmt = (
        select(Kategori.nama.label("kategori"), total.label("total"))
        .join(Kegiatan.kategori)
        .where(
            Kegiatan.user_id == user.id,
            Kegiatan.tanggal.between(mulai, sampai),
            Kegiatan.tipe == Tipe.pengeluaran,
        )
        .group_by(Kategori.nama)
        .order_by(total.desc())
    )
    return [TotalKategori(kategori=b.kategori, total=int(b.total)) for b in db.execute(stmt)]


@router.get("/harian", response_model=LaporanHarian)
def laporan_harian(tanggal: date, db: DbSession, user: UserAktif):
    """Ringkasan satu hari + total pengeluaran per kategori."""
    ringkasan = _ringkasan_per_tanggal(db, user, tanggal, tanggal)[0]

    per_kategori = _per_kategori(db, user, tanggal, tanggal)
    return LaporanHarian(**ringkasan.model_dump(), per_kategori=per_kategori)


@router.get("/rentang", response_model=list[RingkasanHari])
def laporan_rentang(mulai: date, sampai: date, db: DbSession, user: UserAktif):
    """Ringkasan setiap hari dari `mulai` sampai `sampai` (maksimal 31 hari)."""
    if sampai < mulai:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "Tanggal sampai harus setelah tanggal mulai"
        )
    if (sampai - mulai).days + 1 > MAKS_HARI:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Rentang maksimal {MAKS_HARI} hari")
    return _ringkasan_per_tanggal(db, user, mulai, sampai)


@router.get("/bulanan", response_model=LaporanBulanan)
def laporan_bulanan(
    db: DbSession,
    user: UserAktif,
    tahun: int = Query(ge=2000, le=2100),
    bulan: int = Query(ge=1, le=12),
):
    """Total satu bulan, pengeluaran per kategori, dan jumlah hari target tercapai."""
    jumlah_hari = calendar.monthrange(tahun, bulan)[1]
    mulai = date(tahun, bulan, 1)
    sampai = date(tahun, bulan, jumlah_hari)
    harian = _ringkasan_per_tanggal(db, user, mulai, sampai)

    # Hari yang belum terjadi tidak dihitung.
    sudah_lewat = [h for h in harian if h.tanggal <= date.today()]
    tercapai = sum(1 for h in sudah_lewat if h.tabungan >= user.target_harian)
    masuk = sum(h.pemasukan for h in harian)
    keluar = sum(h.pengeluaran for h in harian)

    return LaporanBulanan(
        tahun=tahun,
        bulan=bulan,
        jumlah_hari=jumlah_hari,
        hari_target_tercapai=tercapai,
        jumlah_kegiatan=sum(h.jumlah_kegiatan for h in harian),
        selesai=sum(h.selesai for h in harian),
        pemasukan=masuk,
        pengeluaran=keluar,
        tabungan=masuk - keluar,
        per_kategori=_per_kategori(db, user, mulai, sampai),
    )


@router.get("/ekspor.csv", response_class=StreamingResponse)
def ekspor_csv(mulai: date, sampai: date, db: DbSession, user: UserAktif):
    """Unduh semua kegiatan dalam rentang tanggal (maksimal 1 tahun) sebagai CSV."""
    if sampai < mulai or (sampai - mulai).days > 366:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Rentang harus 1 sampai 366 hari")

    stmt = (
        select(Kegiatan)
        .where(Kegiatan.user_id == user.id, Kegiatan.tanggal.between(mulai, sampai))
        .order_by(Kegiatan.tanggal, Kegiatan.id)
    )
    buf = io.StringIO()
    tulis = csv.writer(buf)
    tulis.writerow(["tanggal", "judul", "tipe", "kategori", "nominal", "selesai"])
    for k in db.scalars(stmt):
        tulis.writerow(
            [k.tanggal, k.judul, k.tipe.value, k.nama_kategori, k.nominal, int(k.selesai)]
        )
    nama = f"tabungku_{mulai}_{sampai}.csv"
    return StreamingResponse(
        iter([buf.getvalue()]),
        media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": f'attachment; filename="{nama}"'},
    )
