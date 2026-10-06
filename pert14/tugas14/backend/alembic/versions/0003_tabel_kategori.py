"""tabel master kategori

Revision ID: 0003
Revises: 0002
Create Date: 2026-10-06
"""

import sqlalchemy as sa

from alembic import op

revision = "0003"
down_revision = "0002"
branch_labels = None
depends_on = None

KATEGORI_AWAL = ["Makan", "Transport", "Belajar", "Hiburan", "Lainnya"]


def upgrade() -> None:
    kategori = op.create_table(
        "kategori",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("nama", sa.String(30), nullable=False, unique=True),
        sa.Column("urutan", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("aktif", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
    )
    # Data awal sama dengan daftar tetap di pertemuan 7.
    op.bulk_insert(
        kategori,
        [{"nama": nama, "urutan": i + 1} for i, nama in enumerate(KATEGORI_AWAL)],
    )

    op.add_column("kegiatan", sa.Column("kategori_id", sa.Integer(), nullable=True))
    op.create_index("ix_kegiatan_kategori_id", "kegiatan", ["kategori_id"])
    op.create_foreign_key(
        "fk_kegiatan_kategori",
        "kegiatan",
        "kategori",
        ["kategori_id"],
        ["id"],
        ondelete="RESTRICT",
    )

    # Migrasi data: teks kategori lama -> id kategori.
    op.execute(
        "UPDATE kegiatan k JOIN kategori c ON c.nama = k.kategori "
        "SET k.kategori_id = c.id WHERE k.tipe = 'pengeluaran'"
    )
    op.drop_column("kegiatan", "kategori")


def downgrade() -> None:
    op.add_column(
        "kegiatan",
        sa.Column("kategori", sa.String(30), nullable=False, server_default="-"),
    )
    op.execute("UPDATE kegiatan k JOIN kategori c ON c.id = k.kategori_id SET k.kategori = c.nama")
    op.drop_constraint("fk_kegiatan_kategori", "kegiatan", type_="foreignkey")
    op.drop_index("ix_kegiatan_kategori_id", table_name="kegiatan")
    op.drop_column("kegiatan", "kategori_id")
    op.drop_table("kategori")
