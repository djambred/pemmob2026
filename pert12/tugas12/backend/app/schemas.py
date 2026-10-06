from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator, model_validator

from .models import Tipe


class KegiatanBase(BaseModel):
    judul: str = Field(min_length=1, max_length=100, examples=["Makan siang"])
    tanggal: date = Field(examples=["2026-10-06"])
    selesai: bool = False
    tipe: Tipe = Tipe.tanpa
    nominal: int = Field(default=0, ge=0, examples=[15000])
    kategori_id: int | None = Field(default=None, examples=[1])


class KegiatanInput(KegiatanBase):
    """Data dari klien untuk POST dan PUT. Aturan bisnis modul 7 dicek di sini."""

    @field_validator("judul")
    @classmethod
    def judul_tidak_kosong(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("judul wajib diisi")
        return v

    @model_validator(mode="after")
    def cek_aturan_bisnis(self):
        if self.tipe == Tipe.tanpa:
            self.nominal = 0
            self.kategori_id = None
            return self
        if self.nominal <= 0:
            raise ValueError("nominal wajib lebih dari 0 untuk pemasukan/pengeluaran")
        if self.tipe == Tipe.pemasukan:
            self.kategori_id = None
        elif self.kategori_id is None:
            raise ValueError("kategori wajib dipilih untuk pengeluaran")
        # Keberadaan kategori di database dicek di router (butuh query).
        return self


class KegiatanPatch(BaseModel):
    """PATCH: semua field opsional, hanya yang dikirim yang diubah."""

    judul: str | None = None
    tanggal: date | None = None
    selesai: bool | None = None
    tipe: Tipe | None = None
    nominal: int | None = None
    kategori_id: int | None = None


class KegiatanOut(KegiatanBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    # Nama kategori untuk ditampilkan; dibaca dari properti model nama_kategori.
    kategori: str = Field(default="-", validation_alias="nama_kategori")
    created_at: datetime
    updated_at: datetime


class KategoriOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nama: str


class Ringkasan(BaseModel):
    jumlah_kegiatan: int
    selesai: int
    pemasukan: int
    pengeluaran: int
    tabungan: int


class RingkasanHari(Ringkasan):
    tanggal: date


class TotalKategori(BaseModel):
    kategori: str
    total: int


class LaporanHarian(RingkasanHari):
    per_kategori: list[TotalKategori]


class UserCreate(BaseModel):
    nama: str = Field(min_length=1, max_length=100, examples=["Budi"])
    email: EmailStr = Field(examples=["budi@contoh.id"])
    password: str = Field(min_length=8, max_length=72, examples=["rahasia123"])


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nama: str
    email: str
    target_harian: int


class UserUpdate(BaseModel):
    """PATCH /users/me: hanya field yang dikirim yang diubah."""

    nama: str | None = Field(default=None, min_length=1, max_length=100)
    target_harian: int | None = Field(default=None, ge=0, le=10_000_000)


class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshInput(BaseModel):
    refresh_token: str
