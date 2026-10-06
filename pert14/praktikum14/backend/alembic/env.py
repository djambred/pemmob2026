from logging.config import fileConfig

from sqlalchemy import create_engine

from alembic import context
from app import models  # noqa: F401  (mendaftarkan semua tabel ke Base.metadata)
from app.config import settings
from app.database import Base

# Aktifkan pengaturan log dari alembic.ini agar langkah migrasi tercetak.
if context.config.config_file_name is not None:
    fileConfig(context.config.config_file_name)

# Metadata dipakai `alembic revision --autogenerate` untuk membandingkan
# model Python dengan isi database.
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Mode offline: hanya mencetak SQL (alembic upgrade head --sql)."""
    context.configure(url=settings.database_url, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    engine = create_engine(settings.database_url)
    with engine.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
