"""Mengisi data contoh: 3 pengguna dan kegiatan selama 30 hari terakhir.

Berguna untuk mencoba dashboard Filament (grafik butuh data). Jalankan:
    docker compose exec api python -m scripts.seed_demo

Semua akun contoh memakai password: rahasia123
Pengguna yang sudah punya kegiatan dilewati, jadi aman dijalankan ulang.
"""

import random
from datetime import date, timedelta

from sqlalchemy import func, select

from app.database import SessionLocal
from app.models import Kategori, Kegiatan, Tipe, User
from app.security import hash_password

PENGGUNA = [
    ("Budi Santoso", "budi@contoh.id"),
    ("Ani Lestari", "ani@contoh.id"),
    ("Citra Dewi", "citra@contoh.id"),
]
PEMASUKAN = [("Uang saku", 50000), ("Freelance desain poster", 75000), ("Jual pulsa", 20000)]
PENGELUARAN = {
    "Makan": ["Makan siang", "Sarapan", "Kopi"],
    "Transport": ["Angkot", "Ojek online", "Bensin"],
    "Belajar": ["Fotokopi materi", "Beli buku"],
    "Hiburan": ["Nonton", "Langganan musik"],
    "Lainnya": ["Laundry", "Pulsa"],
}
TANPA_UANG = ["Kuliah pagi", "Kerja kelompok", "Belajar Flutter di perpustakaan"]


def isi_pengguna(db, user: User, kategori: dict[str, Kategori], rnd: random.Random) -> int:
    jumlah = 0
    for mundur in range(30):
        tgl = date.today() - timedelta(days=mundur)
        lewat = mundur > 0  # kegiatan hari-hari sebelumnya dianggap selesai

        db.add(Kegiatan(user_id=user.id, judul=rnd.choice(TANPA_UANG), tanggal=tgl, selesai=lewat))
        if rnd.random() < 0.6:
            judul, nominal = rnd.choice(PEMASUKAN)
            db.add(
                Kegiatan(
                    user_id=user.id,
                    judul=judul,
                    tanggal=tgl,
                    tipe=Tipe.pemasukan,
                    nominal=nominal,
                    selesai=lewat,
                )
            )
            jumlah += 1
        for _ in range(rnd.randint(1, 3)):
            nama_kat = rnd.choice(list(kategori))
            db.add(
                Kegiatan(
                    user_id=user.id,
                    judul=rnd.choice(PENGELUARAN.get(nama_kat, ["Belanja"])),
                    tanggal=tgl,
                    tipe=Tipe.pengeluaran,
                    nominal=rnd.randrange(5000, 40000, 1000),
                    kategori_id=kategori[nama_kat].id,
                    selesai=lewat,
                )
            )
            jumlah += 1
        jumlah += 1
    return jumlah


def main() -> None:
    rnd = random.Random(2026)  # hasil sama setiap dijalankan
    with SessionLocal() as db:
        kategori = {k.nama: k for k in db.scalars(select(Kategori).where(Kategori.aktif.is_(True)))}
        for nama, email in PENGGUNA:
            user = db.scalar(select(User).where(User.email == email))
            if user is None:
                user = User(nama=nama, email=email, password_hash=hash_password("rahasia123"))
                db.add(user)
                db.flush()
            sudah_ada = db.scalar(
                select(func.count()).select_from(Kegiatan).where(Kegiatan.user_id == user.id)
            )
            if sudah_ada:
                print(f"- {email}: sudah punya {sudah_ada} kegiatan, dilewati")
                continue
            print(f"- {email}: {isi_pengguna(db, user, kategori, rnd)} kegiatan dibuat")
        db.commit()
    print("Selesai. Password semua akun contoh: rahasia123")


if __name__ == "__main__":
    main()
