"""kolom bukti (foto struk) pada kegiatan

Revision ID: 0004
Revises: 0003
Create Date: 2026-10-06
"""

import sqlalchemy as sa

from alembic import op

revision = "0004"
down_revision = "0003"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("kegiatan", sa.Column("bukti", sa.String(255), nullable=True))


def downgrade() -> None:
    op.drop_column("kegiatan", "bukti")
