from pydantic import model_validator
from pydantic_settings import BaseSettings

JWT_SECRET_BAWAAN = "kunci-pengembangan-jangan-dipakai-di-produksi"


class Settings(BaseSettings):
    """Konfigurasi dibaca dari environment variable (diisi docker-compose)."""

    # "development" atau "production".
    app_env: str = "development"

    database_url: str = "mysql+pymysql://tabungku:rahasia_tabungku@localhost:3307/tabungku"

    # JWT: kunci rahasia WAJIB diganti lewat .env (JWT_SECRET).
    jwt_secret: str = JWT_SECRET_BAWAAN
    jwt_algoritma: str = "HS256"
    access_token_menit: int = 15
    refresh_token_hari: int = 7

    # Folder foto bukti struk (di docker-compose dipasang sebagai volume).
    upload_dir: str = "/data/uploads"
    maks_ukuran_bukti: int = 2 * 1024 * 1024  # 2 MB

    # Asal (origin) yang boleh memanggil API dari browser, dipisah koma.
    # Aplikasi Android/iOS tidak terkena CORS; ini untuk Flutter Web.
    cors_origins: str = ""

    @property
    def produksi(self) -> bool:
        return self.app_env == "production"

    @model_validator(mode="after")
    def cek_produksi(self):
        # Gagal sejak awal lebih baik daripada berjalan dengan kunci yang bocor.
        if self.produksi and (self.jwt_secret == JWT_SECRET_BAWAAN or len(self.jwt_secret) < 32):
            raise ValueError("JWT_SECRET wajib diganti (minimal 32 karakter) di produksi")
        return self


settings = Settings()
