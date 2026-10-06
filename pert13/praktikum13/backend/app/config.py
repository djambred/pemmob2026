from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Konfigurasi dibaca dari environment variable (diisi docker-compose)."""

    database_url: str = "mysql+pymysql://tabungku:rahasia_tabungku@localhost:3307/tabungku"

    # JWT: kunci rahasia WAJIB diganti lewat .env (JWT_SECRET).
    jwt_secret: str = "kunci-pengembangan-jangan-dipakai-di-produksi"
    jwt_algoritma: str = "HS256"
    access_token_menit: int = 15
    refresh_token_hari: int = 7

    # Folder foto bukti struk (di docker-compose dipasang sebagai volume).
    upload_dir: str = "/data/uploads"
    maks_ukuran_bukti: int = 2 * 1024 * 1024  # 2 MB


settings = Settings()
