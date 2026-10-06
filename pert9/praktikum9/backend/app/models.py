import enum
from datetime import date, datetime

from sqlalchemy import Date, DateTime, Enum, String, func
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


class Tipe(str, enum.Enum):
    tanpa = "tanpa"
    pemasukan = "pemasukan"
    pengeluaran = "pengeluaran"


class Kegiatan(Base):
    __tablename__ = "kegiatan"

    id: Mapped[int] = mapped_column(primary_key=True)
    judul: Mapped[str] = mapped_column(String(100))
    tanggal: Mapped[date] = mapped_column(Date, index=True)
    selesai: Mapped[bool] = mapped_column(default=False)
    tipe: Mapped[Tipe] = mapped_column(Enum(Tipe), default=Tipe.tanpa)
    nominal: Mapped[int] = mapped_column(default=0)
    kategori: Mapped[str] = mapped_column(String(30), default="-")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(), onupdate=func.now()
    )
