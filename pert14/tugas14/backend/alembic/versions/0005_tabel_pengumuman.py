"""tabel pengumuman

Revision ID: 0005
Revises: 0004
Create Date: 2026-10-06
"""

import sqlalchemy as sa

from alembic import op

revision = "0005"
down_revision = "0004"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "pengumuman",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("judul", sa.String(100), nullable=False),
        sa.Column("isi", sa.Text(), nullable=False),
        sa.Column("aktif", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("mulai", sa.Date(), nullable=True),
        sa.Column("sampai", sa.Date(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("pengumuman")
