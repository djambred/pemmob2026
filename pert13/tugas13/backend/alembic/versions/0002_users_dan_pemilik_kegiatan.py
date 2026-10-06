"""tabel users dan pemilik kegiatan

Revision ID: 0002
Revises: 0001
Create Date: 2026-10-06
"""

import sqlalchemy as sa

from alembic import op

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("nama", sa.String(100), nullable=False),
        sa.Column("email", sa.String(150), nullable=False, unique=True),
        sa.Column("password_hash", sa.String(255), nullable=False),
        sa.Column("target_harian", sa.Integer(), nullable=False, server_default="20000"),
        sa.Column("aktif", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
    )

    # Kegiatan dari pertemuan 9 belum punya pemilik. Karena hanya data uji,
    # data tersebut dihapus agar kolom user_id dapat dibuat NOT NULL.
    op.execute("DELETE FROM kegiatan")
    op.add_column("kegiatan", sa.Column("user_id", sa.Integer(), nullable=False))
    op.create_index("ix_kegiatan_user_id", "kegiatan", ["user_id"])
    op.create_foreign_key(
        "fk_kegiatan_user", "kegiatan", "users", ["user_id"], ["id"], ondelete="CASCADE"
    )


def downgrade() -> None:
    op.drop_constraint("fk_kegiatan_user", "kegiatan", type_="foreignkey")
    op.drop_index("ix_kegiatan_user_id", table_name="kegiatan")
    op.drop_column("kegiatan", "user_id")
    op.drop_table("users")
