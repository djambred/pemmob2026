from sqlalchemy import create_engine

from .config import settings

# pool_pre_ping: cek koneksi sebelum dipakai, berguna bila MySQL sempat restart.
engine = create_engine(settings.database_url, pool_pre_ping=True)
