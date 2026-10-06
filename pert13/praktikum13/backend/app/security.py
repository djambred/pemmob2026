from datetime import datetime, timedelta, timezone

import jwt
from pwdlib import PasswordHash

from .config import settings

# Argon2: algoritma hash password yang direkomendasikan saat ini.
_hasher = PasswordHash.recommended()


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def cek_password(password: str, hash_tersimpan: str) -> bool:
    return _hasher.verify(password, hash_tersimpan)


def _buat_token(user_id: int, jenis: str, umur: timedelta) -> str:
    sekarang = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),  # subject: pemilik token
        "jenis": jenis,  # "access" atau "refresh"
        "iat": sekarang,  # issued at
        "exp": sekarang + umur,
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algoritma)


def buat_access_token(user_id: int) -> str:
    """Umur pendek: dipakai di setiap request."""
    return _buat_token(user_id, "access", timedelta(minutes=settings.access_token_menit))


def buat_refresh_token(user_id: int) -> str:
    """Umur panjang: hanya dipakai untuk meminta access token baru."""
    return _buat_token(user_id, "refresh", timedelta(days=settings.refresh_token_hari))


def baca_token(token: str) -> dict:
    """Melempar jwt.InvalidTokenError bila token rusak, palsu, atau kedaluwarsa."""
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algoritma])
