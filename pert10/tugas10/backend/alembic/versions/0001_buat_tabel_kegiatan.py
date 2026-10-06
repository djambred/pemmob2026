"""buat tabel kegiatan

Revision ID: 0001
Revises:
Create Date: 2026-10-06
"""

import sqlalchemy as sa

from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "kegiatan",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("judul", sa.String(100), nullable=False),
        sa.Column("tanggal", sa.Date(), nullable=False),
        sa.Column("selesai", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column(
            "tipe",
            sa.Enum("tanpa", "pemasukan", "pengeluaran", name="tipe"),
            nullable=False,
            server_default="tanpa",
        ),
        sa.Column("nominal", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("kategori", sa.String(30), nullable=False, server_default="-"),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_kegiatan_tanggal", "kegiatan", ["tanggal"])


def downgrade() -> None:
    op.drop_index("ix_kegiatan_tanggal", table_name="kegiatan")
    op.drop_table("kegiatan")
