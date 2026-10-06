import enum
from datetime import date, datetime

from sqlalchemy import Date, DateTime, Enum, ForeignKey, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


class Tipe(str, enum.Enum):
    tanpa = "tanpa"
    pemasukan = "pemasukan"
    pengeluaran = "pengeluaran"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    nama: Mapped[str] = mapped_column(String(100))
    email: Mapped[str] = mapped_column(String(150), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    target_harian: Mapped[int] = mapped_column(default=20000)
    aktif: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    kegiatan: Mapped[list["Kegiatan"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )


class Kategori(Base):
    """Kategori pengeluaran. Dikelola admin lewat dashboard Filament."""

    __tablename__ = "kategori"

    id: Mapped[int] = mapped_column(primary_key=True)
    nama: Mapped[str] = mapped_column(String(30), unique=True)
    urutan: Mapped[int] = mapped_column(default=0)
    aktif: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(), onupdate=func.now()
    )


class Kegiatan(Base):
    __tablename__ = "kegiatan"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    judul: Mapped[str] = mapped_column(String(100))
    tanggal: Mapped[date] = mapped_column(Date, index=True)
    selesai: Mapped[bool] = mapped_column(default=False)
    tipe: Mapped[Tipe] = mapped_column(Enum(Tipe), default=Tipe.tanpa)
    nominal: Mapped[int] = mapped_column(default=0)
    kategori_id: Mapped[int | None] = mapped_column(
        ForeignKey("kategori.id", ondelete="RESTRICT"), index=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(), onupdate=func.now()
    )

    user: Mapped[User] = relationship(back_populates="kegiatan")
    kategori: Mapped[Kategori | None] = relationship()

    @property
    def nama_kategori(self) -> str:
        return self.kategori.nama if self.kategori else "-"
